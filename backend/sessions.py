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
