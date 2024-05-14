import os
import requests
from schemas import UserCreate, UserCreds
from fastapi import HTTPException
from google.oauth2 import id_token
from google.auth.transport import requests


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

CLIENT_ID = os.getenv("CLIENT_ID")

# (Receive token by HTTPS POST)
def authenticate(access_token):
    try:
    # Specify the CLIENT_ID of the app that accesses the backend:
        idinfo = id_token.verify_oauth2_token(access_token, requests.Request(), CLIENT_ID)

    # Or, if multiple clients access the backend server:
    # idinfo = id_token.verify_oauth2_token(token, requests.Request())
        if idinfo['iss'] not in ['accounts.google.com', 'https://accounts.google.com']:
            raise ValueError('Invalid issuer')
        return idinfo 

    # If the request specified a Google Workspace domain
    # if idinfo['hd'] != DOMAIN_NAME:
    #     raise ValueError('Wrong domain name.')

    # ID token is valid. Get the user's Google Account ID from the decoded token.
        userid = idinfo['sub']
    except ValueError:
    # Invalid token
        pass
