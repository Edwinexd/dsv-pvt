from typing import Optional
import requests


# Google looukp
def google_email_lookup(access_token: Optional[str], id_token: Optional[str]) -> str:
    if not access_token and not id_token:
        raise ValueError("Either access_token or id_token must be provided")
    if access_token:
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
    else:
        try:
            response = requests.get(
                "https://oauth2.googleapis.com/tokeninfo",
                params={"id_token": id_token},
                timeout=5,
            )
            print(response.text)
            response.raise_for_status()
            token_info = response.json()
        except requests.RequestException as e:
            raise ValueError(f"Failed to validate id token: {e}") from e

    email = token_info.get("email")
    if not email:
        raise ValueError("Token does not contain email")

    return email
