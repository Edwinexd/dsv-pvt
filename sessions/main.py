"""
Lace Up & Lead The Way - A pre-race training app and social platform for runners.
Copyright (C) 2024 Group 71 (PVT 7.5) Stockholm University

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program. If not, see <https://www.gnu.org/licenses/>.
"""
# pylint: disable=missing-module-docstring
# pylint: disable=missing-function-docstring
# pylint: disable=missing-class-docstring
import datetime
import logging
import os
from typing import Optional
import redis.asyncio as redis
from redis.commands.json.path import Path

from fastapi import FastAPI, HTTPException, Response
from dotenv import load_dotenv

from id_generator import IdGenerator
from schemas import Bearer, TokenEntryWithExpires

TOKEN_LIFETIME = 86400

ID_GENERATOR = IdGenerator()

logging.basicConfig(level=logging.INFO)

# Load dotenv
load_dotenv()

app = FastAPI()
redis_client = redis.Redis.from_url(os.getenv("REDIS_URL", ""), decode_responses=True)


def user_id_to_revoked_key(user_id: str):
    return f"user:revoked:{user_id}"


async def get_token(bearer: Bearer) -> Optional[TokenEntryWithExpires]:
    key = await bearer.to_key()
    async with redis_client.pipeline() as pipeline:
        pipeline.json().get(key)
        pipeline.ttl(key)
        result = await pipeline.execute()
        if not result[0]:
            return None

        return TokenEntryWithExpires.from_dict(result[0] | {"expires_in": result[1]})


async def delete_token(bearer: Bearer):
    key = await bearer.to_key()
    await redis_client.delete(key)


async def renew_token(bearer: Bearer):
    key = await bearer.to_key()
    await redis_client.expire(key, TOKEN_LIFETIME)


async def create_bearer(user_id: str) -> Bearer:
    bearer = await Bearer.new(str(ID_GENERATOR.generate_id()))
    key = await bearer.to_key()
    await ensure_user(user_id)
    async with redis_client.pipeline() as pipeline:
        pipeline.json().set(
            key,
            Path.root_path(),
            {
                "user_id": user_id,
                "created_at": datetime.datetime.now(datetime.UTC).isoformat(),
            },
        )
        pipeline.expire(key, TOKEN_LIFETIME)
        await pipeline.execute()

    return bearer


async def ensure_user(user_id: str):
    # Indicates the last time the user revoked all sessions
    key = user_id_to_revoked_key(user_id)
    async with redis_client.pipeline() as pipeline:
        pipeline.set(key, datetime.datetime.now(datetime.UTC).isoformat(), nx=True)
        pipeline.expire(key, TOKEN_LIFETIME)
        await pipeline.execute()


async def revoke_sessions(user_id: str):
    await redis_client.set(
        user_id_to_revoked_key(user_id), datetime.datetime.now(datetime.UTC).isoformat()
    )


async def get_user_revoked_at(user_id: str) -> Optional[datetime.datetime]:
    revoked_at = await redis_client.get(user_id_to_revoked_key(user_id))
    if not revoked_at:
        return None

    return datetime.datetime.fromisoformat(revoked_at)


@app.post("/users/{user_id}/sessions")
async def create_session(user_id: str):
    bearer = await create_bearer(user_id)
    return {"token": await bearer.to_token()}


@app.delete("/users/{user_id}/sessions")
async def revoke_sessions_(user_id: str):
    await revoke_sessions(user_id)
    return Response(status_code=204)


@app.delete("/sessions/{bearer}")
async def revoke_session(bearer: str):
    try:
        loaded_bearer = Bearer.from_token(bearer)
        session = await get_token(loaded_bearer)
    except ValueError as e:
        raise HTTPException(status_code=400, detail="Invalid token") from e

    if not session:
        raise HTTPException(status_code=404, detail="Expired or invalid token")

    await delete_token(loaded_bearer)

    return Response(status_code=204)


@app.get("/sessions/{bearer}")
async def get_session(bearer: str, renew: bool = True):
    try:
        loaded_bearer = Bearer.from_token(bearer)
        session = await get_token(loaded_bearer)
    except ValueError as e:
        raise HTTPException(status_code=400, detail="Invalid token") from e

    if not session:
        raise HTTPException(status_code=404, detail="Expired or invalid token")

    if renew:
        await renew_token(loaded_bearer)
        await ensure_user(session.user_id)

    revoke_at = await get_user_revoked_at(session.user_id)
    if revoke_at and revoke_at > session.created_at:
        await delete_token(loaded_bearer)
        raise HTTPException(status_code=404, detail="Session not found")

    return session
