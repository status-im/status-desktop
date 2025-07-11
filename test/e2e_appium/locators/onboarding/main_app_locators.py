"""
Main App Locators for Status Desktop E2E Testing

Element locators for the main application interface.
"""

from appium.webdriver.common.appiumby import AppiumBy
from .base_locators import BaseLocators


class MainAppLocators(BaseLocators):
    """Locators for the main Status Desktop application after onboarding"""

    # Main layout - stable container (avoiding dynamic QMLTYPE)
    MAIN_LAYOUT = (AppiumBy.XPATH, "//*[contains(@resource-id, 'StatusMainLayout')]")

    HOME_CONTAINER = (
        AppiumBy.XPATH,
        "//*[contains(@resource-id, 'homeContainer')]",
    )

    # Main navigation dock buttons - using stable content-desc
    WALLET_BUTTON = (AppiumBy.ACCESSIBILITY_ID, "Wallet")
    MESSAGES_BUTTON = (AppiumBy.ACCESSIBILITY_ID, "Messages")
    COMMUNITIES_BUTTON = (AppiumBy.ACCESSIBILITY_ID, "Communities Portal")
    MARKET_BUTTON = (AppiumBy.ACCESSIBILITY_ID, "Market")
    SETTINGS_BUTTON = (AppiumBy.ACCESSIBILITY_ID, "Settings")

    # Search field - stable content-desc
    SEARCH_FIELD = (
        AppiumBy.ACCESSIBILITY_ID,
        "Jump to a community, chat, account or a dApp...",
    )

    # Grid container - avoiding dynamic QMLTYPE
    SHELL_GRID = (AppiumBy.XPATH, "//*[contains(@resource-id, 'shellGrid')]")

    # Profile button (top right area)
    PROFILE_BUTTON = (AppiumBy.XPATH, "//*[contains(@resource-id, 'ProfileButton')]")
