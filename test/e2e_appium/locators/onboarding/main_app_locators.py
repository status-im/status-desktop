"""
Main App Locators for Status Desktop E2E Testing

Element locators for the main application interface.
"""

from ..base_locators import BaseLocators


class MainAppLocators(BaseLocators):
    """Locators for the main Status Desktop application after onboarding"""

    # Main layout - stable container (avoiding dynamic QMLTYPE)
    MAIN_LAYOUT = BaseLocators.xpath("//*[contains(@resource-id, 'StatusMainLayout')]")

    HOME_CONTAINER = BaseLocators.xpath("//*[contains(@resource-id, 'homeContainer')]")

    # Main navigation dock buttons - using stable content-desc
    WALLET_BUTTON = BaseLocators.accessibility_id("Wallet")
    MESSAGES_BUTTON = BaseLocators.accessibility_id("Messages")
    COMMUNITIES_BUTTON = BaseLocators.accessibility_id("Communities Portal")
    MARKET_BUTTON = BaseLocators.accessibility_id("Market")
    SETTINGS_BUTTON = BaseLocators.accessibility_id("Settings")

    # Search field - stable content-desc
    SEARCH_FIELD = BaseLocators.accessibility_id("Jump to a community, chat, account or a dApp...")

    # Grid container - avoiding dynamic QMLTYPE
    SHELL_GRID = BaseLocators.xpath("//*[contains(@resource-id, 'shellGrid')]")

    # Profile button (top right area)
    PROFILE_BUTTON = BaseLocators.xpath("//*[contains(@resource-id, 'ProfileButton')]")
