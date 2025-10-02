from ..base_locators import BaseLocators

class AnalyticsScreenLocators(BaseLocators):

    ANALYTICS_PAGE_BY_CONTENT_DESC = BaseLocators.accessibility_id(
        "Help us improve Status"
    )
    SHARE_USAGE_DATA_BUTTON = BaseLocators.accessibility_id("Share usage data")
    NOT_NOW_BUTTON = BaseLocators.content_desc_contains("[tid:btnDontShare]")

    ONBOARDING_CONTAINER = BaseLocators.id(
        "QGuiApplication.mainWindow.startupOnboardingLayout"
    )
