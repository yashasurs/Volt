"""
Tests for goal endpoints
"""
import pytest
from fastapi import status
from datetime import datetime, timedelta
from decimal import Decimal


@pytest.fixture
def sample_goal_data(test_user):
    """Sample goal data for testing"""
    return {
        "title": "Vacation Fund",
        "description": "Save for summer vacation",
        "target_amount": 5000.00,
        "end_date": (datetime.utcnow() + timedelta(days=180)).isoformat()
    }


@pytest.fixture
def created_goal(client, auth_headers, sample_goal_data):
    """Create a goal for testing"""
    response = client.post(
        "/goals/",
        json=sample_goal_data,
        headers=auth_headers
    )
    return response.json()


class TestCreateGoal:
    """Test goal creation endpoint"""
    
    def test_create_goal_success(self, client, auth_headers, test_user):
        """Test creating a new goal"""
        goal_data = {
            "title": "Emergency Fund",
            "description": "Build emergency savings",
            "target_amount": 10000.00,
            "end_date": (datetime.utcnow() + timedelta(days=365)).isoformat()
        }
        
        response = client.post(
            "/goals/",
            json=goal_data,
            headers=auth_headers
        )
        
        assert response.status_code == status.HTTP_201_CREATED
        data = response.json()
        assert data["title"] == "Emergency Fund"
        assert data["description"] == "Build emergency savings"
        assert data["target_amount"] == "10000.00"
        assert data["current_amount"] == "0.00"
        assert data["is_active"] == True
        assert data["is_achieved"] == False
        assert data["user_id"] == test_user.id
        assert "id" in data
        assert "created_at" in data
    
    def test_create_goal_minimal_data(self, client, auth_headers):
        """Test creating goal with minimal required data"""
        goal_data = {
            "title": "Short Term Goal",
            "target_amount": 1000.00,
            "end_date": (datetime.utcnow() + timedelta(days=90)).isoformat()
        }
        
        response = client.post(
            "/goals/",
            json=goal_data,
            headers=auth_headers
        )
        
        assert response.status_code == status.HTTP_201_CREATED
        data = response.json()
        assert data["title"] == "Short Term Goal"
        assert data["current_amount"] == "0.00"
    
    def test_create_goal_negative_amount(self, client, auth_headers):
        """Test creating goal with negative target amount"""
        goal_data = {
            "title": "Invalid Goal",
            "target_amount": -1000.00,
            "end_date": (datetime.utcnow() + timedelta(days=90)).isoformat()
        }
        
        response = client.post(
            "/goals/",
            json=goal_data,
            headers=auth_headers
        )
        
        assert response.status_code == status.HTTP_422_UNPROCESSABLE_ENTITY
    
    def test_create_goal_unauthenticated(self, client, sample_goal_data):
        """Test creating goal without authentication"""
        response = client.post("/goals/", json=sample_goal_data)
        
        assert response.status_code == status.HTTP_401_UNAUTHORIZED


class TestGetGoals:
    """Test getting goals"""
    
    def test_get_all_goals(self, client, auth_headers, created_goal):
        """Test getting all goals for current user"""
        response = client.get("/goals/", headers=auth_headers)
        
        assert response.status_code == status.HTTP_200_OK
        data = response.json()
        assert isinstance(data, list)
        assert len(data) >= 1
        assert any(goal["id"] == created_goal["id"] for goal in data)
    
    def test_get_active_goals_only(self, client, auth_headers, created_goal):
        """Test getting only active goals"""
        # Deactivate the created goal first
        client.post(
            f"/goals/{created_goal['id']}/deactivate",
            headers=auth_headers
        )
        
        # Create an active goal
        active_goal_data = {
            "title": "Active Goal",
            "target_amount": 1000.00,
            "end_date": (datetime.utcnow() + timedelta(days=60)).isoformat()
        }
        client.post("/goals/", json=active_goal_data, headers=auth_headers)
        
        response = client.get("/goals/?active_only=true", headers=auth_headers)
        
        assert response.status_code == status.HTTP_200_OK
        data = response.json()
        assert all(goal["is_active"] for goal in data)
    
    def test_get_goals_unauthenticated(self, client):
        """Test getting goals without authentication"""
        response = client.get("/goals/")
        
        assert response.status_code == status.HTTP_401_UNAUTHORIZED


class TestGetGoalsWithProgress:
    """Test getting goals with progress metrics"""
    
    def test_get_goals_with_progress(self, client, auth_headers, created_goal):
        """Test getting goals with calculated progress"""
        response = client.get("/goals/progress", headers=auth_headers)
        
        assert response.status_code == status.HTTP_200_OK
        data = response.json()
        assert isinstance(data, list)
        assert len(data) >= 1
        
        goal_progress = next(g for g in data if g["id"] == created_goal["id"])
        assert "progress_percentage" in goal_progress
        assert "days_remaining" in goal_progress
        assert "is_overdue" in goal_progress
        assert "total_contributions" in goal_progress
        assert goal_progress["progress_percentage"] >= 0
        assert goal_progress["progress_percentage"] <= 100


class TestGetSingleGoal:
    """Test getting a single goal with details"""
    
    def test_get_goal_by_id(self, client, auth_headers, created_goal):
        """Test getting specific goal with detailed information"""
        response = client.get(
            f"/goals/{created_goal['id']}",
            headers=auth_headers
        )
        
        assert response.status_code == status.HTTP_200_OK
        data = response.json()
        assert data["id"] == created_goal["id"]
        assert data["title"] == created_goal["title"]
        assert "contributions" in data
        assert "progress_percentage" in data
        assert "days_remaining" in data
        assert "is_overdue" in data
    
    def test_get_nonexistent_goal(self, client, auth_headers):
        """Test getting non-existent goal"""
        response = client.get("/goals/99999", headers=auth_headers)
        
        assert response.status_code == status.HTTP_404_NOT_FOUND
    
    def test_get_other_user_goal(self, client, auth_headers, second_user, db_session):
        """Test getting another user's goal"""
        from app.models.goal import Goal
        
        # Create a goal for second user
        other_goal = Goal(
            user_id=second_user.id,
            title="Other User Goal",
            target_amount=1000.00,
            end_date=datetime.utcnow() + timedelta(days=30)
        )
        db_session.add(other_goal)
        db_session.commit()
        db_session.refresh(other_goal)
        
        # Try to access with first user's token
        response = client.get(
            f"/goals/{other_goal.id}",
            headers=auth_headers
        )
        
        assert response.status_code == status.HTTP_404_NOT_FOUND


class TestUpdateGoal:
    """Test updating goals"""
    
    def test_update_goal_title(self, client, auth_headers, created_goal):
        """Test updating goal title"""
        response = client.put(
            f"/goals/{created_goal['id']}",
            json={"title": "Updated Vacation Fund"},
            headers=auth_headers
        )
        
        assert response.status_code == status.HTTP_200_OK
        data = response.json()
        assert data["title"] == "Updated Vacation Fund"
        assert data["target_amount"] == created_goal["target_amount"]
    
    def test_update_goal_target_amount(self, client, auth_headers, created_goal):
        """Test updating goal target amount"""
        response = client.put(
            f"/goals/{created_goal['id']}",
            json={"target_amount": 7500.00},
            headers=auth_headers
        )
        
        assert response.status_code == status.HTTP_200_OK
        data = response.json()
        assert data["target_amount"] == "7500.00"
    
    def test_update_goal_status(self, client, auth_headers, created_goal):
        """Test updating goal status"""
        response = client.put(
            f"/goals/{created_goal['id']}",
            json={
                "is_active": False
            },
            headers=auth_headers
        )
        
        assert response.status_code == status.HTTP_200_OK
        data = response.json()
        assert data["is_active"] == False
    
    def test_update_nonexistent_goal(self, client, auth_headers):
        """Test updating a goal that doesn't exist"""
        response = client.put(
            "/goals/99999",
            json={"title": "Updated"},
            headers=auth_headers
        )
        
        assert response.status_code == status.HTTP_404_NOT_FOUND


class TestDeleteGoal:
    """Test deleting goals"""
    
    def test_delete_goal(self, client, auth_headers, created_goal):
        """Test deleting a goal"""
        response = client.delete(
            f"/goals/{created_goal['id']}",
            headers=auth_headers
        )
        
        assert response.status_code == status.HTTP_204_NO_CONTENT
        
        # Verify goal is deleted
        get_response = client.get(
            f"/goals/{created_goal['id']}",
            headers=auth_headers
        )
        assert get_response.status_code == status.HTTP_404_NOT_FOUND
    
    def test_delete_nonexistent_goal(self, client, auth_headers):
        """Test deleting non-existent goal"""
        response = client.delete("/goals/99999", headers=auth_headers)
        
        assert response.status_code == status.HTTP_404_NOT_FOUND


class TestActivateDeactivateGoal:
    """Test goal activation and deactivation"""
    
    def test_activate_goal(self, client, auth_headers, created_goal, db_session):
        """Test activating a goal"""
        # First deactivate it
        client.post(
            f"/goals/{created_goal['id']}/deactivate",
            headers=auth_headers
        )
        
        # Now activate it
        response = client.post(
            f"/goals/{created_goal['id']}/activate",
            headers=auth_headers
        )
        
        assert response.status_code == status.HTTP_200_OK
        data = response.json()
        assert data["is_active"] == True
    
    def test_deactivate_goal(self, client, auth_headers, created_goal):
        """Test deactivating a goal"""
        response = client.post(
            f"/goals/{created_goal['id']}/deactivate",
            headers=auth_headers
        )
        
        assert response.status_code == status.HTTP_200_OK
        data = response.json()
        assert data["is_active"] == False
    
    def test_activate_nonexistent_goal(self, client, auth_headers):
        """Test activating non-existent goal"""
        response = client.post("/goals/99999/activate", headers=auth_headers)
        
        assert response.status_code == status.HTTP_404_NOT_FOUND


class TestGoalContributions:
    """Test goal contributions"""
    
    def test_get_goal_contributions(self, client, auth_headers, created_goal, test_user):
        """Test getting contributions for a goal"""
        # Create a transaction that should contribute to the goal
        client.post(
            "/transactions/",
            json={
                "user_id": test_user.id,
                "amount": 100.00,
                "merchant": "Test",
                "type": "debit"
            },
            headers=auth_headers
        )
        
        response = client.get(
            f"/goals/{created_goal['id']}/contributions",
            headers=auth_headers
        )
        
        assert response.status_code == status.HTTP_200_OK
        data = response.json()
        assert isinstance(data, list)


class TestGoalIntegrationWithTransactions:
    """Test goal behavior with transaction creation"""
class TestGoalIntegrationWithTransactions:
    """Test goal behavior with transaction creation"""
    
    def test_credit_transaction_increases_goal(self, client, auth_headers, created_goal, test_user, db_session):
        """Test that credit transactions increase goal amount"""
        # Get initial goal amount
        initial_response = client.get(
            f"/goals/{created_goal['id']}",
            headers=auth_headers
        )
        initial_amount = Decimal(initial_response.json()["current_amount"])
        
        # Create a credit transaction
        transaction_amount = 500.00
        
        client.post(
            "/transactions/",
            json={
                "user_id": test_user.id,
                "amount": transaction_amount,
                "merchant": "Salary",
                "type": "credit"
            },
            headers=auth_headers
        )
        
        # Check goal increased
        goal_response = client.get(
            f"/goals/{created_goal['id']}",
            headers=auth_headers
        )
        
        goal_data = goal_response.json()
        new_amount = Decimal(goal_data["current_amount"])
        assert new_amount == initial_amount + Decimal(str(transaction_amount))
        assert len(goal_data["contributions"]) > 0
    
    def test_debit_transaction_decreases_goal(self, client, auth_headers, created_goal, test_user):
        """Test that debit transactions decrease goal amount"""
        # First add some credits to have positive balance
        client.post(
            "/transactions/",
            json={
                "user_id": test_user.id,
                "amount": 1000.00,
                "merchant": "Income",
                "type": "credit"
            },
            headers=auth_headers
        )
        
        # Get amount after credit
        response1 = client.get(
            f"/goals/{created_goal['id']}",
            headers=auth_headers
        )
        amount_after_credit = Decimal(response1.json()["current_amount"])
        
        # Create a debit transaction
        debit_amount = 100.00
        client.post(
            "/transactions/",
            json={
                "user_id": test_user.id,
                "amount": debit_amount,
                "merchant": "Store",
                "type": "debit"
            },
            headers=auth_headers
        )
        
        # Check goal decreased
        goal_response = client.get(
            f"/goals/{created_goal['id']}",
            headers=auth_headers
        )
        
        goal_data = goal_response.json()
        new_amount = Decimal(goal_data["current_amount"])
        assert new_amount == amount_after_credit - Decimal(str(debit_amount))
    
    def test_inactive_goal_no_contributions(self, client, auth_headers, created_goal, test_user):
        """Test that inactive goals don't receive contributions"""
        # Deactivate the goal
        client.post(
            f"/goals/{created_goal['id']}/deactivate",
            headers=auth_headers
        )
        
        # Get initial contribution count
        initial_response = client.get(
            f"/goals/{created_goal['id']}",
            headers=auth_headers
        )
        initial_contributions = len(initial_response.json()["contributions"])
        initial_amount = Decimal(initial_response.json()["current_amount"])
        
        # Create a transaction
        client.post(
            "/transactions/",
            json={
                "user_id": test_user.id,
                "amount": 100.00,
                "merchant": "Store",
                "type": "credit"
            },
            headers=auth_headers
        )
        
        # Check that no new contributions were made
        final_response = client.get(
            f"/goals/{created_goal['id']}",
            headers=auth_headers
        )
        final_contributions = len(final_response.json()["contributions"])
        final_amount = Decimal(final_response.json()["current_amount"])
        
        assert final_contributions == initial_contributions
        assert final_amount == initial_amount