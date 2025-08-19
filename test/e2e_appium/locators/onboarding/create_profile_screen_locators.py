"""
Create Profile Locators for Status Desktop E2E Testing

Element locators for the profile creation screen.
"""

from ..base_locators import BaseLocators


class CreateProfileScreenLocators(BaseLocators):
    """Locators for the Create Profile Screen during onboarding"""

    # Screen identification - stable content-desc
    CREATE_PROFILE_SCREEN = BaseLocators.accessibility_id("Create profile")

    # Primary button - Let's go! (creates with password)
    LETS_GO_BUTTON = BaseLocators.accessibility_id("Let's go!")

    # Alternative buttons (for different profile creation methods)
    USE_RECOVERY_PHRASE_BUTTON = BaseLocators.accessibility_id("Use a recovery phrase")
    USE_KEYCARD_BUTTON = BaseLocators.accessibility_id("Use an empty Keycard")

    # Container locators - stable without QMLTYPE
    ONBOARDING_CONTAINER = BaseLocators.id("QGuiApplication.mainWindow.startupOnboardingLayout")

    # Partial resource-id locators (avoiding dynamic QMLTYPE numbers)
    LETS_GO_BUTTON_BY_ID = BaseLocators.xpath("//*[contains(@resource-id, 'btnCreateWithPassword')]")
    CREATE_PROFILE_PARTIAL = BaseLocators.xpath("//*[contains(@resource-id, 'CreateProfilePage')]")
