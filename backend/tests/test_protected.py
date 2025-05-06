import os
import sys
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), '..', 'app')))
import pytest
import uuid
from fastapi.testclient import TestClient
from app.main import app
from app.routes.auth import get_db
from app.database import TestingSessionLocal


@pytest.fixture(scope="module")
def client():
    def override_get_db():
        db = TestingSessionLocal()
        try:
            yield db
        finally:
            db.close()

    app.dependency_overrides[get_db] = override_get_db
    yield TestClient(app)


def register_and_login(client):
    username = f"user_{uuid.uuid4().hex[:6]}"
    email = f"{username}@example.com"

    reg = client.post("/auth/register", json={
        "username": username,
        "email": email,
        "phone": "1234567890",
        "password": "testpass"
    })

    response = client.post("/auth/login", data={
    "username": username,
    "password": "testpass"
    })  

    token = response.json()["access_token"]
    return {"Authorization": f"Bearer {token}"}



def test_protected_route_requires_auth(client):
    response = client.get("/talks/")
    assert response.status_code == 401
    assert response.json()["detail"] == "Not authenticated"


def test_get_talks_with_token(client):
    headers = register_and_login(client)
    response = client.get("/talks/", headers=headers)
    assert response.status_code == 200
    assert isinstance(response.json(), list)


def test_add_to_history(client):
    headers = register_and_login(client)
    response = client.post("/history/", json={
        "talk_title": "Fall Protection"
    }, headers=headers)
    assert response.status_code == 200
    assert response.json()["message"] == "Talk added to history"

def test_access_the_history(client):
    headers = register_and_login(client)
    response1 = client.post("/history/", json={
        "talk_title": "Fall Protection"
    }, headers=headers)
    assert response1.status_code == 200
    response2 = client.get("/history/", headers=headers)
    assert response2.status_code == 200
    history_items = response2.json()
    assert len(history_items) > 0
    history_id = history_items[-1]["id"]
    response3 = client.get(f"/history/{history_id}", headers=headers)
    assert response3.status_code == 200

def test_access_the_talk(client):
    headers = register_and_login(client)

    response = client.get("/talks/", headers=headers)
    assert response.status_code == 200
    talks = response.json()
    assert isinstance(talks, list)
    assert len(talks) > 0

    talk_id = talks[0]["id"]
    response2 = client.get(f"/talks/{talk_id}", headers=headers)
    assert response2.status_code == 200
    talk_data = response2.json()
    assert talk_data["id"] == talk_id
    assert "title" in talk_data
    assert "category" in talk_data

def test_talk_requires_auth(client):
    response = client.get("/talks/1")
    assert response.status_code == 401
    assert response.json()["detail"] == "Not authenticated"
    
def test_get_nonexistent_talk(client):
    headers = register_and_login(client)
    response = client.get("/talks/9999", headers=headers)
    assert response.status_code == 404
    assert response.json()["detail"] == "Talk not found"
