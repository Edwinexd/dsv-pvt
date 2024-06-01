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
import os
import hashlib

from cryptography.exceptions import InvalidSignature
from cryptography.hazmat.primitives.asymmetric.ed25519 import (
    Ed25519PrivateKey,
)  # pylint: disable=no-name-in-module
from dotenv import load_dotenv
import url64

load_dotenv()

_PRIVATE_KEY_BYTES = os.getenv("PRIVATE_KEY_BYTES", None)
if not _PRIVATE_KEY_BYTES:
    raise ValueError("PRIVATE_KEY_BYTES not set in environment")

PRIVATE_KEY = Ed25519PrivateKey.from_private_bytes(bytes.fromhex(_PRIVATE_KEY_BYTES))

PUBLIC_KEY = PRIVATE_KEY.public_key()


def sign(data: str) -> str:
    return PRIVATE_KEY.sign(data.encode()).hex()


def verify(signature: str, data: str) -> bool:
    try:
        PUBLIC_KEY.verify(bytes.fromhex(signature), data.encode())
        return True
    except (InvalidSignature, ValueError):
        return False


def blake2b_hash(data: str) -> str:
    return url64.encode(hashlib.blake2b(data.encode()).digest())
