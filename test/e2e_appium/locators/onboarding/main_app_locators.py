from ..base_locators import BaseLocators


class MainAppLocators(BaseLocators):

    # TODO: Ensure not used anywhere and remove (superceded by home_locators.py)

    MAIN_LAYOUT = BaseLocators.xpath("//*[contains(@resource-id, 'StatusMainLayout')]")

    HOME_CONTAINER = BaseLocators.xpath("//*[contains(@resource-id, 'homeContainer')]")

    WALLET_BUTTON = BaseLocators.accessibility_id("Wallet")
    MESSAGES_BUTTON = BaseLocators.accessibility_id("Messages")
    COMMUNITIES_BUTTON = BaseLocators.accessibility_id("Communities Portal")
    MARKET_BUTTON = BaseLocators.accessibility_id("Market")
    SETTINGS_BUTTON = BaseLocators.accessibility_id("Settings")

    SEARCH_FIELD = BaseLocators.accessibility_id(
        "Jump to a community, chat, account or a dApp..."
    )

    SHELL_GRID = BaseLocators.xpath("//*[contains(@resource-id, 'shellGrid')]")

    PROFILE_BUTTON = BaseLocators.xpath("//*[contains(@resource-id, 'ProfileButton')]")
