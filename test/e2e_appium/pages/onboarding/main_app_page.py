"""
Main App Page for Status Desktop E2E Testing

Page object for the main application interface after successful onboarding, Shell container.
"""

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
