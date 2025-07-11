"""
Onboarding screen locators for Status Desktop tablet E2E tests.
"""

from ..base_locators import BaseLocators


class OnboardingLocators(BaseLocators):
    # Welcome Screen Locators
    WELCOME_TEXT = BaseLocators.accessibility_id("Welcome to Status")
    WELCOME_TEXT_FALLBACK = BaseLocators.content_desc_contains("Welcome")
    WELCOME_TEXT_TEXT = BaseLocators.text_contains("Welcome to Status")

    CREATE_PROFILE_BUTTON = BaseLocators.accessibility_id("Create profile")
    CREATE_PROFILE_BUTTON_FALLBACK = BaseLocators.content_desc_exact("Create profile")
    CREATE_PROFILE_BUTTON_TEXT = BaseLocators.button_with_text("Create profile")

    IMPORT_PROFILE_BUTTON = BaseLocators.accessibility_id("Import profile")

    # Create Profile Screen Locators
    CREATE_PROFILE_SCREEN = BaseLocators.accessibility_id("Create profile screen")

    DISPLAY_NAME_INPUT = BaseLocators.accessibility_id("Display name input")
    DISPLAY_NAME_ERROR = BaseLocators.accessibility_id("Display name error")

    NEXT_BUTTON = BaseLocators.accessibility_id("Next")

    # Help Improve Screen Locators
    HELP_IMPROVE_SCREEN = BaseLocators.accessibility_id("Help us improve Status")
    HELP_IMPROVE_TEXT_FALLBACK = BaseLocators.content_desc_contains("Help us improve")

    NOT_NOW_BUTTON = BaseLocators.accessibility_id("Not now")
    HELP_IMPROVE_BUTTON = BaseLocators.accessibility_id("Help improve")

    # Password Setup Screen Locators
    PASSWORD_SCREEN = BaseLocators.accessibility_id("Password setup screen")
    PASSWORD_INPUT = BaseLocators.accessibility_id("Password input")
    CONFIRM_PASSWORD_INPUT = BaseLocators.accessibility_id("Confirm password input")
    PASSWORD_STRENGTH = BaseLocators.accessibility_id("Password strength")
    PASSWORD_ERROR = BaseLocators.accessibility_id("Password error")
    PASSWORD_CONTINUE_BUTTON = BaseLocators.accessibility_id("Continue")

    # Completion Screen Locators
    COMPLETION_SCREEN = BaseLocators.accessibility_id("Onboarding completion")
    COMPLETION_MESSAGE = BaseLocators.accessibility_id("Completion message")
    GET_STARTED_BUTTON = BaseLocators.accessibility_id("Get started")

    # Main App Indicator
    MAIN_APP_INDICATOR = BaseLocators.accessibility_id("Main app")

    # General Screen Elements
    SCREEN_TITLE = BaseLocators.accessibility_id("Screen title")
    LOADING_INDICATOR = BaseLocators.accessibility_id("Loading")

    # Dynamic Locators
    @classmethod
    def get_step_screen(cls, step_name: str) -> tuple:
        """Get screen locator for specific onboarding step"""
        return cls.accessibility_id(f"{step_name}_screen")

    @classmethod
    def get_input_field(cls, field_name: str) -> tuple:
        """Get input field locator by name"""
        return cls.accessibility_id(f"{field_name}_input")

    @classmethod
    def get_error_message(cls, field_name: str) -> tuple:
        """Get error message locator for specific field"""
        return cls.accessibility_id(f"{field_name}_error")

    @classmethod
    def get_button_by_text(cls, button_text: str) -> tuple:
        """Get button locator by text"""
        return cls.button_with_text(button_text)

    @classmethod
    def get_screen_element(cls, element_name: str) -> tuple:
        """Get any screen element by name"""
        return cls.accessibility_id(element_name)
