"""
Welcome Page for Status Desktop E2E Testing

Page object for the initial welcome screen in the onboarding flow.
"""

import logging
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from selenium.common.exceptions import TimeoutException
from .base_page import BasePage
from locators.welcome_screen_locators import WelcomeScreenLocators


class WelcomeScreenPage(BasePage):
    """Page object for the Welcome screen"""
    
    def __init__(self, driver):
        super().__init__(driver)
        self.locators = WelcomeScreenLocators()
        self.logger = logging.getLogger(__name__)
    
    def is_screen_displayed(self) -> bool:
        """Check if the welcome screen is currently displayed"""
        return self.is_element_visible(self.locators.WELCOME_PAGE)
    
    def click_create_profile(self) -> bool:
        """Click the 'Create profile' button"""
        self.logger.info("Clicking 'Create profile' button")
        return self.safe_click(self.locators.CREATE_PROFILE_BUTTON)
    
    def click_login(self) -> bool:
        """Click the 'Log in' button"""
        self.logger.info("Clicking 'Log in' button")
        return self.safe_click(self.locators.LOGIN_BUTTON) 