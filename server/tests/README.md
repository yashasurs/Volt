"""
README for Testing

## Running Tests

### Run all tests:
```bash
pytest
```

### Run specific test file:
```bash
pytest tests/test_auth.py
pytest tests/test_transactions.py
pytest tests/test_goals.py
pytest tests/test_email_config.py
pytest tests/test_ocr.py
```

### Run specific test class:
```bash
pytest tests/test_auth.py::TestUserRegistration
pytest tests/test_transactions.py::TestCreateTransaction
```

### Run specific test:
```bash
pytest tests/test_auth.py::TestUserRegistration::test_register_new_user
```

### Run with coverage:
```bash
pytest --cov=app --cov-report=html
```

### Run tests in parallel:
```bash
pytest -n auto
```

### Run only fast tests (skip slow/integration):
```bash
pytest -m "not slow"
```

## Test Structure

- `conftest.py` - Shared fixtures and test configuration
- `test_auth.py` - Authentication endpoint tests
- `test_transactions.py` - Transaction CRUD and savings tests
- `test_goals.py` - Goal management and contribution tests
- `test_email_config.py` - Email parsing configuration tests
- `test_ocr.py` - OCR image processing tests (mostly skipped, need real images)

## Fixtures Available

- `client` - FastAPI TestClient
- `db_session` - Test database session
- `test_user` - Pre-created test user
- `test_user_token` - Authentication token for test user
- `auth_headers` - Authorization headers with Bearer token
- `second_user` - Additional user for authorization tests

## Notes

- Tests use SQLite in-memory database
- Each test gets a fresh database
- OCR tests are mostly skipped (require actual image processing)
- All tests are independent and can run in any order
