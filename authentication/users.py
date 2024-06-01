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
import sqlalchemy
from database import add_user, get_user
from passwords import create_password_hash, generate_salt, validate


class EmailInUseError(Exception):
    pass


def create_user(username: str, password: str):
    salt = generate_salt()
    password_hash = create_password_hash(password, salt)

    try:
        return add_user(username, password_hash, salt)
    except sqlalchemy.exc.IntegrityError as e:
        raise EmailInUseError() from e


def find_user(username: str, password: str):
    # NOTE: Susceptible to timing attacks
    user = get_user(username)

    if user is not None and validate(password, user.salt, user.password_hash):
        return user

    return None
