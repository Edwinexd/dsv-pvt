# pylint: disable=missing-module-docstring
# pylint: disable=missing-function-docstring
# pylint: disable=missing-class-docstring
import logging
import mimetypes
import os
from typing import Literal, List, Union

import fastapi
from pydantic import BaseModel
from dotenv import load_dotenv

from users import UsernameInUseError, create_user, find_user
from database import setup


logging.basicConfig(level=logging.INFO)

# Load dotenv
load_dotenv()

app = fastapi.FastAPI()

setup()

class LoginPayload(BaseModel):
    username: str
    password: str

class BasicUserInfo(BaseModel):
    id: int

@app.post("/users/login")
def login(payload: LoginPayload):
    user = find_user(payload.username, payload.password)
    
    if user is None:
        raise fastapi.HTTPException(401, detail="Invalid username and/or password")

    return BasicUserInfo(id=user.id) # type: ignore

@app.post("/users")
def create_user_(payload: LoginPayload):
    try:
        new_user = create_user(payload.username, payload.password)
    except UsernameInUseError as e:
        raise fastapi.HTTPException(400, detail="Username unavailable") from e

    return BasicUserInfo(id=new_user.id) # type: ignore
