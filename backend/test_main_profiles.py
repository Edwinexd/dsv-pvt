"""
Tests for profile endpoints in main.py
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
from sessions import revoke_sessions
from test_main_users import PayloadGenerator

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

payload_generator = PayloadGenerator()

client = TestClient(app)


@pytest.fixture(scope="session", autouse=True)
def generate_users(session_mocker):
    """
    Generate users for profile tests
    """
    for i in range(0, 100):
        user_payload = payload_generator.generate_user_payload()
        mock_user_id = payload_generator.generate_mock_id()
        print(mock_user_id)
        session_mocker.patch("main.auth.create_user", return_value=mock_user_id)
        response = client.post("/users", json=user_payload)
    yield
    os.remove("tester.db")


# TODO: this is a better solution for auth, implement it in user tests too.


@pytest.fixture(scope="session", autouse=True)
def login(session_mocker):
    """
    Logs in to mock client once per test session and gets access token.
    """
    session_mocker.patch("main.auth.login", return_value="user1")
    response = client.post(
        "/users/login",
        json={
            "email": "test1@example.com",
            "password": "password",
        },
    )
    global TOKEN
    TOKEN = response.json()["bearer"]


profile_payload = {
    "description": "string",
    "age": 99,
    "interests": "string",
    "skill_level": 2,
    "is_private": True,
    "runner_id": "1234",
    "location": "string",
}


def test_create_profile_success():
    user_id = "user1"

    response = client.put(f"/users/{user_id}/profile", json=profile_payload, headers={"Authorization": TOKEN})

    assert "id" in response.json()
    assert response.json()["id"] == user_id
    assert response.status_code == 200

def test_nonexistent_user():
    user_id = "i_dont_exist"

    response = client.put(f"/users/{user_id}/profile", json=profile_payload, headers={"Authorization": TOKEN})

    assert "id" not in response.json()
    assert response.status_code == 404

def test_invalid_profile_data():
    user_id = "user1"
    profile_payload["is_private"] = None

    response = client.put(f"/users/{user_id}/profile", json=profile_payload, headers={"Authorization": TOKEN})

    assert "id" not in response.json()
    assert response.status_code == 422

def test_nonexistent_data():
    user_id = "user1"
    profile_payload = {"location": "string"}

    response = client.put(f"/users/{user_id}/profile", json=profile_payload, headers={"Authorization": TOKEN})

    assert "id" not in response.json()
    assert response.status_code == 400

def test_already_existing_profile():
    pass
