"""
Pages package for Status Desktop tablet E2E tests.
Contains Page Object Model classes for different screens.
"""

from .base_page import BasePage
from .onboarding import (
    MainAppPage,
    WelcomePage,
    AnalyticsPage,
    CreateProfilePage,
    PasswordPage,
    SplashScreen,
)

__all__ = [
    "BasePage",
    "MainAppPage",
    "WelcomePage",
    "AnalyticsPage",
    "CreateProfilePage",
    "PasswordPage",
    "SplashScreen",
]
