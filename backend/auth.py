import os
import requests
from schemas import UserCreate, UserCreds
from fastapi import HTTPException, Depends

# from google.oauth2 import id_token
# from google.auth.transport import requests
import jwt


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


REDIRECT_URI = "https://pvt.edt.cx/login/callbacks/google"
CLIENT_ID = os.getenv("CLIENT_ID")
CLIENT_SECRET = os.getenv("CLIENT_SECRET")


def authenticate(access_token, client_id):
    try:
        # Decode the JWT token
        idinfo = jwt.decode(access_token, options={"verify_signature": False})

        # Verify the issuer
        if idinfo["iss"] not in ["accounts.google.com", "https://accounts.google.com"]:
            raise ValueError("Invalid issuer")

        # Verify the audience (client ID)
        if idinfo.get("aud") != client_id:
            raise ValueError("Invalid audience")

        # If the request specified a Google Workspace domain
        # if idinfo.get('hd') != DOMAIN_NAME:
        #     raise ValueError('Wrong domain name.')

        # ID token is valid. Get the user's Google Account ID from the decoded token.
        userid = idinfo["sub"]
        return idinfo
    except jwt.DecodeError as e:
        # Invalid token
        pass
    except ValueError as e:
        # Invalid issuer or audience
        pass


def exchange_code_for_token(code):
    token_url = "https://oauth2.googleapis.com/token"
    data = {
        "response_type": code,
        "client_id": CLIENT_ID,
        "client_secret": CLIENT_SECRET,
        "redirect_uri": REDIRECT_URI,
        "grant_type": "authorization_code",
    }
    response = requests.post(token_url, data=data)
    return response.json().get("token")
