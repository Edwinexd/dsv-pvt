from fastapi.testclient import TestClient
import pytest
from main import app

client = TestClient(app)

def test_test():
    response = client.get("/")
    assert response.status_code == 200
