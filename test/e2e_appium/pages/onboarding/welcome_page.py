"""
Welcome Page for Status Desktop E2E Testing

Page object for the initial welcome screen in the onboarding flow.
"""

import logging
from ..base_page import BasePage
from locators.onboarding.welcome_screen_locators import WelcomeScreenLocators


class WelcomePage(BasePage):
    """Page object for the Welcome screen"""

    def __init__(self, driver):
        super().__init__(driver)
        self.locators = WelcomeScreenLocators()
        self.logger = logging.getLogger(__name__)
        self.IDENTITY_LOCATOR = self.locators.WELCOME_PAGE

    def click_create_profile(self) -> bool:
        """Click the 'Create profile' button"""
        self.logger.info("Clicking 'Create profile' button")
        return self.safe_click(self.locators.CREATE_PROFILE_BUTTON)

    def click_login(self) -> bool:
        """Click the 'Log in' button"""
        self.logger.info("Clicking 'Log in' button")
        return self.safe_click(self.locators.LOGIN_BUTTON)
