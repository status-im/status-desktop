from ..base_locators import BaseLocators


class CreateProfileScreenLocators(BaseLocators):

    CREATE_PROFILE_SCREEN = BaseLocators.accessibility_id("Create profile")
    LETS_GO_BUTTON = BaseLocators.accessibility_id("Let's go!")
    USE_RECOVERY_PHRASE_BUTTON = BaseLocators.accessibility_id("Use a recovery phrase")
    USE_KEYCARD_BUTTON = BaseLocators.accessibility_id("Use an empty Keycard")

    ONBOARDING_CONTAINER = BaseLocators.id(
        "QGuiApplication.mainWindow.startupOnboardingLayout"
    )

    LETS_GO_BUTTON_BY_ID = BaseLocators.xpath(
        "//*[contains(@resource-id, 'btnCreateWithPassword')]"
    )
    CREATE_PROFILE_PARTIAL = BaseLocators.xpath(
        "//*[contains(@resource-id, 'CreateProfilePage')]"
    )
