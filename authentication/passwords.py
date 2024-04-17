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
