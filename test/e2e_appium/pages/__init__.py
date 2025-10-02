"""Pages package for tablet E2E tests."""

from .base_page import BasePage
from .app import App
from .onboarding import (
    HomePage,
    WelcomePage,
    AnalyticsPage,
    CreateProfilePage,
    PasswordPage,
    SplashScreen,
)

__all__ = [
    "BasePage",
    "HomePage",
    "App",
    "WelcomePage",
    "AnalyticsPage",
    "CreateProfilePage",
    "PasswordPage",
    "SplashScreen",
]
