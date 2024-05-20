from fastapi.testclient import TestClient
from sqlalchemy.orm import Session
# from fastapi import Depends
# from typing import Annotated
import pytest
from main import app
import schemas
import models
import auth
import crud

# TODO: Before all, mock main.get_db_session to return mock_session below.

def login():
    response = client.post(
        "/users/login",
        json={
            "email": "test@email.com",
            "password": "test123",
        }
    )
    return response.json()["bearer"]


@pytest.fixture
def db_session(mocker):
    mock_session = mocker.MagicMock(spec=Session)
    return mock_session


@pytest.fixture
def client():
    with TestClient(app) as client:
        yield client


def test_create_user_success(client, db_session, mocker):
    user_payload = schemas.UserCreate(
        email="test@example.com",
        username="testuser",
        password="testpassword",
        full_name="Test User"
    )
    mock_user_id = "user123"
    mocker.patch("main.auth.create_user", return_value=mock_user_id)
    mocker.patch(
        "main.crud.create_user",
        return_value=models.User(**user_payload.dict(), id=mock_user_id),
    )

    response = client.post("/users", json=user_payload.dict())

    assert response.status_code == 200
    assert response.json() == {"id": mock_user_id, **user_payload.dict()}
    auth.create_user.assert_called_once_with(user_payload)
    crud.create_user.assert_called_once_with(
        db_session=db_session,
        user=mocker.ANY
    )
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

