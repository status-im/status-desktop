"""
Password Page for Status Desktop E2E Testing

Page object for password creation and confirmation during profile setup.
"""

from selenium.webdriver.support.ui import WebDriverWait

from ..base_page import BasePage
from locators.onboarding.password_screen_locators import PasswordScreenLocators


class PasswordPage(BasePage):
    """Page object for the Password Creation screen"""

    def __init__(self, driver):
        super().__init__(driver)
        self.locators = PasswordScreenLocators()
        self.IDENTITY_LOCATOR = self.locators.PASSWORD_SCREEN

    def enter_password(self, password: str) -> bool:
        """Enter password using Qt/QML-safe input method"""
        self.logger.info("Entering password")

        # Use the new Qt-safe input method from base page
        return self.qt_safe_input(self.locators.PASSWORD_INPUT, password)

    def confirm_password(self, password: str) -> bool:
        """Enter password confirmation using Qt/QML-safe input method"""
        self.logger.info("Confirming password")

        # Use the new Qt-safe input method from base page
        return self.qt_safe_input(self.locators.PASSWORD_CONFIRM_INPUT, password)

    def click_confirm_password_button(self) -> bool:
        """Click the 'Confirm password' button with proper waiting for enablement"""
        self.logger.info("Waiting for password validation and button enablement")

        # FIRST: Hide keyboard if it's blocking the view
        self.logger.info("Ensuring button is visible before checking enabled state")
        if not self.ensure_element_visible(self.locators.CONFIRM_PASSWORD_BUTTON):
            self.logger.warning(
                "Confirm password button not visible after keyboard handling"
            )

        # THEN: Wait for button to become enabled (passwords must match)
        if not self._wait_for_button_enabled():
            self.logger.error("Confirm password button did not become enabled")
            return False

        # Use existing framework method - click_element() already waits for element_to_be_clickable
        result = self.safe_click(self.locators.CONFIRM_PASSWORD_BUTTON)
        if result is True:
            self.logger.info("Successfully clicked confirm password button")
            return True

        # Fallback with resource-id locator
        self.logger.info("Trying fallback locator for confirm button")
        result = self.safe_click(self.locators.CONFIRM_PASSWORD_BUTTON_BY_ID)
        return result is True

    def _wait_for_button_enabled(self, timeout: int = 10) -> bool:
        """Wait for the confirm password button to become enabled"""

        def button_is_enabled(driver):
            try:
                element = driver.find_element(*self.locators.CONFIRM_PASSWORD_BUTTON)
                return element.is_enabled()
            except Exception:
                return False

        try:
            wait = WebDriverWait(self.driver, timeout)
            wait.until(button_is_enabled)
            self.logger.info("Confirm password button is now enabled")
            return True
        except Exception:
            self.logger.warning(
                f"Button did not become enabled within {timeout} seconds"
            )
            return False

    def create_password(self, password: str) -> bool:
        """Complete password creation process"""
        self.logger.info("Creating password")

        if not self.enter_password(password):
            return False

        if not self.confirm_password(password):
            return False

        return self.click_confirm_password_button()
