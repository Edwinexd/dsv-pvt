import os
from typing import Optional
import requests

from schemas import SessionUser

SESSIONS_URL = os.getenv("SESSIONS_URL", "")

def create_session(user_id: int) -> str:
    response = requests.post(f"{SESSIONS_URL}/users/{user_id}/sessions", timeout=5)
    response.raise_for_status()
    return response.json()["token"]

def revoke_sessions(user_id: int) -> None:
    response = requests.delete(f"{SESSIONS_URL}/users/{user_id}/sessions", timeout=5)
    response.raise_for_status()

def revoke_session(token: str) -> None:
    response = requests.delete(f"{SESSIONS_URL}/sessions/{token}", timeout=5)
    response.raise_for_status()

def get_session(token: str) -> Optional[SessionUser]:
    response = requests.get(f"{SESSIONS_URL}/sessions/{token}", timeout=5)
    if not response.ok:
        return None
    return SessionUser(id=response.json()["user_id"])
