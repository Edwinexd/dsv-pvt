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
import secrets
import hashlib


def generate_salt():
    return secrets.token_urlsafe(256)


def _pbkdf2_hmac(password: str, salt: str):
    return hashlib.pbkdf2_hmac("sha256", password.encode(), salt.encode(), 100000).hex()


def validate(password: str, salt: str, password_hash: str) -> bool:
    return _pbkdf2_hmac(password, salt) == password_hash


def create_password_hash(password: str, salt: str):
    return _pbkdf2_hmac(password, salt)
