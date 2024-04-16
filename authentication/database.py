import sqlalchemy
from sqlalchemy.orm import declarative_base, sessionmaker
from sqlalchemy import Column, Integer, String

from id_generator import IdGenerator

ID_GENERATOR = IdGenerator()

# TODO: Replace sqlalchemy with SQLModel
ENGINE = sqlalchemy.create_engine("sqlite:///:memory:")

_BASE = declarative_base()

class User(_BASE):
    __tablename__ = "users"

    id = Column(Integer, primary_key=True)
    username = Column(String, unique=True)
    password_hash = Column(String)
    salt = Column(String)

SESSION = sessionmaker(ENGINE)

def add_user(username: str, password_hash: str, salt: str):
    session = SESSION()

    new_user = User(id=ID_GENERATOR.generate_id(), username=username, password_hash=password_hash, salt=salt)
    session.add(new_user)

    session.commit()

    return new_user

def get_user(username: str):
    session = SESSION()

    target_user = session.query(User).filter(User.username == username).first()

    return target_user


if __name__ == "__main__":
    _BASE.metadata.create_all(ENGINE)

    # Create a new user
    test_session = SESSION()

    new_test_user = User(username="test", password_hash="1234", salt="abcd")
    test_session.add(new_test_user)

    test_session.commit()

    # Query the user
    user = test_session.query(User).filter(User.username == "test").first()
    
    assert user
    
    print(user.username)
