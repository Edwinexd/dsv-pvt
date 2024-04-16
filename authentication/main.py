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

from users import find_user


logging.basicConfig(level=logging.INFO)

# Load dotenv
load_dotenv()

app = fastapi.FastAPI()

class LoginPayload(BaseModel):
    username: str
    password: str

@app.post("/login")
def login(payload: LoginPayload):
    user = find_user(payload.username, payload.password)
    # TODO Respond
