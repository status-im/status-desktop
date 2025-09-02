"""
Password Page for Status Desktop E2E Testing

Page object for password creation and confirmation during profile setup.
"""

import time

from ..base_page import BasePage
from locators.onboarding.password_screen_locators import PasswordScreenLocators


class PasswordPage(BasePage):
    """Page object for the Password Creation screen"""

    def __init__(self, driver):
        super().__init__(driver)
        self.locators = PasswordScreenLocators()
        self.IDENTITY_LOCATOR = self.locators.PASSWORD_SCREEN

    def enter_password(self, password: str) -> bool:
        self.logger.info("Entering password")

        # Use the new Qt-safe input method from base page
        return self.qt_safe_input(self.locators.PASSWORD_INPUT, password)

    def confirm_password(self, password: str) -> bool:
        self.logger.info("Confirming password")

        # Use the new Qt-safe input method from base page
        return self.qt_safe_input(self.locators.PASSWORD_CONFIRM_INPUT, password)

    def click_confirm_password_button(self) -> bool:
        self.logger.info("Clicking confirm password button")
        
        self.hide_keyboard()
        
        try:
            return self.safe_click(self.locators.CONFIRM_PASSWORD_BUTTON_BY_ID)
        except RuntimeError:
            self.logger.info("Trying fallback locator for confirm button")
            return self.safe_click(self.locators.CONFIRM_PASSWORD_BUTTON)

    def create_password(self, password: str) -> bool:
        self.logger.info("Creating password")

        self.enter_password(password)
        self.confirm_password(password)

        time.sleep(1)  # Brief wait for validation

        return self.click_confirm_password_button()
