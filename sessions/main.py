# pylint: disable=missing-module-docstring
# pylint: disable=missing-function-docstring
# pylint: disable=missing-class-docstring
import datetime
import json
import logging
import os
import secrets
from typing import Optional
import url64
import redis.asyncio as redis
from redis.commands.json.path import Path

from fastapi import FastAPI, HTTPException, Response
from dotenv import load_dotenv

from cryptolib import blake2b_hash, sign, verify
from id_generator import IdGenerator

TOKEN_LIFETIME = 86400

ID_GENERATOR = IdGenerator()

logging.basicConfig(level=logging.INFO)

# Load dotenv
load_dotenv()

app = FastAPI()
redis_client = redis.Redis.from_url(os.getenv("REDIS_URL", ""), decode_responses=True)

# TODO: Bearer should def be a class, methods for getting key etc
def generate_token() -> str:
    sid = secrets.token_urlsafe(256)
    id_ = ID_GENERATOR.generate_id()
    algo = "ed25519"
    sig = sign(f"{id_}:{sid}:{algo}")
    
    return url64.encode(json.dumps({"sid": sid, "id": str(id_), "algo": algo, "sig": sig }))

def bearer_to_key(bearer: str) -> Optional[str]:
    blob = url64.decode(bearer)
    try:
        blob_decoded = json.loads(blob)
    except json.JSONDecodeError:
        return None
    if not all(key in blob_decoded and isinstance(blob_decoded[key], str) for key in ["sid", "id", "algo", "sig"]):
        return None
    sid, id_, algo, sig = blob_decoded["sid"], blob_decoded["id"], blob_decoded["algo"], blob_decoded["sig"]
    if not verify(sig, f"{id_}:{sid}:{algo}"):
        return None
    
    hash_ = blake2b_hash(f"{sid}:{id_}")

    return f"bearer:{id_}:{hash_}"

def user_id_to_revoked_key(user_id: str):
    return f"user:revoked:{user_id}"

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

async def create_bearer(user_id: str):
    # TODO: Collissions may happen
    token = generate_token()
    key = token_to_key(token)
    await ensure_user(user_id)
    async with redis_client.pipeline() as pipeline:
        # TODO: Don't store plain access tokens in the database
        pipeline.json().set(key, Path.root_path(), {"user_id": user_id, "created_at": datetime.datetime.now(datetime.UTC).isoformat()})
        pipeline.expire(key, TOKEN_LIFETIME)
        await pipeline.execute()

    return {"user_id": user_id, "token": token, "expires_in": TOKEN_LIFETIME}

async def ensure_user(user_id: str):
    # Indicates the last time the user revoked all sessions
    key = user_id_to_revoked_key(user_id)
    async with redis_client.pipeline() as pipeline:
        pipeline.set(key, datetime.datetime.now(datetime.UTC).isoformat(), nx=True)
        pipeline.expire(key, TOKEN_LIFETIME)
        await pipeline.execute()

async def revoke_sessions(user_id: str):
    await redis_client.set(user_id_to_revoked_key(user_id), datetime.datetime.now(datetime.UTC).isoformat())

async def get_user_revoked_at(user_id: str) -> Optional[datetime.datetime]:
    revoked_at = await redis_client.get(user_id_to_revoked_key(user_id))
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

