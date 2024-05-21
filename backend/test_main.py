from fastapi.testclient import TestClient
from sqlalchemy.orm import Session
# from fastapi import Depends
# from typing import Annotated
import pytest
from main import app, get_db_session
import schemas
import models
import auth
import crud
from database import base
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
import os


SQLALCHEMY_DB_URL = "sqlite:///./tester.db"
engine = create_engine(SQLALCHEMY_DB_URL)
testing_session_local = sessionmaker(autocommit=False, autoflush=False, bind=engine)

base.metadata.create_all(bind=engine)

def override_get_db_session():
    try:
        db = testing_session_local()
        yield db
    finally:
        db.close()

# Essentially mocks mains database to be local
app.dependency_overrides[get_db_session] = override_get_db_session

@pytest.fixture
def client():
    with TestClient(app) as client:
        yield client
    os.remove("tester.db") #yikes


def test_create_user_success(client, mocker):
    user_payload = schemas.UserCreate(
        email="test@example.com",
        username="testuser",
        password="testpassword",
        full_name="Test User"
    )
    mock_user_id = "user123"
    mocker.patch("main.auth.create_user", return_value=mock_user_id) # Mock requests to auth to prevent state mismatching in prod

    response = client.post("/users", json=user_payload.model_dump())

    assert response.status_code == 200
    assert {
        "id": mock_user_id, 
        "email": "test@example.com",
        "username": "testuser",
        "full_name": "Test User",
        "role": 2,
    }.items() <= response.json().items() # assert above is a subset of items in response

#TODO: empty/None fields (assert returns 400)
#TODO invalid email format (400)
#TODO alredy existing email (400)
#TODO nonexistent fields (422)
#TODO: invalid input types (422)
#TODO: test with wrong request method (put,delete) (405)
#TODO: test with diff user roles (valid) (200 for all)
#TODO: Test with different input data encodings (e.g., UTF-8, ASCII)
#TODO: very long strings (413?)
#TODO: special characters/non ascii characters (valid/invalid?)
#TODO: already existing username (400)
#TODO: bulk user creation
