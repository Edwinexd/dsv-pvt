import datetime
import json
import secrets
from typing import Optional
from pydantic import BaseModel
import url64

from cryptolib import blake2b_hash, sign, verify
from utils import run_sync


class TokenEntry(BaseModel):
    user_id: str
    created_at: datetime.datetime

    @classmethod
    def from_dict(cls, data: dict):
        return cls(
            user_id=data["user_id"],
            created_at=datetime.datetime.fromisoformat(data["created_at"]),
        )


class TokenEntryWithExpires(TokenEntry):
    expires_in: int

    @classmethod
    def from_dict(cls, data: dict):
        return cls(
            user_id=data["user_id"],
            created_at=datetime.datetime.fromisoformat(data["created_at"]),
            expires_in=data["expires_in"],
        )


class Bearer:
    def __init__(
        self, sid: str, id_: str, algo: str, sig: str, valid: Optional[bool] = None
    ) -> None:
        self._sid = sid
        self._id = id_
        self._algo = algo
        self._sig = sig
        self.valid: Optional[bool] = valid
        self._cached_key: Optional[str] = None

    @property
    def sid(self) -> str:
        """
        Returns the sid tokens used for the signature
        """
        return self._sid

    @property
    def id_(self) -> str:
        """
        Returns the globally unique id of the bearer
        """
        return self._id

    @property
    def algo(self) -> str:
        """
        Returns the algorithm used for the signature
        """
        return self._algo

    @property
    def sig(self) -> str:
        """
        Returns the signature of the bearer
        """
        return self._sig

    async def _verify(self) -> bool:
        return await run_sync(verify, self.sig, f"{self.id_}:{self.sid}:{self.algo}")

    async def is_valid(self) -> bool:
        """
        Returns whether the bearer is valid, i.e. the signature is correct
        """
        if self.valid is None:
            self.valid = await self._verify()
        return self.valid

    async def to_key(self) -> str:
        """
        Returns the redis key for the bearer
        """
        if self._cached_key is None:
            if not await self.is_valid():
                raise ValueError("Bearer is not valid")
            hash_ = await run_sync(blake2b_hash, f"{self._sid}:{self._id}")
            self._cached_key = f"bearer:{self._id}:{hash_}"
        return self._cached_key

    async def to_token(self) -> str:
        """
        Returns the token representation of the bearer used as a bearer token header
        """
        if not await self.is_valid():
            raise ValueError("Bearer is not valid")

        return url64.encode(
            json.dumps(
                {"sid": self._sid, "id": self._id, "algo": self._algo, "sig": self._sig}
            )
        )

    @classmethod
    def from_token(cls, token: str) -> "Bearer":
        """
        Creates a Bearer from a token, i.e. the part after the Bearer keyword in the Authorization header
        """
        blob = url64.decode(token)
        try:
            blob_decoded = json.loads(blob)
        except json.JSONDecodeError as e:
            raise ValueError("Invalid token") from e
        if not all(
            key in blob_decoded and isinstance(blob_decoded[key], str)
            for key in ["sid", "id", "algo", "sig"]
        ):
            raise ValueError("Invalid token")
        sid, id_, algo, sig = (
            blob_decoded["sid"],
            blob_decoded["id"],
            blob_decoded["algo"],
            blob_decoded["sig"],
        )
        return cls(sid, id_, algo, sig)

    @classmethod
    async def new(cls, id_: str) -> "Bearer":
        """
        Creates a new bearer with a random sid
        """
        sid = url64.encode(secrets.token_bytes(256))
        algo = "ed25519"
        sig = await run_sync(sign, f"{id_}:{sid}:{algo}")
        return cls(sid, str(id_), algo, sig, valid=True)

    def __repr__(self) -> str:
        return (
            f"<Bearer sid={self.sid} id={self.id_} algo={self.algo} valid={self.valid}>"
        )
