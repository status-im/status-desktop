"""
Loading Page for Status Desktop E2E Testing

Page object for splash during onboarding.
"""

from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC

from ..base_page import BasePage
from locators.onboarding.loading_screen_locators import LoadingScreenLocators


class SplashScreen(BasePage):
    """Page object for the Loading/Splash screen during onboarding"""

    def __init__(self, driver):
        super().__init__(driver)
        self.locators = LoadingScreenLocators()
        self.IDENTITY_LOCATOR = self.locators.SPLASH_SCREEN_PARTIAL

    def is_progress_bar_visible(self) -> bool:
        return self.is_element_visible(self.locators.PROGRESS_BAR)

    def wait_for_loading_completion(self, timeout: int = 60) -> bool:
        """Wait for loading to complete using explicit invisibility wait"""
        self.logger.info(f"Waiting for loading completion (timeout: {timeout}s)")
        try:
            wait = WebDriverWait(self.driver, timeout)
            wait.until(
                EC.invisibility_of_element_located(self.locators.SPLASH_SCREEN_PARTIAL)
            )
            self.logger.info("Loading completed - screen disappeared")
            return True
        except Exception:
            self.logger.warning(f"Loading did not complete within {timeout} seconds")
            return False
