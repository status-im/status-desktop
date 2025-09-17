"""
Loading Page for Status Desktop E2E Testing

Page object for splash during onboarding.
"""

from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from selenium.common.exceptions import TimeoutException

from ..base_page import BasePage
from locators.onboarding.loading_screen_locators import LoadingScreenLocators
from pages.onboarding.main_app_page import MainAppPage


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
        except TimeoutException:
            self.logger.warning(
                f"Loading did not complete within {timeout} seconds; checking main app state"
            )
            try:
                # Fallback: detect main app container to avoid false negatives on cloud runs
                main_app = MainAppPage(self.driver)
                if main_app.is_main_app_loaded():
                    self.logger.info(
                        "Main app container visible despite splash locator; continuing"
                    )
                    return True
            except Exception:
                pass
            return False
        except Exception:
            self.logger.warning(
                "Unexpected error while waiting for loading completion", exc_info=True
            )
            return False
