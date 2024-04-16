from sqlmodel import Field, Session, SQLModel, create_engine, select

from id_generator import IdGenerator

ID_GENERATOR = IdGenerator()

ENGINE = create_engine("sqlite:///temp.db")

class User(SQLModel, table=True):
    id: int = Field(default=None, primary_key=True)
    username: str = Field(unique=True, index=True)
    password_hash: str
    salt: str

def add_user(username: str, password_hash: str, salt: str):
    with Session(ENGINE) as session:
        new_user = User(id=ID_GENERATOR.generate_id(), username=username, password_hash=password_hash, salt=salt)
        session.add(new_user)

        session.commit()

        session.refresh(new_user)

        return new_user

def get_user(username: str):
    with Session(ENGINE) as session:
        statement = select(User).where(User.username == username)
        target_user = session.exec(statement).first()

        return target_user

def setup():
    SQLModel.metadata.create_all(ENGINE)

if __name__ == "__main__":
    setup()
    
    with Session(ENGINE) as test_session:
    # Create a new user
        new_test_user = User(username="test", password_hash="1234", salt="abcd")
        test_session.add(new_test_user)

        test_session.commit()

        # Query the user
        test_statement = select(User).where(User.username == "test")
        user = test_session.exec(test_statement).first()
        
        assert user
        
        print(user.username)
