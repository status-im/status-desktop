"""Onboarding page objects package."""

from .welcome_page import WelcomePage
from .analytics_page import AnalyticsPage
from .create_profile_page import CreateProfilePage
from .password_page import PasswordPage
from .loading_page import SplashScreen
from .home_page import HomePage
from .seed_phrase_input_page import SeedPhraseInputPage
from .main_app_page import MainAppPage

__all__ = [
    "WelcomePage",
    "AnalyticsPage",
    "CreateProfilePage",
    "PasswordPage",
    "SplashScreen",
    "HomePage",
    "SeedPhraseInputPage",
    "MainAppPage",
]
