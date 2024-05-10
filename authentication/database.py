import os
from typing import List

from dotenv import load_dotenv
from sqlalchemy import BigInteger, Column, ForeignKey
from sqlmodel import Field, Relationship, Session, SQLModel, create_engine, select

from id_generator import IdGenerator

load_dotenv()

ID_GENERATOR = IdGenerator()

ENGINE = create_engine(os.getenv("DATABASE_URL", "sqlite:///:memory:"))

EMAIL_REGEX = r"(^[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\.[a-zA-Z0-9-.]+$)"


class User(SQLModel, table=True):
    id: int = Field(sa_column=Column(BigInteger(), default=None, primary_key=True))
    email: str = Field(unique=True, index=True, regex=EMAIL_REGEX)
    password_hash: str
    salt: str
    oauth_users: List["OauthUser"] = Relationship(back_populates="user")


# Oauth foreign tables if needed
class OauthUser(SQLModel, table=True):
    user_id: int = Field(
        sa_column=Column(BigInteger(), ForeignKey("user.id"), primary_key=True)
    )
    provider: str = Field(primary_key=True)
    provider_user_id: str = Field(index=True)
    user: User = Relationship(back_populates="oauth_users")
    # TODO: Add more fields as needed


def add_user(email: str, password_hash: str, salt: str):
    with Session(ENGINE) as session:
        new_user = User(
            id=ID_GENERATOR.generate_id(),
            email=email,
            password_hash=password_hash,
            salt=salt,
        )
        session.add(new_user)

        session.commit()

        session.refresh(new_user)

        return new_user


def get_user(email: str):
    with Session(ENGINE) as session:
        statement = select(User).where(User.email == email)
        target_user = session.exec(statement).first()

        return target_user


def setup():
    SQLModel.metadata.create_all(ENGINE)


if __name__ == "__main__":
    setup()

    with Session(ENGINE) as test_session:
        # Create a new user
        new_test_user = User(
            id=ID_GENERATOR.generate_id(),
            email="test@blank.com",
            password_hash="1234",
            salt="abcd",
        )
        test_session.add(new_test_user)

        test_session.commit()

        # Query the user
        test_statement = select(User).where(User.email == "test@blank.com")
        user = test_session.exec(test_statement).first()

        assert user

        print(user.username)
