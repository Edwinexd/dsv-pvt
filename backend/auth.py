import os
import requests
from schemas import UserCreate, UserCreds
from fastapi import HTTPException

AUTH_URL = os.getenv("AUTH_URL")

def login(creds: UserCreds):
    response = requests.post(f"{AUTH_URL}/users/login", json=creds.model_dump())
    if not response.ok:
        raise HTTPException(status_code=response.status_code, detail=response.json()["detail"])
    return response.json()["id"]

def create_user(user_payload: UserCreate):
    auth_payload = {
        "username": user_payload.username,
        "password": user_payload.password
    }
    response = requests.post(f"{AUTH_URL}/users", json=auth_payload)
    if not response.ok:
        raise HTTPException(status_code=response.status_code, detail=response.json()["detail"])
    return response.json()["id"]