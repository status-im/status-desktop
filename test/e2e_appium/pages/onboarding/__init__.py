"""Onboarding page objects package (barrel module)"""

# Import from local modules (files were renamed to drop 'screen')
from .welcome_page import WelcomePage
from .analytics_page import AnalyticsPage
from .create_profile_page import CreateProfilePage
from .password_page import PasswordPage
from .loading_page import SplashScreen
from .main_app_page import MainAppPage
from .seed_phrase_input_page import SeedPhraseInputPage

__all__ = [
    "WelcomePage",
    "AnalyticsPage",
    "CreateProfilePage",
    "PasswordPage",
    "SplashScreen",
    "MainAppPage",
    "SeedPhraseInputPage",
]
