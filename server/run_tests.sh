#!/bin/bash
# Test runner script for Kronyx API

echo "================================"
echo "Running Kronyx API Test Suite"
echo "================================"
echo ""

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if pytest is installed
if ! command -v pytest &> /dev/null; then
    echo -e "${YELLOW}pytest not found. Installing dependencies...${NC}"
    pip install -r requirements.txt
fi

# Run tests based on argument
case "${1}" in
    "auth")
        echo "Running authentication tests..."
        pytest tests/test_auth.py -v
        ;;
    "transactions")
        echo "Running transaction tests..."
        pytest tests/test_transactions.py -v
        ;;
    "goals")
        echo "Running goal tests..."
        pytest tests/test_goals.py -v
        ;;
    "email")
        echo "Running email config tests..."
        pytest tests/test_email_config.py -v
        ;;
    "ocr")
        echo "Running OCR tests..."
        pytest tests/test_ocr.py -v -s
        ;;
    "coverage")
        echo "Running tests with coverage report..."
        pytest --cov=app --cov-report=html --cov-report=term
        echo ""
        echo -e "${GREEN}Coverage report generated in htmlcov/index.html${NC}"
        ;;
    "fast")
        echo "Running fast tests only (excluding slow/integration tests)..."
        pytest -m "not slow" -v
        ;;
    "quick")
        echo "Running quick smoke tests..."
        pytest tests/test_auth.py::TestUserRegistration::test_register_new_user -v
        pytest tests/test_transactions.py::TestCreateTransaction::test_create_debit_transaction -v
        ;;
    *)
        echo "Running all tests (excluding OCR)..."
        pytest -v --ignore=tests/test_ocr.py
        ;;
esac

echo ""
echo -e "${GREEN}Tests completed!${NC}"
