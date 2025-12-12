"""
Test configuration for pytest.

This file ensures the 'app' package is importable in all test files.
"""
import os
import sys
import pytest
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from fastapi.testclient import TestClient

# Add the server directory to sys.path so 'app' module can be imported
SERVER_ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
if SERVER_ROOT not in sys.path:
    sys.path.insert(0, SERVER_ROOT)

from app.main import app
from app.database import Base, get_db
from app.oauth2 import get_password_hash


# Use SQLite in-memory database for testing
SQLALCHEMY_DATABASE_URL = "sqlite:///./test.db"

engine = create_engine(
    SQLALCHEMY_DATABASE_URL,
    connect_args={"check_same_thread": False}
)
TestingSessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)


@pytest.fixture(scope="function")
def db_session():
    """Create a fresh database for each test"""
    Base.metadata.create_all(bind=engine)
    db = TestingSessionLocal()
    try:
        yield db
    finally:
        db.close()
        Base.metadata.drop_all(bind=engine)


@pytest.fixture(scope="function")
def client(db_session):
    """Create a test client with database override"""
    def override_get_db():
        try:
            yield db_session
        finally:
            pass
    
    app.dependency_overrides[get_db] = override_get_db
    with TestClient(app) as test_client:
        yield test_client
    app.dependency_overrides.clear()


@pytest.fixture
def test_user(db_session):
    """Create a test user"""
    from app.models.user import User
    
    user = User(
        name="Test User",
        email="test@example.com",
        phone_number="1234567890",
        hashed_password=get_password_hash("testpass123"),
        savings=1000.00
    )
    db_session.add(user)
    db_session.commit()
    db_session.refresh(user)
    return user


@pytest.fixture
def test_user_token(client, test_user):
    """Get authentication token for test user"""
    response = client.post(
        "/auth/login",
        data={
            "username": test_user.email,
            "password": "testpass123"
        }
    )
    return response.json()["access_token"]


@pytest.fixture
def auth_headers(test_user_token):
    """Get authorization headers"""
    return {"Authorization": f"Bearer {test_user_token}"}


@pytest.fixture
def second_user(db_session):
    """Create a second test user for authorization tests"""
    from app.models.user import User
    
    user = User(
        name="Second User",
        email="second@example.com",
        phone_number="9876543210",
        hashed_password=get_password_hash("testpass456"),
        savings=500.00
    )
    db_session.add(user)
    db_session.commit()
    db_session.refresh(user)
    return user
