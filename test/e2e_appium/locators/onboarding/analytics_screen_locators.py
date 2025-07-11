"""
Analytics Locators for Status Desktop E2E Testing

Element locators for the analytics consent screen.
"""

from appium.webdriver.common.appiumby import AppiumBy
from .base_locators import BaseLocators


class AnalyticsScreenLocators(BaseLocators):
    """Locators for the Help Us Improve Status screen (analytics consent)"""

    # Screen identification - stable content-desc
    ANALYTICS_PAGE_BY_CONTENT_DESC = (
        AppiumBy.ACCESSIBILITY_ID,
        "Help us improve Status",
    )

    # Primary buttons - using stable content-desc
    SHARE_USAGE_DATA_BUTTON = (AppiumBy.ACCESSIBILITY_ID, "Share usage data")
    NOT_NOW_BUTTON = (AppiumBy.ACCESSIBILITY_ID, "Not now")

    # Container locator - stable without QMLTYPE
    ONBOARDING_CONTAINER = (
        AppiumBy.ID,
        "QGuiApplication.mainWindow.startupOnboardingLayout",
    )
