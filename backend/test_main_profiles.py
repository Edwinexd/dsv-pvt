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
from test_main_users import PayloadGenerator, override_get_db_session

SQLALCHEMY_DB_URL = "sqlite:///:memory:"
engine = create_engine(SQLALCHEMY_DB_URL)
testing_session_local = sessionmaker(
    autocommit=False, autoflush=False, bind=engine)

base.metadata.create_all(bind=engine)

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
        session_mocker.patch("main.auth.create_user", return_value=mock_user_id)
        response = client.post("/users", json=user_payload)

# TODO: this is a better solution for auth, implement it in user tests too.
@pytest.fixture(scope="session", autouse=True)
def login(session_mocker):
    """
    Logs in to mock client once per test session and gets access token.
    """
    session_mocker.patch("main.auth.login", return_value="user1")
    response = client.post(
        "/users/login", json={"email": "test1@example.com", "password": "password", })
    global TOKEN
    TOKEN = response.json()["bearer"]


def test_test(mocker):
    print(TOKEN)
    assert TOKEN == "hej"
