import os
import sys
import pytest
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from fastapi.testclient import TestClient
from app import models
from app.database import Base
from app.main import app
from app.routes.auth import get_db

sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), '..')))

# Use a fixed file-based test DB
SQLALCHEMY_TEST_DB_URL = "sqlite:///./test.db"

# Setup engine and session
engine = create_engine(SQLALCHEMY_TEST_DB_URL, connect_args={"check_same_thread": False})
TestingSessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

# Recreate DB before test session
Base.metadata.drop_all(bind=engine)
Base.metadata.create_all(bind=engine)

def seed_talks(db):
    if not db.query(models.Talk).first():
        db.add_all([
            models.Talk(title="Fall Protection", category="Hazards"),
            models.Talk(title="PPE Basics", category="Safety Equipment")
        ])
        db.commit()
@pytest.fixture(scope="module")
def client():
    db = TestingSessionLocal()
    try:
        # Clear and seed
        db.query(models.Talk).delete()
        db.commit()
        seed_talks(db)
    finally:
        db.close()

    yield TestClient(app)

