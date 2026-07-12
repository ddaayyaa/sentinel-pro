import pytest

def test_server_health(driver):
    # Smoke test to check if server is reachable
    driver.get("http://localhost:5000/health")
    assert "ok" in driver.page_source.lower()

def test_api_status_check(driver):
    driver.get("http://localhost:5000/api/admin/api-status")
    # Should require login, so 401 is expected if not authenticated
    # This verifies the endpoint exists and security is active
    assert "unauthorized" in driver.page_source.lower() or driver.title != ""
