"""
Analytics Page for Status Desktop E2E Testing

Page object for the analytics consent screen during onboarding.
"""

from ..base_page import BasePage
from locators.onboarding.analytics_screen_locators import AnalyticsScreenLocators


class AnalyticsPage(BasePage):
    """Page object for the Help Us Improve Status screen (analytics consent)"""

    def __init__(self, driver):
        super().__init__(driver)

        self.locators = AnalyticsScreenLocators()
        self.IDENTITY_LOCATOR = self.locators.ANALYTICS_PAGE_BY_CONTENT_DESC

    def click_share_usage_data(self) -> bool:
        self.logger.info("Clicking 'Share usage data' button")
        return self.safe_click(self.locators.SHARE_USAGE_DATA_BUTTON)

    def click_not_now(self) -> bool:
        self.logger.info("Clicking 'Not now' button")
        return self.safe_click(self.locators.NOT_NOW_BUTTON)

    def skip_analytics_sharing(self) -> bool:
        return self.click_not_now()

    def accept_analytics_sharing(self) -> bool:
        return self.click_share_usage_data()
