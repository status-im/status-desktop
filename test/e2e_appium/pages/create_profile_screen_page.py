"""
Create Profile Page for Status Desktop E2E Testing

This page object encapsulates interactions with the profile creation screen
during the onboarding flow. Supports multiple profile creation methods:
- Create new profile with password
- Import via recovery phrase  
- Use empty Keycard
"""

import logging
import time
from .base_page import BasePage
from locators.create_profile_screen_locators import CreateProfileScreenLocators


class CreateProfileScreenPage(BasePage):
    """Page object for the Create Profile Screen during onboarding"""
    
    def __init__(self, driver):
        super().__init__(driver)
        self.locators = CreateProfileScreenLocators()
        self.logger = logging.getLogger(__name__)
    
    def is_screen_displayed(self) -> bool:
        """Check if the create profile screen is currently displayed"""
        return self.is_element_visible(self.locators.CREATE_PROFILE_SCREEN)
    
    def click_lets_go(self) -> bool:
        """Click the 'Let's go!' button to create profile with password"""
        self.logger.info("Clicking 'Let's go!' button")
        
        # Small wait to ensure button is fully ready
        time.sleep(1)
        
        # Try resource-id first
        result = self.safe_click(self.locators.LETS_GO_BUTTON_BY_ID)
        if result is True:
            return True
            
        # Fallback to accessibility-id based locator
        self.logger.info("Fallback: trying resource-id based locator")
        result = self.safe_click(self.locators.LETS_GO_BUTTON)
        return result is True
    
    def click_use_recovery_phrase(self) -> bool:
        """Click the 'Use a recovery phrase' button"""
        self.logger.info("Clicking 'Use a recovery phrase' button")
        return self.safe_click(self.locators.USE_RECOVERY_PHRASE_BUTTON)
    
    def click_use_keycard(self) -> bool:
        """Click the 'Use an empty Keycard' button"""
        self.logger.info("Clicking 'Use an empty Keycard' button")
        return self.safe_click(self.locators.USE_KEYCARD_BUTTON) 