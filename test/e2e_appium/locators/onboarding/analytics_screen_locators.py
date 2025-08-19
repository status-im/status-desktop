"""
Analytics Locators for Status Desktop E2E Testing

Element locators for the analytics consent screen.
"""

from ..base_locators import BaseLocators


class AnalyticsScreenLocators(BaseLocators):
    """Locators for the Help Us Improve Status screen (analytics consent)"""

    # Screen identification - stable content-desc
    ANALYTICS_PAGE_BY_CONTENT_DESC = BaseLocators.accessibility_id("Help us improve Status")

    # Primary buttons - using stable content-desc
    SHARE_USAGE_DATA_BUTTON = BaseLocators.accessibility_id("Share usage data")
    NOT_NOW_BUTTON = BaseLocators.accessibility_id("Not now")

    # Container locator - stable without QMLTYPE
    ONBOARDING_CONTAINER = BaseLocators.id("QGuiApplication.mainWindow.startupOnboardingLayout")
