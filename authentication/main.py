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
import logging
from typing import Literal, Never, Optional

import fastapi
from pydantic import BaseModel, Field
from dotenv import load_dotenv

from oauth import google_email_lookup
from users import EmailInUseError, create_user, find_user
from database import EMAIL_REGEX, get_user, setup


logging.basicConfig(level=logging.INFO)

# Load dotenv
load_dotenv()

app = fastapi.FastAPI()

setup()


class LoginPayload(BaseModel):
    email: str
    password: str


class RegisterPayload(LoginPayload):
    email: str = Field(pattern=EMAIL_REGEX)


class BasicUserInfo(BaseModel):
    id: int


class OauthLoginPayload(BaseModel):
    access_token: Optional[str]
    id_token: Optional[str]


@app.post("/users/login")
def login(payload: LoginPayload) -> BasicUserInfo:
    user = find_user(payload.email, payload.password)

    if user is None:
        raise fastapi.HTTPException(401, detail="Invalid email and/or password")

    return BasicUserInfo(id=user.id)


@app.post("/users")
def create_user_(payload: RegisterPayload) -> BasicUserInfo:
    try:
        new_user = create_user(payload.email, payload.password)
    except EmailInUseError as e:
        raise fastapi.HTTPException(400, detail="Email unavailable") from e

    return BasicUserInfo(id=new_user.id)


@app.post("/users/login/oauth/{provider}")
def login_oauth(
    provider: Literal["google"], payload: OauthLoginPayload
) -> BasicUserInfo:
    if payload.access_token is None and payload.id_token is None:
        raise fastapi.HTTPException(400, detail="Missing access token or id token")
    if provider == "google":
        try:
            email = google_email_lookup(payload.access_token, payload.id_token)
        except ValueError as e:
            raise fastapi.HTTPException(400, detail="Invalid access token") from e

        user = get_user(email)
        if user is None:
            raise fastapi.HTTPException(404, detail="User not found")

        return BasicUserInfo(id=user.id)

    return Never
