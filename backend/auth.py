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
import requests
from schemas import UserCreate, UserCreds
from fastapi import HTTPException


AUTH_URL = os.getenv("AUTH_URL")


def login(creds: UserCreds):
    response = requests.post(f"{AUTH_URL}/users/login", json=creds.model_dump())
    if not response.ok:
        raise HTTPException(
            status_code=response.status_code, detail=response.json()["detail"]
        )
    return str(response.json()["id"])


def create_user(user_payload: UserCreate):
    auth_payload = {"email": user_payload.email, "password": user_payload.password}
    response = requests.post(f"{AUTH_URL}/users", json=auth_payload)
    if not response.ok:
        raise HTTPException(
            status_code=response.status_code, detail=response.json()["detail"]
        )
    return str(response.json()["id"])


def login_ouath(access_token: Optional[str], id_token: Optional[str], provider: str):
    response = requests.post(
        f"{AUTH_URL}/users/login/oauth/{provider}",
        json={"access_token": access_token, "id_token": id_token},
    )
    if not response.ok:
        raise HTTPException(
            status_code=response.status_code, detail=response.json()["detail"]
        )

    return str(response.json()["id"])
