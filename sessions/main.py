# pylint: disable=missing-module-docstring
# pylint: disable=missing-function-docstring
# pylint: disable=missing-class-docstring
import datetime
import logging
import os
import secrets
from typing import Optional
import redis.asyncio as redis
from redis.commands.json.path import Path

from fastapi import FastAPI, HTTPException, Response
from dotenv import load_dotenv

TOKEN_LIFETIME = 86400

logging.basicConfig(level=logging.INFO)

# Load dotenv
load_dotenv()

app = FastAPI()
redis_client = redis.Redis.from_url(os.getenv("REDIS_URL", ""), decode_responses=True)

def generate_token():
    # TODO: Implement proper bearer token generation
    return secrets.token_urlsafe(256)

def token_to_key(token: str):
    return f"token:{token}"

async def get_token(token: str):
    key = token_to_key(token)
    async with redis_client.pipeline() as pipeline:
        pipeline.json().get(key)
        pipeline.ttl(key)
        result = await pipeline.execute()
        if not result[0]:
            return None

        val, ttl = tuple(result)

        return val | {"token": token, "expires_in": ttl if ttl else 0}

async def delete_token(token: str):
    key = token_to_key(token)
    await redis_client.delete(key)

async def renew_token(token: str):
    key = token_to_key(token)
    await redis_client.expire(key, TOKEN_LIFETIME)

async def create_token(user_id: str):
    # TODO: Collissions may happen
    token = generate_token()
    key = token_to_key(token)
    await ensure_user(user_id)
    async with redis_client.pipeline() as pipeline:
        pipeline.json().set(key, Path.root_path(), {"user_id": user_id, "created_at": datetime.datetime.now(datetime.UTC).isoformat()})
        pipeline.expire(key, TOKEN_LIFETIME)
        await pipeline.execute()

    return {"user_id": user_id, "token": token, "expires_in": TOKEN_LIFETIME}

async def ensure_user(user_id: str):
    # Indicates the last time the user revoked all sessions
    async with redis_client.pipeline() as pipeline:
        pipeline.set(f"user:revoked:{user_id}", datetime.datetime.now(datetime.UTC).isoformat(), nx=True)
        pipeline.expire(f"user:revoked:{user_id}", TOKEN_LIFETIME)
        await pipeline.execute()

async def revoke_sessions(user_id: str):
    await redis_client.set(f"user:revoked:{user_id}", datetime.datetime.now(datetime.UTC).isoformat())

async def get_user_revoked_at(user_id: str) -> Optional[datetime.datetime]:
    revoked_at = await redis_client.get(f"user:revoked:{user_id}")
    if not revoked_at:
        return None

    return datetime.datetime.fromisoformat(revoked_at)

@app.post("/users/{user_id}/sessions")
async def create_session(user_id: str):
    token = await create_token(user_id)
    return token

@app.delete("/users/{user_id}/sessions")
async def revoke_sessions_(user_id: str):
    await revoke_sessions(user_id)
    return Response(status_code=204)

@app.delete("/sessions/{token}")
async def revoke_session(token: str):
    session = await get_token(token)
    if not session:
        raise HTTPException(status_code=404, detail="Session not found")

    await delete_token(token)
    return Response(status_code=204)

@app.get("/sessions/{token}")
async def get_session(token: str, renew: bool = True):
    session = await get_token(token)
    if not session:
        raise HTTPException(status_code=404, detail="Session not found")

    if renew:
        await renew_token(token)
        await ensure_user(session["user_id"])

    revoke_at = await get_user_revoked_at(session["user_id"])
    if revoke_at and revoke_at > datetime.datetime.fromisoformat(session["created_at"]):
        await delete_token(token)
        raise HTTPException(status_code=404, detail="Session not found")

    return session

