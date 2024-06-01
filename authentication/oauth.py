"""
Lace Up & Lead The Way - A pre-race training app and social platform for runners.
Copyright (C) 2024 Group 71 (PVT 7.5) Stockholm University

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program. If not, see <https://www.gnu.org/licenses/>.
"""
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
            response.raise_for_status()
            token_info = response.json()
        except requests.RequestException as e:
            raise ValueError(f"Failed to validate id token: {e}") from e

    email = token_info.get("email")
    if not email:
        raise ValueError("Token does not contain email")

    return email
