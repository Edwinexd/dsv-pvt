import requests


# Google looukp
def google_email_lookup(access_token: str) -> str:
    try:
        response = requests.get(
            "https://www.googleapis.com/oauth2/v3/tokeninfo",
            params={"access_token": access_token},
            timeout=5,
        )
        response.raise_for_status()
        token_info = response.json()
    except requests.RequestException as e:
        raise ValueError(f"Failed to validate access token: {e}") from e

    if "error" in token_info:
        raise ValueError(f"Failed to validate access token: {token_info['error']}")

    email = token_info.get("email")
    if not email:
        raise ValueError("Access token does not contain email")

    return email
