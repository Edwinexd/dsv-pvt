
from google.oauth2 import id_token
from google.auth.transport import requests


#Scope = https://www.googleapis.com/auth/userinfo.email

REDIRECT_URI = 'http://localhost:5000/callback'







# (Receive token by HTTPS POST)
try:
    # Specify the CLIENT_ID of the app that accesses the backend:
    idinfo = id_token.verify_oauth2_token(token, requests.Request(), CLIENT_ID)

    # Or, if multiple clients access the backend server:
    # idinfo = id_token.verify_oauth2_token(token, requests.Request())
    # if idinfo['aud'] not in [CLIENT_ID_1, CLIENT_ID_2, CLIENT_ID_3]:
    #     raise ValueError('Could not verify audience.')

    # If the request specified a Google Workspace domain
    # if idinfo['hd'] != DOMAIN_NAME:
    #     raise ValueError('Wrong domain name.')

    # ID token is valid. Get the user's Google Account ID from the decoded token.
    userid = idinfo['sub']
except ValueError:
    # Invalid token
    pass