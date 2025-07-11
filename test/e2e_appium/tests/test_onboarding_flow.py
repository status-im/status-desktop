"""
Status Desktop E2E Onboarding Flow Tests
"""

import pytest
from tests.base_test import BaseTest

# Import all page objects
from pages.welcome_screen_page import WelcomeScreenPage
from pages.analytics_screen_page import AnalyticsScreenPage
from pages.create_profile_screen_page import CreateProfileScreenPage
from pages.password_screen_page import PasswordScreenPage
from pages.loading_screen_page import LoadingScreenPage
from pages.main_app_page import MainAppPage

from models.user_model import User, UserProfile


class TestOnboardingFlow(BaseTest):
    """Test class for onboarding flow functionality"""
    
    def setup_method(self, method):
        """Set up method called before each test"""
        super().setup_method(method)
        
        # Initialize all page objects
        self.welcome_page = WelcomeScreenPage(self.driver)
        self.analytics_page = AnalyticsScreenPage(self.driver)
        self.create_profile_page = CreateProfileScreenPage(self.driver)
        self.password_page = PasswordScreenPage(self.driver)
        self.loading_page = LoadingScreenPage(self.driver)
        self.main_app_page = MainAppPage(self.driver)
        
        # Create test user data
        self.test_user = User(
            profile=UserProfile(
                display_name="E2E Test User",
                bio="Created during E2E automation test"
            ),
            password="TestPassword123!",
            environment="e2e_test"
        )
    
    @pytest.mark.smoke
    @pytest.mark.onboarding
    @pytest.mark.e2e
    def test_complete_onboarding_flow(self):
        """
        Test the complete onboarding flow from Welcome to Main App.
        
        This is the primary E2E test for the onboarding user journey.
        """
        self.logger.info("Starting complete onboarding flow test")
        
        # Step 1: Welcome Screen - Click "Create profile"
        self.logger.info("Step 1: Welcome Screen")
        assert self.welcome_page.is_screen_displayed(), "Welcome screen should be displayed"
        success = self.welcome_page.click_create_profile()
        assert success, "Should successfully click Create Profile button"
        
        # Step 2: Analytics Screen - Click "Not now"
        self.logger.info("Step 2: Analytics Screen")
        assert self.analytics_page.is_screen_displayed(), "Analytics screen should be displayed"
        success = self.analytics_page.skip_analytics_sharing()
        assert success, "Should successfully skip analytics sharing"
        
        # Step 3: Create Profile Screen - Click "Let's go!"
        self.logger.info("Step 3: Create Profile Screen")
        assert self.create_profile_page.is_screen_displayed(), "Create profile screen should be displayed"
        success = self.create_profile_page.click_lets_go()
        assert success, "Should successfully click Let's go! button"
        
        # Step 4: Password Screen - Create password
        self.logger.info("Step 4: Password Screen")
        assert self.password_page.is_screen_displayed(), "Password screen should be displayed"
        success = self.password_page.create_password(self.test_user.password)
        assert success, "Should successfully create password"
        
        # Step 5: Loading Screen - Wait for completion
        self.logger.info("Step 5: Loading Screen")
        success = self.loading_page.wait_for_loading_completion()
        assert success, "Should successfully complete loading"
        
        # Step 6: Main App - Verify shell container is present
        self.logger.info("Step 6: Main App")
        assert self.main_app_page.is_main_app_loaded(), "Main app should be loaded"
        
        self.logger.info("Complete onboarding flow test passed!")
    

    @pytest.mark.component
    @pytest.mark.onboarding
    @pytest.mark.ui_validation
    def test_welcome_screen_component_validation(self):
        """
        Test component-level validation for Welcome screen elements.
        """
        self.logger.info("Testing Welcome screen component validation")
        
        # Arrange - Verify initial state
        assert self.welcome_page.is_screen_displayed(), "Welcome screen should be displayed initially"
        
        # Act & Assert - Test component properties
        # Button visibility
        is_button_visible = self.welcome_page.is_create_profile_button_visible()
        assert is_button_visible, "Create profile button should be visible"
        
        # Button interactivity  
        is_button_clickable = self.welcome_page.is_create_profile_button_clickable()
        assert is_button_clickable, "Create profile button should be clickable"
        
        # Button text content
        actual_button_text = self.welcome_page.get_create_profile_button_text()
        expected_button_text = "Create profile"
        assert actual_button_text == expected_button_text, \
            f"Button text should be '{expected_button_text}', got '{actual_button_text}'"
        
        # Button functionality
        click_success = self.welcome_page.click_create_profile()
        assert click_success, "Should successfully click Create Profile button"
        
        # Verify navigation occurred
        assert self.analytics_page.is_screen_displayed(), \
            "Should navigate to Analytics screen after clicking Create Profile"
        
        self.logger.info("Welcome screen component validation passed!")
    