"""
Loading Locators for Status Desktop E2E Testing

Element locators for loading screens.
"""

from ..base_locators import BaseLocators


class LoadingScreenLocators(BaseLocators):
    """Locators for the Loading/Splash screen during onboarding"""

    # Loading screen container - stable resource-id
    SPLASH_SCREEN = BaseLocators.id("QGuiApplication.mainWindow.startupOnboardingLayout.OnboardingFlow_QMLTYPE_206.splashScreenV2")

    # Alternative using partial ID (avoiding dynamic QMLTYPE)
    SPLASH_SCREEN_PARTIAL = BaseLocators.xpath("//*[contains(@resource-id, 'splashScreenV2')]")

    # Progress bar - avoiding dynamic QMLTYPE
    PROGRESS_BAR = BaseLocators.xpath("//*[contains(@resource-id, 'StatusProgressBar')]")

    # Container locator - stable without QMLTYPE
    ONBOARDING_CONTAINER = BaseLocators.id("QGuiApplication.mainWindow.startupOnboardingLayout")
