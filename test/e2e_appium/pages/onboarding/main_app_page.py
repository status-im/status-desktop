"""
Main App Page for Status Desktop E2E Testing

Page object for the main application interface after successful onboarding, Shell container.
"""

from typing import Optional

from ..base_page import BasePage
from locators.onboarding.main_app_locators import MainAppLocators


class MainAppPage(BasePage):
    """Page object for the main Status Desktop application after onboarding"""

    def __init__(self, driver):
        super().__init__(driver)
        self.locators = MainAppLocators()

    def is_main_app_loaded(self) -> bool:
        return self.is_element_visible(self.locators.HOME_CONTAINER)

    def is_home_container_visible(self) -> bool:
        return self.is_element_visible(self.locators.HOME_CONTAINER)

    def is_search_field_visible(self) -> bool:
        return self.is_element_visible(self.locators.SEARCH_FIELD)

    def click_wallet_button(self) -> bool:
        self.logger.info("Clicking Wallet button")
        return self.safe_click(self.locators.WALLET_BUTTON)

    def click_messages_button(self) -> bool:
        self.logger.info("Clicking Messages button")
        return self.safe_click(self.locators.MESSAGES_BUTTON)

    def click_communities_button(self) -> bool:
        self.logger.info("Clicking Communities Portal button")
        return self.safe_click(self.locators.COMMUNITIES_BUTTON)

    def click_settings_button(self) -> bool:
        self.logger.info("Clicking Settings button")
        return self.safe_click(self.locators.SETTINGS_BUTTON)
    
    def open_profile_menu(self) -> bool:
        self.logger.info("Opening profile menu from main navigation")
        return self.safe_click(self.locators.PROFILE_NAV_BUTTON, timeout=5)

    def copy_profile_link_from_menu(self, timeout: int = 5) -> Optional[str]:
        if not self.open_profile_menu():
            self.logger.error("Failed to open profile menu")
            return None

        try: self.driver.set_clipboard_text("")
        except Exception: pass

        if not self.safe_click(self.locators.COPY_PROFILE_LINK_ACTION, timeout=timeout):
            self.logger.error("Failed to trigger copy-link action from profile menu")
            return None

        def has_clipboard_value():
            try:
                return bool(self.driver.get_clipboard_text().strip())
            except Exception:
                return False

        if not self.wait_for_condition(has_clipboard_value, timeout=timeout):
            self.logger.error("Clipboard did not receive profile link within timeout")
            return None

        try:
            return self.driver.get_clipboard_text().strip()
        except Exception:
            return None
