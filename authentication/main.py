# pylint: disable=missing-module-docstring
# pylint: disable=missing-function-docstring
# pylint: disable=missing-class-docstring
import logging
import mimetypes
import os
from typing import Literal, List, Union

import fastapi
from pydantic import BaseModel, Field
from dotenv import load_dotenv

from users import EmailInUseError, create_user, find_user
from database import EMAIL_REGEX, setup


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
