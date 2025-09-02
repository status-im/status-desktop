"""
Welcome Locators for Status Desktop E2E Testing

Element locators for the welcome screen.
"""

from ..base_locators import BaseLocators


class WelcomeScreenLocators(BaseLocators):
    """Locators for the Welcome screen"""

    # Screen identification - stable content-desc
    WELCOME_PAGE = BaseLocators.content_desc_contains("Welcome to Status")

    # Primary buttons - using stable content-desc (QMLTYPE numbers are dynamic)
    CREATE_PROFILE_BUTTON = BaseLocators.accessibility_id("Create profile")
    LOGIN_BUTTON = BaseLocators.accessibility_id("Log in")

    # Container locators - stable without QMLTYPE
    ONBOARDING_LAYOUT = BaseLocators.id("QGuiApplication.mainWindow.startupOnboardingLayout")
