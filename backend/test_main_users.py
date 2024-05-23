"""
Tests for user endpoints in main.py
"""

import os
import re

# from fastapi import Depends
# from typing import Annotated
import pytest
from fastapi.testclient import TestClient
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker

import models
from database import base
from main import app, get_db_session

SQLALCHEMY_DB_URL = "sqlite:///./tester.db"
engine = create_engine(SQLALCHEMY_DB_URL)
testing_session_local = sessionmaker(autocommit=False, autoflush=False, bind=engine)

base.metadata.create_all(bind=engine)

VERY_LONG_STRING = "ttemptemptemptemptemptemptemptemptemptemptemptemptemptemptemptemptemptemptemptemptemptemptemptemptemptemptemptemptemptemptemptemptemptemptemptemptemptemptemptemptemptemptemptemptemptempemp"


def override_get_db_session():
    try:
        db = testing_session_local()
        yield db
    finally:
        db.close()


# Essentially mocks mains database to be local
app.dependency_overrides[get_db_session] = override_get_db_session


class PayloadGenerator:
    count: int

    def __init__(self):
        PayloadGenerator.count = 0

    def get_count():
        PayloadGenerator.count += 1
        return PayloadGenerator.count

    def generate_user_payload(self):
        c = PayloadGenerator.get_count()
        return {
            "email": f"test{c}@example.com",
            "username": f"testuser{c}",
            "password": "password",
            "full_name": "Test User",
        }

    def generate_mock_id(self):
        return f"user{PayloadGenerator.count}"


payload_generator = PayloadGenerator()


@pytest.fixture(scope="session", autouse=True)
def client():
    with TestClient(app) as app_client:
        # TODO: create user to use in tests
        yield app_client
    os.remove("tester.db")


# USER CREATION TESTS
def test_create_user_success(client, mocker):
    user_payload = payload_generator.generate_user_payload()
    mock_user_id = payload_generator.generate_mock_id()
    mocker.patch(
        "main.auth.create_user", return_value=mock_user_id
    )  # Mock requests to auth to prevent state mismatching in prod

    response = client.post("/users", json=user_payload)

    assert response.status_code == 200
    assert {
        "id": mock_user_id,
        "email": user_payload["email"],
        "username": user_payload["username"],
        "full_name": user_payload["full_name"],
        "role": 2,
        # assert above is a subset of items in response
    }.items() <= response.json().items()


def test_empty_fields(client, mocker):
    user_payload = payload_generator.generate_user_payload()
    user_payload["email"] = ""
    mock_user_id = payload_generator.generate_mock_id()

    mocker.patch("main.auth.create_user", return_value=mock_user_id)

    response = client.post("/users", json=user_payload)

    assert response.status_code == 400
    assert "id" not in response.json()


def test_none_fields(client, mocker):
    user_payload = payload_generator.generate_user_payload()
    user_payload["username"] = None
    mock_user_id = payload_generator.generate_mock_id()

    mocker.patch("main.auth.create_user", return_value=mock_user_id)

    response = client.post("/users", json=user_payload)

    assert response.status_code == 422
    assert "id" not in response.json()


def test_invalid_email_format(client, mocker):
    user_payload = payload_generator.generate_user_payload()
    user_payload["email"] = "@example@@com."
    mock_user_id = payload_generator.generate_mock_id()

    mocker.patch("main.auth.create_user", return_value=mock_user_id)

    response = client.post("/users", json=user_payload)

    assert response.status_code == 400
    assert "id" not in response.json()


def test_already_existing_email(client, mocker):  # 5
    user_payload = payload_generator.generate_user_payload()
    mock_user_id = payload_generator.generate_mock_id()

    mocker.patch("main.auth.create_user", return_value=mock_user_id)

    response = client.post("/users", json=user_payload)

    assert response.status_code == 200
    assert "id" in response.json()

    mock_user_id2 = "user5232"
    mocker.patch("main.auth.create_user", return_value=mock_user_id2)

    # Send same email again
    response2 = client.post("/users", json=user_payload)

    assert response.status_code == 409
    assert "id" not in response.json()
    assert re.search("already exists", response.json()["detail"], re.IGNORECASE)


def test_nonexistent_fields(client, mocker):
    user_payload = payload_generator.generate_user_payload()
    user_payload.pop("full_name")
    mock_user_id = payload_generator.generate_mock_id()

    mocker.patch("main.auth.create_user", return_value=mock_user_id)

    response = client.post("/users", json=user_payload)

    assert response.status_code == 422
    assert "id" not in response.json()
    assert re.search("nonexistent field", response.json()["detail"], re.IGNORECASE)


def test_invalid_input_types(client, mocker):
    user_payload = payload_generator.generate_user_payload()
    user_payload["full_name"] = 32
    mock_user_id = payload_generator.generate_mock_id()

    mocker.patch("main.auth.create_user", return_value=mock_user_id)

    response = client.post("/users", json=user_payload)

    assert response.status_code == 422
    assert "id" not in response.json()
    assert re.search("invalid input type", response.json()["detail"], re.IGNORECASE)


def test_wrong_request_method_put(client, mocker):
    user_payload = payload_generator.generate_user_payload()
    mock_user_id = payload_generator.generate_mock_id()

    mocker.patch("main.auth.create_user", return_value=mock_user_id)

    response = client.put("/users", json=user_payload)

    assert response.status_code == 405
    assert "id" not in response.json()
    assert re.search("wrong request method", response.json()["detail"], re.IGNORECASE)


def test_wrong_request_method_delete(client, mocker):
    user_payload = payload_generator.generate_user_payload()
    mock_user_id = payload_generator.generate_mock_id()

    mocker.patch("main.auth.create_user", return_value=mock_user_id)

    response = client.delete("/users", json=user_payload)

    assert response.status_code == 405
    assert "id" not in response.json()
    assert re.search("wrong request method", response.json()["detail"], re.IGNORECASE)


def test_very_long_strings(client, mocker):
    user_payload = payload_generator.generate_user_payload()
    user_payload["username"] = VERY_LONG_STRING
    mock_user_id = payload_generator.generate_mock_id()

    mocker.patch("main.auth.create_user", return_value=mock_user_id)

    response = client.post("/users", json=user_payload)

    assert response.status_code == 413
    assert "id" not in response.json()
    assert re.search("too long", response.json()["detail"], re.IGNORECASE)


def test_bulk_user_creation(client, mocker):
    responses = set()

    for i in range(0, 10):
        user_payload = payload_generator.generate_user_payload()
        mock_user_id = payload_generator.generate_mock_id()

        mocker.patch("main.auth.create_user", return_value=mock_user_id)

        response = client.post("/users", json=user_payload)
        responses.add(response.status_code)

    assert 429 in responses


creds = {  # Normal user
    "email": "test1@example.com",
    "password": "password",
}


def login(client, mocker) -> str:
    """
    Logs in to mock client and gets access token.
    """
    mocker.patch("main.auth.login", return_value="user1")
    response = client.post("/users/login", json=creds)
    return response.json()["bearer"]


# USER READING TESTS
def test_read_single_user(client, mocker):
    token = login(client, mocker)
    skip = 0
    limit = 1

    response = client.get(
        f"/users?skip={skip}&limit={limit}", headers={"Authorization": token}
    )

    users = response.json()["data"]

    assert len(users) == 1


def test_read_multiple_users(client, mocker):
    token = login(client, mocker)
    skip = 0
    limit = 3

    response = client.get(
        f"/users?skip={skip}&limit={limit}", headers={"Authorization": token}
    )

    users = response.json()["data"]

    assert len(users) == 3


def test_no_users(client, mocker):
    token = login(client, mocker)
    skip = 3
    limit = 0

    response = client.get(
        f"/users?skip={skip}&limit={limit}", headers={"Authorization": token}
    )

    users = response.json()["data"]

    assert len(users) == 0


def test_limit_exceeds_amt(client, mocker):
    rows = testing_session_local().query(models.User).count()
    token = login(client, mocker)
    skip = 0
    limit = rows+1

    response = client.get(
        f"/users?skip={skip}&limit={limit}", headers={"Authorization": token}
    )

    users = response.json()["data"]

    assert len(users) == rows

def test_negative_skip(client, mocker):
    token = login(client, mocker)
    skip = -1
    limit = 2

    response = client.get(
        f"/users?skip={skip}&limit={limit}", headers={"Authorization": token}
    )

    users = response.json()["data"]

    assert len(users) == 2
    assert users[0]["id"] == "user1"

def test_limit_equals_amt(client, mocker):
    rows = testing_session_local().query(models.User).count()
    token = login(client, mocker)
    skip = 0
    limit = rows

    response = client.get(
        f"/users?skip={skip}&limit={limit}", headers={"Authorization": token}
    )

    users = response.json()["data"]

    assert len(users) == rows

def test_amt_is_limit_plus_one(client, mocker):
    rows = testing_session_local().query(models.User).count()
    token = login(client, mocker)
    skip = 0
    limit = rows - 1

    response = client.get(
        f"/users?skip={skip}&limit={limit}", headers={"Authorization": token}
    )

    users = response.json()["data"]

    assert len(users) == rows - 1


def test_pagination_consistency(client, mocker):
    expected_id = "user4"
    token = login(client, mocker)
    skip = 3
    limit = 1

    response = client.get(
        f"/users?skip={skip}&limit={limit}", headers={"Authorization": token}
    )

    users = response.json()["data"]

    assert len(users) == 1
    assert users[0]["id"] == expected_id

def test_wrong_datatypes(client, mocker):
    token = login(client, mocker)
    skip = "3"
    limit = 12

    response = client.get(
        f"/users?skip={skip}&limit={limit}", headers={"Authorization": token}
    )

    assert response.status_code == 422

def test_very_large_values(client, mocker):
    token = login(client, mocker)
    skip = 0
    limit = 0x100000000000000

    response = client.get(
        f"/users?skip={skip}&limit={limit}", headers={"Authorization": token}
    )

    assert response.status_code == 413

def test_no_authentication(client, mocker):
    skip = 0
    limit = 10

    response = client.get(
        f"/users?skip={skip}&limit={limit}", headers={"Authorization": "none"}
    )

    assert response.status_code == 401

   