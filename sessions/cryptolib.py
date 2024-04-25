import os
import hashlib

from cryptography.exceptions import InvalidSignature
from cryptography.hazmat.primitives.asymmetric.ed25519 import \
    Ed25519PrivateKey  # pylint: disable=no-name-in-module
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

if __name__ == "__main__":
    data = "Hello, world!"
    signature = sign(data)
    print(f"Signature: {signature}")
    print(f"Verification: {verify(signature, data)}")
    print(f"Verification: {verify(signature, data + 'x')}")
