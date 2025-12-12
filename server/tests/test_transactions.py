"""
Tests for transaction endpoints
"""
import pytest
from fastapi import status
from datetime import datetime, timedelta
from decimal import Decimal


@pytest.fixture
def sample_transaction_data(test_user):
    """Sample transaction data for testing"""
    return {
        "user_id": test_user.id,
        "amount": 100.50,
        "merchant": "Test Store",
        "category": "Shopping",
        "type": "debit",
        "timestamp": datetime.utcnow().isoformat(),
        "bankName": "Test Bank",
        "transactionId": "TXN123456"
    }


@pytest.fixture
def created_transaction(client, auth_headers, sample_transaction_data):
    """Create a transaction for testing"""
    response = client.post(
        "/transactions/",
        json=sample_transaction_data,
        headers=auth_headers
    )
    return response.json()


class TestCreateTransaction:
    """Test transaction creation endpoint"""
    
    def test_create_debit_transaction(self, client, auth_headers, test_user, db_session):
        """Test creating a debit transaction and verify savings update"""
        initial_savings = test_user.savings
        
        response = client.post(
            "/transactions/",
            json={
                "user_id": test_user.id,
                "amount": 50.00,
                "merchant": "Coffee Shop",
                "type": "debit",
                "timestamp": datetime.utcnow().isoformat()
            },
            headers=auth_headers
        )
        
        assert response.status_code == status.HTTP_201_CREATED
        data = response.json()
        assert data["amount"] == "50.00"
        assert data["merchant"] == "Coffee Shop"
        assert data["type"] == "debit"
        assert "id" in data
        assert "created_at" in data
        
        # Verify savings decreased
        db_session.refresh(test_user)
        assert test_user.savings == initial_savings - Decimal("50.00")
    
    def test_create_credit_transaction(self, client, auth_headers, test_user, db_session):
        """Test creating a credit transaction and verify savings update"""
        initial_savings = test_user.savings
        
        response = client.post(
            "/transactions/",
            json={
                "user_id": test_user.id,
                "amount": 200.00,
                "merchant": "Salary",
                "type": "credit",
                "timestamp": datetime.utcnow().isoformat()
            },
            headers=auth_headers
        )
        
        assert response.status_code == status.HTTP_201_CREATED
        data = response.json()
        assert data["amount"] == "200.00"
        assert data["type"] == "credit"
        
        # Verify savings increased
        db_session.refresh(test_user)
        assert test_user.savings == initial_savings + Decimal("200.00")
    
    def test_create_transaction_unauthorized(self, client, auth_headers, second_user):
        """Test creating transaction for another user"""
        response = client.post(
            "/transactions/",
            json={
                "user_id": second_user.id,
                "amount": 50.00,
                "merchant": "Test",
                "type": "debit"
            },
            headers=auth_headers
        )
        
        assert response.status_code == status.HTTP_403_FORBIDDEN
    
    def test_create_transaction_invalid_amount(self, client, auth_headers, test_user):
        """Test creating transaction with invalid amount"""
        response = client.post(
            "/transactions/",
            json={
                "user_id": test_user.id,
                "amount": -50.00,
                "merchant": "Test",
                "type": "debit"
            },
            headers=auth_headers
        )
        
        assert response.status_code == status.HTTP_422_UNPROCESSABLE_ENTITY
    
    def test_create_transaction_missing_required_fields(self, client, auth_headers, test_user):
        """Test creating transaction without required fields"""
        response = client.post(
            "/transactions/",
            json={
                "user_id": test_user.id,
                "amount": 50.00
                # Missing 'type' field
            },
            headers=auth_headers
        )
        
        assert response.status_code == status.HTTP_422_UNPROCESSABLE_ENTITY


class TestBulkCreateTransactions:
    """Test bulk transaction creation"""
    
    def test_create_multiple_transactions(self, client, auth_headers, test_user, db_session):
        """Test creating multiple transactions at once"""
        initial_savings = test_user.savings
        
        transactions = [
            {
                "user_id": test_user.id,
                "amount": 30.00,
                "merchant": "Store 1",
                "type": "debit"
            },
            {
                "user_id": test_user.id,
                "amount": 100.00,
                "merchant": "Income",
                "type": "credit"
            },
            {
                "user_id": test_user.id,
                "amount": 20.00,
                "merchant": "Store 2",
                "type": "debit"
            }
        ]
        
        response = client.post(
            "/transactions/bulk",
            json=transactions,
            headers=auth_headers
        )
        
        assert response.status_code == status.HTTP_201_CREATED
        data = response.json()
        assert len(data) == 3
        
        # Verify savings: -30 + 100 - 20 = +50
        db_session.refresh(test_user)
        expected_savings = initial_savings + Decimal("50.00")
        assert test_user.savings == expected_savings
    
    def test_bulk_create_unauthorized_user(self, client, auth_headers, test_user, second_user):
        """Test bulk create with unauthorized user ID"""
        transactions = [
            {
                "user_id": second_user.id,
                "amount": 30.00,
                "merchant": "Store",
                "type": "debit"
            }
        ]
        
        response = client.post(
            "/transactions/bulk",
            json=transactions,
            headers=auth_headers
        )
        
        assert response.status_code == status.HTTP_403_FORBIDDEN


class TestGetTransactions:
    """Test getting transactions"""
    
    def test_get_all_transactions(self, client, auth_headers, created_transaction):
        """Test getting all transactions for current user"""
        response = client.get("/transactions/", headers=auth_headers)
        
        assert response.status_code == status.HTTP_200_OK
        data = response.json()
        assert isinstance(data, list)
        assert len(data) >= 1
        assert data[0]["id"] == created_transaction["id"]
    
    def test_get_transactions_with_pagination(self, client, auth_headers, test_user):
        """Test transaction pagination"""
        # Create multiple transactions
        for i in range(5):
            client.post(
                "/transactions/",
                json={
                    "user_id": test_user.id,
                    "amount": 10.00 * (i + 1),
                    "merchant": f"Store {i}",
                    "type": "debit"
                },
                headers=auth_headers
            )
        
        response = client.get("/transactions/?skip=0&limit=3", headers=auth_headers)
        
        assert response.status_code == status.HTTP_200_OK
        data = response.json()
        assert len(data) <= 3
    
    def test_get_transactions_unauthenticated(self, client):
        """Test getting transactions without authentication"""
        response = client.get("/transactions/")
        
        assert response.status_code == status.HTTP_401_UNAUTHORIZED


class TestGetTransactionsByDateRange:
    """Test getting transactions by date range"""
    
    def test_get_transactions_in_range(self, client, auth_headers, test_user):
        """Test getting transactions within date range"""
        # Create transactions with different timestamps
        now = datetime.utcnow()
        yesterday = now - timedelta(days=1)
        tomorrow = now + timedelta(days=1)
        
        client.post(
            "/transactions/",
            json={
                "user_id": test_user.id,
                "amount": 50.00,
                "merchant": "Old Store",
                "type": "debit",
                "timestamp": yesterday.isoformat()
            },
            headers=auth_headers
        )
        
        response = client.get(
            f"/transactions/date-range?start_date={yesterday.isoformat()}&end_date={tomorrow.isoformat()}",
            headers=auth_headers
        )
        
        assert response.status_code == status.HTTP_200_OK
        data = response.json()
        assert len(data) >= 1
    
    def test_get_transactions_invalid_range(self, client, auth_headers):
        """Test with end_date before start_date"""
        now = datetime.utcnow()
        yesterday = now - timedelta(days=1)
        
        response = client.get(
            f"/transactions/date-range?start_date={now.isoformat()}&end_date={yesterday.isoformat()}",
            headers=auth_headers
        )
        
        assert response.status_code == status.HTTP_400_BAD_REQUEST


class TestGetSingleTransaction:
    """Test getting a single transaction"""
    
    def test_get_transaction_by_id(self, client, auth_headers, created_transaction):
        """Test getting specific transaction"""
        response = client.get(
            f"/transactions/{created_transaction['id']}",
            headers=auth_headers
        )
        
        assert response.status_code == status.HTTP_200_OK
        data = response.json()
        assert data["id"] == created_transaction["id"]
        assert data["merchant"] == created_transaction["merchant"]
    
    def test_get_nonexistent_transaction(self, client, auth_headers):
        """Test getting non-existent transaction"""
        response = client.get("/transactions/99999", headers=auth_headers)
        
        assert response.status_code == status.HTTP_404_NOT_FOUND


class TestUpdateTransaction:
    """Test updating transactions"""
    
    def test_update_transaction(self, client, auth_headers, created_transaction, test_user, db_session):
        """Test updating a transaction and verify savings adjustment"""
        initial_savings = test_user.savings
        old_amount = Decimal(created_transaction["amount"])
        old_type = created_transaction["type"]
        
        # Reverse old transaction effect on savings
        if old_type == "debit":
            expected_savings = initial_savings + old_amount  # Reverse debit
        else:
            expected_savings = initial_savings - old_amount  # Reverse credit
        
        # Apply new transaction
        new_amount = Decimal("150.00")
        expected_savings -= new_amount  # New debit
        
        response = client.put(
            f"/transactions/{created_transaction['id']}",
            json={
                "user_id": test_user.id,
                "amount": 150.00,
                "merchant": "Updated Store",
                "type": "debit",
                "timestamp": datetime.utcnow().isoformat()
            },
            headers=auth_headers
        )
        
        assert response.status_code == status.HTTP_200_OK
        data = response.json()
        assert data["amount"] == "150.00"
        assert data["merchant"] == "Updated Store"
        
        # Verify savings updated correctly
        db_session.refresh(test_user)
        assert test_user.savings == expected_savings
    
    def test_update_unauthorized_transaction(self, client, auth_headers, created_transaction, second_user):
        """Test updating transaction for another user"""
        response = client.put(
            f"/transactions/{created_transaction['id']}",
            json={
                "user_id": second_user.id,
                "amount": 150.00,
                "merchant": "Updated",
                "type": "debit"
            },
            headers=auth_headers
        )
        
        assert response.status_code == status.HTTP_403_FORBIDDEN


class TestDeleteTransaction:
    """Test deleting transactions"""
    
    def test_delete_transaction(self, client, auth_headers, created_transaction):
        """Test deleting a transaction"""
        response = client.delete(
            f"/transactions/{created_transaction['id']}",
            headers=auth_headers
        )
        
        assert response.status_code == status.HTTP_204_NO_CONTENT
        
        # Verify transaction is deleted
        get_response = client.get(
            f"/transactions/{created_transaction['id']}",
            headers=auth_headers
        )
        assert get_response.status_code == status.HTTP_404_NOT_FOUND
    
    def test_delete_nonexistent_transaction(self, client, auth_headers):
        """Test deleting non-existent transaction"""
        response = client.delete("/transactions/99999", headers=auth_headers)
        
        assert response.status_code == status.HTTP_404_NOT_FOUND
