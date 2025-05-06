import uuid

def test_register_user(client):
    username = f"user_{uuid.uuid4().hex[:6]}"
    response = client.post("/auth/register", json={
        "username": username,
        "email": f"{username}@example.com",
        "phone": "1234567890",
        "password": "testpass"
    })
    assert response.status_code == 200
    assert response.json()["username"] == username

def test_login_user(client):
    username = f"user_{uuid.uuid4().hex[:6]}"
    client.post("/auth/register", json={
        "username": username,
        "email": f"{username}@example.com",
        "phone": "1234567890",
        "password": "testpass"
    })

    response = client.post("/auth/login", data={
        "username": username,
        "password": "testpass"
    })

    assert response.status_code == 200
    assert "access_token" in response.json()

def test_same_user_return_errors(client):
    username = f"user_{uuid.uuid4().hex[:6]}"
    response1 = client.post("/auth/register", json={
        "username": username,
        "email": f"{username}@example.com",
        "phone": "1234567890",
        "password": "testpass"
    })
    assert response1.status_code == 200
    response2 = client.post("/auth/register", json={
        "username": username,
        "email": f"{username}@example.com",
        "phone": "1234567890",
        "password": "testpass"
    })
    assert response2.status_code == 400

def test_user_with_wrong_credentials(client):
    username = f"user_{uuid.uuid4().hex[:6]}"
    response1 = client.post("/auth/register", json={
        "username": username,
        "email": f"{username}@example.com",
        "phone": "1234567890",
        "password": "testpass"
    })
    assert response1.status_code == 200
    response2 = client.post("/auth/login", data={
        "username": username,
        "password": "testpass1"
    })
    assert response2.status_code == 403
    assert "access_token" not in response2.json()