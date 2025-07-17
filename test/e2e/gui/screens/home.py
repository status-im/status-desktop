import time

import allure

import driver
from gui.components.online_identifier import OnlineIdentifier
from gui.elements.button import Button
from gui.elements.object import QObject
from gui.elements.text_edit import TextEdit
from gui.objects_map import home_names
from gui.screens.community_portal import CommunitiesPortal
from gui.screens.market import MarketScreen
from gui.screens.messages import MessagesScreen
from gui.screens.settings import SettingsScreen
from gui.screens.wallet import WalletScreen


class HomeScreen(QObject):

    def __init__(self):
        super().__init__(home_names.home_container)
        self.search_field = TextEdit(home_names.home_search_field)
        self.grid = QObject(home_names.home_grid)
        self.dock = QObject(home_names.home_dock)
        self.profile_button = QObject(home_names.home_profile)

        # Dock button mapping
        self.dock_buttons = {
            "Wallet": (home_names.home_regular_dock_button_wallet, WalletScreen),
            "Settings": (home_names.home_regular_dock_button_settings, SettingsScreen),
            "Messages": (home_names.home_regular_dock_button_messages, MessagesScreen),
            "Communities": (home_names.home_regular_dock_button_communities, CommunitiesPortal),
            "Market": (home_names.home_regular_dock_button_market, MarketScreen)
        }

    # =============================================================================
    # SEARCH FUNCTIONS
    # =============================================================================

    @allure.step('Search in Home')
    def search(self, query: str):
        """Enter search query in the home search field"""
        self.search_field.clear()
        self.search_field.type_text(query)

    @allure.step('Clear Home search')
    def clear_search(self):
        """Clear the search field"""
        self.search_field.clear()

    @allure.step('Get search text')
    def get_search_text(self) -> str:
        """Get current search text"""
        return self.search_field.text

    # =============================================================================
    # GRID FUNCTIONS
    # =============================================================================

    @allure.step('Get grid items count')
    def get_grid_items_count(self) -> int:
        """Get number of items currently visible in the grid"""
        return self.grid.object.count if hasattr(self.grid.object, 'count') else 0

    @allure.step('Click grid item by title')
    def click_grid_item_by_title(self, title: str):
        """Click a grid item by its title"""
        locator = home_names.home_grid_item.copy()
        locator["title"] = title
        grid_item = Button(locator)
        grid_item.click()

    @allure.step('Check if grid item exists by title')
    def has_grid_item_by_title(self, title: str) -> bool:
        """Check if a grid item with the given title exists in the home grid"""
        locator = home_names.home_grid_item.copy()
        locator["title"] = title
        grid_item = Button(locator)
        return grid_item.is_visible

    @allure.step('Wait for grid item to appear')
    def wait_for_grid_item_by_title(self, title: str, timeout_msec: int = 10000):
        """Wait for a grid item to appear in the home grid"""
        return driver.waitFor(
            lambda: self.has_grid_item_by_title(title), timeout_msec
        )

    @allure.step('Wait for grid item to be removed')
    def wait_for_grid_item_removed_by_title(self, title: str, timeout_msec: int = 10000):
        """Wait for a grid item to be removed from the home grid"""
        return driver.waitFor(
            lambda: not self.has_grid_item_by_title(title), timeout_msec
        )

    @allure.step('Open Communities Portal from home grid')
    def open_communities_portal_from_grid(self) -> CommunitiesPortal:
        """Navigate to Communities Portal from home grid"""
        self.click_grid_item_by_title("Communities")
        return CommunitiesPortal().wait_until_appears()

    @allure.step('Open online identifier from home screen')
    def open_online_identifier_from_home_screen(self, attempts: int = 3) -> OnlineIdentifier:
        for _ in range(attempts):
            try:
                self.profile_button.click()
                return OnlineIdentifier().wait_until_appears()
            except Exception:
                pass
        raise LookupError(f'Online identifier popup was not opened after {attempts} retries')

    # =============================================================================
    # DOCK FUNCTIONS
    # =============================================================================

    @allure.step('Open screen from home dock')
    def open_from_dock(self, screen_name: str):
        """Navigate to a screen from home dock"""
        self.wait_for_home_ui_loaded()

        if screen_name in self.dock_buttons:
            button_locator, screen_class = self.dock_buttons[screen_name]
            Button(button_locator).click()
            return screen_class().wait_until_appears()
        else:
            raise ValueError(f"Unknown screen: {screen_name}")

    @allure.step('Click dock button by text')
    def click_dock_button_by_text(self, text: str):
        """Click a dock button by its text"""
        if text in self.dock_buttons:
            button_locator, _ = self.dock_buttons[text]
            Button(button_locator).click()
        else:
            # Fallback for unknown buttons
            locator = home_names.home_generic_dock_button.copy()
            locator["text"] = text
            Button(locator).click()

    # =============================================================================
    # UTILITY FUNCTIONS
    # =============================================================================

    @allure.step('Wait for home UI to be fully loaded')
    def wait_for_home_ui_loaded(self):
        # TODO: https://github.com/status-im/status-desktop/issues/18325
        time.sleep(0.5)
        return self
