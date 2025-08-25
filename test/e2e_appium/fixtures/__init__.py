# E2E_Appium Fixtures - Clean Modular Export System
#
# This module provides a clean, organized fixture system for the e2e_appium framework.
# All fixtures are properly exported to avoid import conflicts and circular dependencies.

# Import and re-export core fixtures from the original comprehensive module
from .onboarding_fixture import (
    OnboardingConfig,
    OnboardingFlow,
    OnboardingFlowError,
    onboarding_config,
    onboarded_user,
    onboarded_app,
)

# Import and re-export fixtures from modular system


# Export all fixtures for easy importing
__all__ = [
    # Core onboarding fixtures
    "OnboardingConfig",
    "OnboardingFlow",
    "OnboardingFlowError",
    "onboarding_config",
    "onboarded_user",
    "onboarded_app",
]
