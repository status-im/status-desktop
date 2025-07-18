"""
Locators package for Status Desktop tablet E2E tests.
Contains all element locators organized by screen/feature.
"""

from .base_locators import BaseLocators
from .onboarding_locators import OnboardingLocators
from .main_app_locators import MainAppLocators
from .welcome_screen_locators import WelcomeScreenLocators
from .analytics_screen_locators import AnalyticsScreenLocators
from .create_profile_screen_locators import CreateProfileScreenLocators
from .password_screen_locators import PasswordScreenLocators
from .loading_screen_locators import LoadingScreenLocators

__all__ = [
    'BaseLocators',
    'OnboardingLocators', 
    'MainAppLocators',
    'WelcomeScreenLocators',
    'AnalyticsScreenLocators',
    'CreateProfileScreenLocators',
    'PasswordScreenLocators',
    'LoadingScreenLocators',
] 