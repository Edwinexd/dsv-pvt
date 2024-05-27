"""
Tests for profile endpoints in main.py
"""

import os

import pytest
from fastapi.testclient import TestClient
from test_main_users import PayloadGenerator
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from database import base
from main import app, get_db_session

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

client = TestClient(app)
payload_generator = PayloadGenerator()


@pytest.fixture(scope="session", autouse=True)
def generate_users(session_mocker):
    """
    Generate users for profile tests
    """
    for i in range(0, 100):
        user_payload = payload_generator.generate_user_payload()
        mock_user_id = payload_generator.generate_mock_id()
        session_mocker.patch("main.auth.create_user", return_value=mock_user_id)
        client.post("/users", json=user_payload)
    yield
    os.remove("tester.db")


CURRENT_USER_ID = "user1"
CURRENT_USER_EMAIL = "test1@example.com"
CURRENT_USER_PW = "password"


# TODO: this is a better solution for auth, implement it in user tests too.
@pytest.fixture(scope="session", autouse=True)
def login(
    session_mocker,
    email=CURRENT_USER_EMAIL,
    pw=CURRENT_USER_PW,
    user_id=CURRENT_USER_ID,
):
    """
    Logs in to mock client once per test session and gets access token.
    """
    session_mocker.patch("main.auth.login", return_value=user_id)
    response = client.post(
        "/users/login",
        json={
            "email": email,
            "password": pw,
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
    response = client.put(
        f"/users/{CURRENT_USER_ID}/profile",
        json=profile_payload,
        headers={"Authorization": TOKEN},
    )

    assert response.status_code == 200


def test_nonexistent_user():
    user_id = "i_dont_exist"

    response = client.put(
        f"/users/{user_id}/profile",
        json=profile_payload,
        headers={"Authorization": TOKEN},
    )

    assert "id" not in response.json()
    assert response.status_code == 404


def test_invalid_profile_data():
    profile_payload_cpy = dict(profile_payload)
    profile_payload_cpy["is_private"] = None

    response = client.put(
        f"/users/{CURRENT_USER_ID}/profile",
        json=profile_payload_cpy,
        headers={"Authorization": TOKEN},
    )

    assert "id" not in response.json()
    assert response.status_code == 422


def test_nonexistent_data():
    profile_payload = {"location": "string"}

    response = client.put(
        f"/users/{CURRENT_USER_ID}/profile",
        json=profile_payload,
        headers={"Authorization": TOKEN},
    )

    assert "id" not in response.json()
    assert response.status_code == 422


def test_already_existing_profile():
    # Check that the profile exists
    response1 = client.get(
        f"/users/{CURRENT_USER_ID}/profile", headers={"Authorization": TOKEN}
    )
    assert response1.status_code == 200

    # Try to create a new profile
    response = client.put(
        f"/users/{CURRENT_USER_ID}/profile",
        json=profile_payload,
        headers={"Authorization": TOKEN},
    )

    assert (
        response.status_code == 200
    )  # Should not conflict, should just overwrite profile because PUT


# PROFILE UPDATES
update_data = {
    "runner_id": "testupdate",
    "age": 32,
}


def test_update_success():
    # make the update
    response = client.patch(
        f"/users/{CURRENT_USER_ID}/profile",
        json=update_data,
        headers={"Authorization": TOKEN},
    )
    assert response.status_code == 200

    # get the profile
    response1 = client.get(
        f"/users/{CURRENT_USER_ID}/profile", headers={"Authorization": TOKEN}
    )
    assert update_data["runner_id"] == response1.json()["runner_id"]


def test_update_invalid_user_permissions(mocker):
    # Log in to a different user
    mocker.patch("main.auth.login", return_value="user2")
    response = client.post(
        "/users/login",
        json={
            "email": "test2@example.com",
            "password": "password",
        },
    )
    token_local = response.json()["bearer"]

    response = client.patch(
        f"/users/{CURRENT_USER_ID}/profile",
        json=update_data,
        headers={"Authorization": token_local},
    )
    assert response.status_code == 403


def test_no_update_unchanged():
    # get profile before update
    response_before = client.get(
        f"/users/{CURRENT_USER_ID}/profile",
        headers={"Authorization": TOKEN},
    )

    # make an update without changes
    response = client.patch(
        f"/users/{CURRENT_USER_ID}/profile",
        json={},
        headers={"Authorization": TOKEN},
    )

    # get the profile after
    response_after = client.get(
        f"/users/{CURRENT_USER_ID}/profile",
        headers={"Authorization": TOKEN},
    )

    # validate no changes
    assert response_before.json() == response_after.json()
    assert response.status_code == 200


def test_update_invalid_data():
    update_data_invalid = {
        "age": "311",
        "description": 311,
    }

    # get profile before update
    response_before = client.get(
        f"/users/{CURRENT_USER_ID}/profile",
        headers={"Authorization": TOKEN},
    )

    # make an update with invalid fields
    response = client.patch(
        f"/users/{CURRENT_USER_ID}/profile",
        json=update_data_invalid,
        headers={"Authorization": TOKEN},
    )

    # get the profile after
    response_after = client.get(
        f"/users/{CURRENT_USER_ID}/profile",
        headers={"Authorization": TOKEN},
    )

    # assert no change was made
    assert response_before.json() == response_after.json()

    # check appropriate error was given from patch
    assert response.status_code == 422


# check if the endpoint is vurnerable to very elementary sql injection
def test_sql_injection():
    update_data_sql_inject = {"description": "DROP TABLE profiles;"}

    # make an update trying to drop profile table
    client.patch(
        f"/users/{CURRENT_USER_ID}/profile",
        json=update_data_sql_inject,
        headers={"Authorization": TOKEN},
    )

    # get the profile after
    response_after = client.get(
        f"/users/{CURRENT_USER_ID}/profile",
        headers={"Authorization": TOKEN},
    )

    # profile check that the profile is still in db
    assert response_after.json() is not None
    assert response_after.json()["description"] == update_data_sql_inject["description"]


# TODO: Maximum Field Lengths
# TODO: Special Characters
# TODO: Duplicate Values: If applicable, simulate trying to update a unique field (like email) to a value already in use, checking for proper error propagation.
# TODO: Admin User: If there's a special role like 'admin', test if they can update any user's profile as expected.
