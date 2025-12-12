"""
Tests for email configuration endpoints
"""
import pytest
from fastapi import status


class TestSetupAppPassword:
    """Test email app password setup endpoint"""
    
    def test_setup_app_password_success(self, client, auth_headers, test_user, db_session):
        """Test successful app password setup"""
        response = client.post(
            "/email-config/setup-app-password",
            json={
                "app_password": "abcd efgh ijkl mnop",
                "consent": True
            },
            headers=auth_headers
        )
        
        assert response.status_code == status.HTTP_200_OK
        data = response.json()
        assert data["status"] == "success"
        assert data["email_parsing_enabled"] == True
        assert "enabled" in data["message"].lower()
        
        # Verify user record updated
        db_session.refresh(test_user)
        assert test_user.email_parsing_enabled == True
        assert test_user.email_app_password is not None
    
    def test_setup_app_password_without_consent(self, client, auth_headers):
        """Test setup without user consent"""
        response = client.post(
            "/email-config/setup-app-password",
            json={
                "app_password": "abcd efgh ijkl mnop",
                "consent": False
            },
            headers=auth_headers
        )
        
        assert response.status_code == status.HTTP_400_BAD_REQUEST
        assert "consent" in response.json()["detail"].lower()
    
    def test_setup_invalid_app_password_format(self, client, auth_headers):
        """Test setup with invalid app password format"""
        response = client.post(
            "/email-config/setup-app-password",
            json={
                "app_password": "short",
                "consent": True
            },
            headers=auth_headers
        )
        
        assert response.status_code == status.HTTP_400_BAD_REQUEST
        assert "invalid" in response.json()["detail"].lower()
    
    def test_setup_app_password_unauthenticated(self, client):
        """Test setup without authentication"""
        response = client.post(
            "/email-config/setup-app-password",
            json={
                "app_password": "abcd efgh ijkl mnop",
                "consent": True
            }
        )
        
        assert response.status_code == status.HTTP_401_UNAUTHORIZED


class TestGetEmailParsingStatus:
    """Test email parsing status endpoint"""
    
    def test_get_status_not_configured(self, client, auth_headers, test_user):
        """Test getting status when email parsing is not configured"""
        response = client.get(
            "/email-config/status",
            headers=auth_headers
        )
        
        assert response.status_code == status.HTTP_200_OK
        data = response.json()
        assert data["email_parsing_enabled"] == False
        assert data["has_app_password"] == False
        assert "disabled" in data["message"].lower()
    
    def test_get_status_configured(self, client, auth_headers, test_user, db_session):
        """Test getting status when email parsing is configured"""
        # Setup email parsing first
        client.post(
            "/email-config/setup-app-password",
            json={
                "app_password": "abcd efgh ijkl mnop",
                "consent": True
            },
            headers=auth_headers
        )
        
        response = client.get(
            "/email-config/status",
            headers=auth_headers
        )
        
        assert response.status_code == status.HTTP_200_OK
        data = response.json()
        assert data["email_parsing_enabled"] == True
        assert data["has_app_password"] == True
        assert data["email_address"] == test_user.email
        assert "active" in data["message"].lower()
    
    def test_get_status_unauthenticated(self, client):
        """Test getting status without authentication"""
        response = client.get("/email-config/status")
        
        assert response.status_code == status.HTTP_401_UNAUTHORIZED


class TestDisableEmailParsing:
    """Test email parsing disable endpoint"""
    
    def test_disable_email_parsing_success(self, client, auth_headers, test_user, db_session):
        """Test successfully disabling email parsing"""
        # Setup email parsing first
        client.post(
            "/email-config/setup-app-password",
            json={
                "app_password": "abcd efgh ijkl mnop",
                "consent": True
            },
            headers=auth_headers
        )
        
        # Now disable it
        response = client.post(
            "/email-config/disable",
            json={"confirm": True},
            headers=auth_headers
        )
        
        assert response.status_code == status.HTTP_200_OK
        data = response.json()
        assert data["status"] == "success"
        assert data["email_parsing_enabled"] == False
        assert "disabled" in data["message"].lower()
        
        # Verify user record updated
        db_session.refresh(test_user)
        assert test_user.email_parsing_enabled == False
        assert test_user.email_app_password is None
    
    def test_disable_without_confirmation(self, client, auth_headers):
        """Test disable without confirmation"""
        response = client.post(
            "/email-config/disable",
            json={"confirm": False},
            headers=auth_headers
        )
        
        assert response.status_code == status.HTTP_400_BAD_REQUEST
        assert "confirmation" in response.json()["detail"].lower()
    
    def test_disable_unauthenticated(self, client):
        """Test disable without authentication"""
        response = client.post(
            "/email-config/disable",
            json={"confirm": True}
        )
        
        assert response.status_code == status.HTTP_401_UNAUTHORIZED


class TestUpdateAppPassword:
    """Test updating app password endpoint"""
    
    def test_update_app_password(self, client, auth_headers, test_user, db_session):
        """Test updating existing app password"""
        # Setup initial password
        client.post(
            "/email-config/setup-app-password",
            json={
                "app_password": "abcd efgh ijkl mnop",
                "consent": True
            },
            headers=auth_headers
        )
        
        initial_password = test_user.email_app_password
        
        # Update to new password
        response = client.post(
            "/email-config/update-app-password",
            json={
                "app_password": "wxyz abcd efgh ijkl",
                "consent": True
            },
            headers=auth_headers
        )
        
        assert response.status_code == status.HTTP_200_OK
        data = response.json()
        assert data["status"] == "success"
        assert data["email_parsing_enabled"] == True
        
        # Verify password was updated
        db_session.refresh(test_user)
        assert test_user.email_app_password != initial_password
        assert test_user.email_app_password is not None


class TestEmailConfigWorkflow:
    """Test complete email configuration workflow"""
    
    def test_complete_workflow(self, client, auth_headers, test_user, db_session):
        """Test setup -> check status -> update -> disable workflow"""
        # 1. Check initial status
        status_response = client.get("/email-config/status", headers=auth_headers)
        assert status_response.json()["email_parsing_enabled"] == False
        
        # 2. Setup app password
        setup_response = client.post(
            "/email-config/setup-app-password",
            json={
                "app_password": "abcd efgh ijkl mnop",
                "consent": True
            },
            headers=auth_headers
        )
        assert setup_response.status_code == status.HTTP_200_OK
        
        # 3. Verify status changed
        status_response = client.get("/email-config/status", headers=auth_headers)
        assert status_response.json()["email_parsing_enabled"] == True
        
        # 4. Update password
        update_response = client.post(
            "/email-config/update-app-password",
            json={
                "app_password": "wxyz abcd efgh ijkl",
                "consent": True
            },
            headers=auth_headers
        )
        assert update_response.status_code == status.HTTP_200_OK
        
        # 5. Disable email parsing
        disable_response = client.post(
            "/email-config/disable",
            json={"confirm": True},
            headers=auth_headers
        )
        assert disable_response.status_code == status.HTTP_200_OK
        
        # 6. Verify disabled
        final_status = client.get("/email-config/status", headers=auth_headers)
        assert final_status.json()["email_parsing_enabled"] == False
