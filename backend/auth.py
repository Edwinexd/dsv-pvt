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


REDIRECT_URI = 'http://localhost:5000/callback'
CLIENT_ID = os.getenv("CLIENT_ID")
CLIENT_SECRET = os.getenv("CLIENT_SECRET")

def exchange_code_for_token(code):
    token_url = 'https://oauth2.googleapis.com/token'
    data = {
        'code' : code,
        'client_id' : CLIENT_ID,
        'client_secret' : CLIENT_SECRET,
        'redirect_uri' : REDIRECT_URI,
        'grant_type' : 'authorization_code'
    }
    response = requests.post(token_url, data=data)
    return response.json().get('access_token')


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
