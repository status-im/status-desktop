"""
Loading Page for Status Desktop E2E Testing

Page object for splash during onboarding.
"""

import logging
import time
from .base_page import BasePage
from locators.loading_screen_locators import LoadingScreenLocators


class LoadingScreenPage(BasePage):
    """Page object for the Loading/Splash screen during onboarding"""
    
    def __init__(self, driver):
        super().__init__(driver)
        self.locators = LoadingScreenLocators()
        self.logger = logging.getLogger(__name__)
    
    def is_screen_displayed(self) -> bool:
        """Check if the loading screen is currently displayed"""
        return self.is_element_visible(self.locators.SPLASH_SCREEN_PARTIAL)
    
    def is_progress_bar_visible(self) -> bool:
        """Check if the progress bar is visible"""
        return self.is_element_visible(self.locators.PROGRESS_BAR)
    
    def wait_for_loading_completion(self, timeout: int = 60) -> bool:
        """Wait for loading to complete and screen to disappear"""
        self.logger.info(f"Waiting for loading completion (timeout: {timeout}s)")
        
        start_time = time.time()
        while time.time() - start_time < timeout:
            # Check if we're still on loading screen
            if not self.is_screen_displayed():
                self.logger.info("Loading completed - screen disappeared")
                return True
            
            # Wait a bit before checking again
            time.sleep(1)
        
        self.logger.warning(f"Loading did not complete within {timeout} seconds")
        return False 