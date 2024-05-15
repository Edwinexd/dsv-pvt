import os
import requests
from schemas import UserCreate, UserCreds
from fastapi import HTTPException, Depends
import jwt


AUTH_URL = os.getenv("AUTH_URL")
REDIRECT_URI = "https://pvt.edt.cx/login/callbacks/google"
CLIENT_ID = os.getenv("CLIENT_ID")
CLIENT_SECRET = os.getenv("CLIENT_SECRET")


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


def authenticate(access_token, client_id):
    try:
        # Decode JWT token
        idinfo = jwt.decode(access_token, options={"verify_signature": False})

        # Verify issuer
        if idinfo["iss"] not in ["accounts.google.com", "https://accounts.google.com"]:
            raise ValueError("Invalid issuer")

        # Verifycclient ID
        if idinfo.get("aud") != client_id:
            raise ValueError("Invalid audience")

        # ID token is valid - Get the user's Google Account ID from the decoded token
        userid = idinfo["sub"]
        return idinfo
    except jwt.DecodeError as e:
        pass
    except ValueError as e:
        pass
