"""
Create Profile Locators for Status Desktop E2E Testing

Element locators for the profile creation screen.
"""

from appium.webdriver.common.appiumby import AppiumBy
from .base_locators import BaseLocators


class CreateProfileScreenLocators(BaseLocators):
    """Locators for the Create Profile Screen during onboarding"""

    # Screen identification - stable content-desc
    CREATE_PROFILE_SCREEN = (AppiumBy.ACCESSIBILITY_ID, "Create profile")

    # Primary button - Let's go! (creates with password)
    LETS_GO_BUTTON = (AppiumBy.ACCESSIBILITY_ID, "Let's go!")

    # Alternative buttons (for different profile creation methods)
    USE_RECOVERY_PHRASE_BUTTON = (AppiumBy.ACCESSIBILITY_ID, "Use a recovery phrase")
    USE_KEYCARD_BUTTON = (AppiumBy.ACCESSIBILITY_ID, "Use an empty Keycard")

    # Container locators - stable without QMLTYPE
    ONBOARDING_CONTAINER = (
        AppiumBy.ID,
        "QGuiApplication.mainWindow.startupOnboardingLayout",
    )

    # Partial resource-id locators (avoiding dynamic QMLTYPE numbers)
    LETS_GO_BUTTON_BY_ID = (
        AppiumBy.XPATH,
        "//*[contains(@resource-id, 'btnCreateWithPassword')]",
    )
    CREATE_PROFILE_PARTIAL = (
        AppiumBy.XPATH,
        "//*[contains(@resource-id, 'CreateProfilePage')]",
    )
