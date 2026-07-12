import pytest
from ..pages.login_page import LoginPage

@pytest.mark.usefixtures("driver")
class TestE2E:
    BASE_URL = "http://localhost:5000"

    def test_login_positive(self, driver):
        driver.get(f"{self.BASE_URL}/login")
        login_page = LoginPage(driver)
        # Using default credentials found in README
        login_page.login("admin", "admin123")
        assert "dashboard" in driver.current_url.lower()

    def test_login_negative(self, driver):
        driver.get(f"{self.BASE_URL}/login")
        login_page = LoginPage(driver)
        login_page.login("invalid", "invalid")
        assert login_page.get_text(LoginPage.ERROR_MESSAGE) != ""
