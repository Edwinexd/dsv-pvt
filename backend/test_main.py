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
    mocker.patch("main.auth.create_user", return_value=mock_user_id) # Mock requests to auth to prevent state missmatches
    #mocker.patch(
    #    "main.crud.create_user",
    #    return_value=models.User(email=user_payload.email, username = user_payload.username, full_name = user_payload.full_name, date_created="2023-05-05", role = 2, id=mock_user_id),
    #)

    response = client.post("/users", json=user_payload.dict())

    print(response.json())
    assert response.status_code == 200
    #assert response.json() == {"id": mock_user_id, **user_payload.dict()}
    #auth.create_user.assert_called_once_with(user_payload)
    #crud.create_user.assert_called_once_with(
    #    db_session=db_session,
    #    user=mocker.ANY
    #)
#    response = client.post(
#        "/users",
#        json = {
#            "email" : "test@email.com",
#            "username" : "test123",
#            "full_name" : "Test Testsson",
#            "password" : "test123",
#        }
#    )
#    assert response.status_code == 200
#
#    test_user_id = response.json()["id"]
#    get_user_response = client.get(
#        f"/users/{test_user_id}",
#        headers = {
#            "Authorization" : token,
#        }
#    )
#
#    assert get_user_response.status_code == 200
#    assert get_user_response.json()["id"] == test_user_id

