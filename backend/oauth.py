from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
import requests


# Scope = https://www.googleapis.com/auth/userinfo.email

app = FastAPI()


class AccessToken(BaseModel):
    access_token: str


@app.post("login/callbacks/google")
async def login_with_google(token_data: AccessToken):
    access_token = token_data.access_token

    try:
        response = requests.get(
            f"https://www.googleapis.com/oauth2/v3/tokeninfo?access_token={access_token}"
        )
        response.raise_for_status()
        token_info = response.json()
    except requests.RequestException as e:
        raise HTTPException(
            status_code=400, detail=f"Failed to validate access token: {str(e)}"
        )

    if "error" in token_info:
        raise HTTPException(
            status_code=400,
            detail=f"Invalid access token: {token_info['error_description']}",
        )

    email = token_info.get("email")
    if not email:
        raise HTTPException(status_code=400, detail="Email not found in token")
    return {"email": email}


# AUTH_SERVER_URL = os.getenv("AUTH_URL")

# @app.post('/verify-token')
# async def verify_token(request: Request):
#    data = await request.json()
#    access_token = data.get('access_token')

# Send token verification request to the authorization server
#    response = requests.post(f'{AUTH_SERVER_URL}/verify-token', json={'access_token': access_token})

#    if response.status_code == 200:
# Token is valid, extract user information from the response
#        token_info = response.json()
#        user_id = token_info.get('user_id')
#        email = token_info.get('email')

# Perform additional logic (e.g., user authentication, authorization)
# ...

#        return {'user_id': user_id, 'email': email}
#    else:
# Token is invalid or verification failed
#        raise HTTPException(status_code=401, detail='Invalid token')

# if __name__ == '__main__':
#    import uvicorn
#    uvicorn.run(app, host='0.0.0.0', port=8000)


# REDIRECT_URI = "https://pvt.edt.cx/login/callbacks/google"
# CLIENT_ID = os.getenv("CLIENT_ID")
# CLIENT_SECRET = os.getenv("CLIENT_SECRET")


# def exchange_code_for_token(code):
#    token_url = "https://oauth2.googleapis.com/token"
#    data = {
#        "response_type": code,
#        "client_id": CLIENT_ID,
#        "client_secret": CLIENT_SECRET,
#        "redirect_uri": REDIRECT_URI,
#        "grant_type": "authorization_code",
#    }
#    response = requests.post(token_url, data=data)
#    return response.json().get("token")
