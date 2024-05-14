import os
from typing import Optional
from fastapi import HTTPException
import requests

from schemas import SessionUser

SESSIONS_URL = os.getenv("SESSIONS_URL", "")


def create_session(user_id: int) -> str:
    response = requests.post(f"{SESSIONS_URL}/users/{user_id}/sessions", timeout=5)
    if not response.ok:
        raise HTTPException(
            status_code=response.status_code, detail=response.json()["detail"]
        )
    return response.json()["token"]


def revoke_sessions(user_id: int) -> None:
    response = requests.delete(f"{SESSIONS_URL}/users/{user_id}/sessions", timeout=5)
    if not response.ok:
        raise HTTPException(
            status_code=response.status_code, detail=response.json()["detail"]
        )


def revoke_session(token: str) -> None:
    response = requests.delete(f"{SESSIONS_URL}/sessions/{token}", timeout=5)
    if not response.ok:
        raise HTTPException(
            status_code=response.status_code, detail=response.json()["detail"]
        )


def get_session(token: str) -> Optional[SessionUser]:
    response = requests.get(f"{SESSIONS_URL}/sessions/{token}", timeout=5)
    if not response.ok:
        return None
    return SessionUser(id=response.json()["user_id"])
