import time
from typing import Optional

from .base_page import BasePage
from locators.onboarding_locators import OnboardingLocators


class OnboardingPage(BasePage):
    
    def __init__(self, driver):
        super().__init__(driver)
        self.locators = OnboardingLocators()
    
    # Welcome Screen Methods
    def is_welcome_screen_visible(self) -> bool:
        fallbacks = [
            self.locators.WELCOME_TEXT_FALLBACK, 
            self.locators.WELCOME_TEXT_TEXT
        ]
        return self.is_element_visible(self.locators.WELCOME_TEXT, fallbacks)
    
    def click_create_profile_button(self) -> bool:
        fallbacks = [
            self.locators.CREATE_PROFILE_BUTTON_FALLBACK, 
            self.locators.CREATE_PROFILE_BUTTON_TEXT
        ]
        result = self.safe_click(self.locators.CREATE_PROFILE_BUTTON, fallbacks)
        return result is not None
    
    def get_welcome_text(self) -> Optional[str]:
        """Get welcome screen text"""
        element = self.wait_for_element(self.locators.WELCOME_TEXT)
        return element.text if element else None
    
    # Create Profile Screen Methods
    def is_create_profile_screen_visible(self) -> bool:
        return self.is_element_visible(self.locators.CREATE_PROFILE_SCREEN)
    
    def enter_display_name(self, name: str) -> bool:
        return self.safe_input(self.locators.DISPLAY_NAME_INPUT, name)
    
    def get_entered_display_name(self) -> Optional[str]:
        """Get the currently entered display name"""
        element = self.wait_for_element(self.locators.DISPLAY_NAME_INPUT)
        return element.text if element else None
    
    def is_next_button_enabled(self) -> bool:
        return self.is_element_visible(self.locators.NEXT_BUTTON)
    
    def click_next_button(self) -> bool:
        result = self.safe_click(self.locators.NEXT_BUTTON)
        return result is not None
    
    def is_display_name_error_visible(self) -> bool:
        """Check if display name validation error is shown"""
        return self.is_element_visible(self.locators.DISPLAY_NAME_ERROR)
    
    def get_display_name_error_text(self) -> Optional[str]:
        """Get display name error message"""
        element = self.wait_for_element(self.locators.DISPLAY_NAME_ERROR)
        return element.text if element else None
    
    # Help Improve Screen Methods
    def is_help_improve_screen_visible(self) -> bool:
        fallbacks = [self.locators.HELP_IMPROVE_TEXT_FALLBACK]
        return self.is_element_visible(self.locators.HELP_IMPROVE_SCREEN, fallbacks)
    
    def get_help_improve_text(self) -> Optional[str]:
        """Get help improve screen text"""
        element = self.wait_for_element(self.locators.HELP_IMPROVE_SCREEN)
        return element.text if element else None
    
    def click_not_now_button(self) -> bool:
        """Click 'Not now' button on help improve screen"""
        result = self.safe_click(self.locators.NOT_NOW_BUTTON)
        return result is not None
    
    def click_help_improve_button(self) -> bool:
        """Click 'Help improve' button"""
        result = self.safe_click(self.locators.HELP_IMPROVE_BUTTON)
        return result is not None
    
    # Password Setup Screen Methods
    def is_password_screen_visible(self) -> bool:
        """Check if password setup screen is visible"""
        return self.is_element_visible(self.locators.PASSWORD_SCREEN)
    
    def enter_password(self, password: str) -> bool:
        """Enter password in password field"""
        return self.safe_input(self.locators.PASSWORD_INPUT, password)
    
    def enter_confirm_password(self, password: str) -> bool:
        """Enter password in confirm password field"""
        return self.safe_input(self.locators.CONFIRM_PASSWORD_INPUT, password)
    
    def is_password_strength_visible(self) -> bool:
        """Check if password strength indicator is visible"""
        return self.is_element_visible(self.locators.PASSWORD_STRENGTH)
    
    def get_password_strength_text(self) -> Optional[str]:
        """Get password strength indicator text"""
        element = self.wait_for_element(self.locators.PASSWORD_STRENGTH)
        return element.text if element else None
    
    def is_password_error_visible(self) -> bool:
        """Check if password error is visible"""
        return self.is_element_visible(self.locators.PASSWORD_ERROR)
    
    def get_password_error_text(self) -> Optional[str]:
        """Get password error message"""
        element = self.wait_for_element(self.locators.PASSWORD_ERROR)
        return element.text if element else None
    
    def is_password_continue_enabled(self) -> bool:
        """Check if continue button is enabled on password screen"""
        return self.is_element_visible(self.locators.PASSWORD_CONTINUE_BUTTON)
    
    def click_password_continue(self) -> bool:
        """Click continue button on password screen"""
        result = self.safe_click(self.locators.PASSWORD_CONTINUE_BUTTON)
        return result is not None
    
    # Completion Screen Methods
    def is_completion_screen_visible(self) -> bool:
        """Check if onboarding completion screen is visible"""
        return self.is_element_visible(self.locators.COMPLETION_SCREEN)
    
    def get_completion_message(self) -> Optional[str]:
        """Get completion screen message"""
        element = self.wait_for_element(self.locators.COMPLETION_MESSAGE)
        return element.text if element else None
    
    def click_get_started_button(self) -> bool:
        """Click get started button on completion screen"""
        result = self.safe_click(self.locators.GET_STARTED_BUTTON)
        return result is not None
    
    def is_main_app_visible(self) -> bool:
        """Check if main app is visible after onboarding"""
        return self.is_element_visible(self.locators.MAIN_APP_INDICATOR)
    
    # General Helper Methods
    def wait_for_screen_transition(self, timeout: int = 10) -> bool:
        """Wait for screen transition to complete"""
        time.sleep(1)  # Basic wait for transition
        return True
    
    def take_onboarding_screenshot(self, step_name: str) -> bool:
        """Take screenshot during onboarding step"""
        return self.take_screenshot(f"onboarding_{step_name}")
    
    def get_current_screen_title(self) -> Optional[str]:
        """Get current screen title if available"""
        element = self.wait_for_element(self.locators.SCREEN_TITLE)
        return element.text if element else None
    
    # Complete Flow Methods
    def complete_basic_onboarding(self, display_name: str, password: str) -> bool:
        """Complete basic onboarding flow with given data"""
        try:
            # Step 1: Welcome screen
            if not self.is_welcome_screen_visible():
                return False
            
            # Step 2: Click create profile
            if not self.click_create_profile_button():
                return False
            
            # Step 3: Enter display name
            if not self.enter_display_name(display_name):
                return False
            
            # Step 4: Continue to next step
            if not self.click_next_button():
                return False
            
            # Step 5: Skip help improve if visible
            if self.is_help_improve_screen_visible():
                if not self.click_not_now_button():
                    return False
            
            # Step 6: Password setup
            if self.is_password_screen_visible():
                if not self.enter_password(password):
                    return False
                if not self.enter_confirm_password(password):
                    return False
                if not self.click_password_continue():
                    return False
            
            # Step 7: Complete onboarding
            if self.is_completion_screen_visible():
                if not self.click_get_started_button():
                    return False
            
            return self.is_main_app_visible()
            
        except Exception as e:
            self.logger.error(f"Complete basic onboarding failed: {e}")
            return False 