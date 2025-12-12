"""
Tests for authentication endpoints
"""
import pytest
from fastapi import status


class TestUserRegistration:
    """Test user registration endpoint"""
    
    def test_register_new_user(self, client):
        """Test successful user registration"""
        response = client.post(
            "/auth/register",
            json={
                "name": "New User",
                "email": "newuser@example.com",
                "phone_number": "5555555555",
                "password": "password123"
            }
        )
        
        assert response.status_code == status.HTTP_201_CREATED
        data = response.json()
        assert data["name"] == "New User"
        assert data["email"] == "newuser@example.com"
        assert data["phone_number"] == "5555555555"
        assert "id" in data
        assert "password" not in data
        assert "hashed_password" not in data
        assert data["savings"] == "0.00"
    
    def test_register_duplicate_email(self, client, test_user):
        """Test registration with existing email"""
        response = client.post(
            "/auth/register",
            json={
                "name": "Another User",
                "email": test_user.email,
                "phone_number": "9999999999",
                "password": "password123"
            }
        )
        
        assert response.status_code == status.HTTP_400_BAD_REQUEST
        assert "already registered" in response.json()["detail"].lower()
    
    def test_register_invalid_email(self, client):
        """Test registration with invalid email"""
        response = client.post(
            "/auth/register",
            json={
                "name": "Bad Email",
                "email": "not-an-email",
                "phone_number": "5555555555",
                "password": "password123"
            }
        )
        
        assert response.status_code == status.HTTP_422_UNPROCESSABLE_ENTITY
    
    def test_register_short_password(self, client):
        """Test registration with password too short"""
        response = client.post(
            "/auth/register",
            json={
                "name": "Short Pass",
                "email": "short@example.com",
                "phone_number": "5555555555",
                "password": "pass"
            }
        )
        
        assert response.status_code == status.HTTP_422_UNPROCESSABLE_ENTITY


class TestUserLogin:
    """Test user login endpoints"""
    
    def test_login_with_form_data(self, client, test_user):
        """Test login with OAuth2 form data"""
        response = client.post(
            "/auth/login",
            data={
                "username": test_user.email,
                "password": "testpass123"
            }
        )
        
        assert response.status_code == status.HTTP_200_OK
        data = response.json()
        assert "access_token" in data
        assert data["token_type"] == "bearer"
    
    def test_login_with_json(self, client, test_user):
        """Test login with JSON body"""
        response = client.post(
            "/auth/login/json",
            json={
                "email": test_user.email,
                "password": "testpass123"
            }
        )
        
        assert response.status_code == status.HTTP_200_OK
        data = response.json()
        assert "access_token" in data
        assert data["token_type"] == "bearer"
    
    def test_login_wrong_password(self, client, test_user):
        """Test login with incorrect password"""
        response = client.post(
            "/auth/login",
            data={
                "username": test_user.email,
                "password": "wrongpassword"
            }
        )
        
        assert response.status_code == status.HTTP_401_UNAUTHORIZED
    
    def test_login_nonexistent_user(self, client):
        """Test login with non-existent email"""
        response = client.post(
            "/auth/login",
            data={
                "username": "nonexistent@example.com",
                "password": "somepassword"
            }
        )
        
        assert response.status_code == status.HTTP_401_UNAUTHORIZED


class TestGetCurrentUser:
    """Test getting current user information"""
    
    def test_get_me_authenticated(self, client, test_user, auth_headers):
        """Test getting current user info with valid token"""
        response = client.get("/auth/me", headers=auth_headers)
        
        assert response.status_code == status.HTTP_200_OK
        data = response.json()
        assert data["id"] == test_user.id
        assert data["email"] == test_user.email
        assert data["name"] == test_user.name
        assert data["phone_number"] == test_user.phone_number
        assert data["savings"] == "1000.00"
    
    def test_get_me_unauthenticated(self, client):
        """Test getting current user without authentication"""
        response = client.get("/auth/me")
        
        assert response.status_code == status.HTTP_401_UNAUTHORIZED
    
    def test_get_me_invalid_token(self, client):
        """Test getting current user with invalid token"""
        response = client.get(
            "/auth/me",
            headers={"Authorization": "Bearer invalidtoken"}
        )
        
        assert response.status_code == status.HTTP_401_UNAUTHORIZED
