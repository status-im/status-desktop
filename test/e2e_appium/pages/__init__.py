"""
Pages package for Status Desktop tablet E2E tests.
Contains Page Object Model classes for different screens.
"""

from .base_page import BasePage
from .onboarding_page import OnboardingPage
from .main_app_page import MainAppPage
from .welcome_screen_page import WelcomeScreenPage
from .analytics_screen_page import AnalyticsScreenPage
from .create_profile_screen_page import CreateProfileScreenPage
from .password_screen_page import PasswordScreenPage
from .loading_screen_page import LoadingScreenPage

__all__ = [
    'BasePage',
    'OnboardingPage',
    'MainAppPage',
    'WelcomeScreenPage',
    'AnalyticsScreenPage',
    'CreateProfileScreenPage',
    'PasswordScreenPage',
    'LoadingScreenPage',
] 