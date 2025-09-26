from ..base_locators import BaseLocators

class WelcomeScreenLocators(BaseLocators):

    # Screen identification
    WELCOME_PAGE = BaseLocators.content_desc_contains("Welcome to Status")

    CREATE_PROFILE_BUTTON = BaseLocators.content_desc_contains("[tid:btnCreateProfile]")
    LOGIN_BUTTON = BaseLocators.accessibility_id("Log in")

    ONBOARDING_LAYOUT = BaseLocators.xpath(
        "//*[contains(@resource-id, 'startupOnboardingLayout')]"
    )
