
import sqlalchemy
from database import add_user, get_user
from passwords import create_password_hash, generate_salt, validate

class UsernameInUseError(Exception):
    pass

def create_user(username: str, password: str):
    salt = generate_salt()
    password_hash = create_password_hash(password, salt)

    try:
        return add_user(username, password_hash, salt)
    except sqlalchemy.exc.IntegrityError as e:
        raise UsernameInUseError() from e

def find_user(username: str, password: str):
    # NOTE: Susceptible to timing attacks
    user = get_user(username)

    # Alchemy stubs don't work with python's type system: https://github.com/python/typeshed/issues/974
    if user is not None and validate(password, user.salt, user.password_hash): # type: ignore
        return user
    
    return None
