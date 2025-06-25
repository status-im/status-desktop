import time

import allure

import driver
from gui.elements.button import Button
from gui.elements.object import QObject
from gui.elements.text_edit import TextEdit
from gui.objects_map import shell_names
from gui.objects_map.names import statusDesktop_mainWindow
from gui.screens.community_portal import CommunitiesPortal
from gui.screens.market import MarketScreen
from gui.screens.messages import MessagesScreen
from gui.screens.settings import SettingsScreen
from gui.screens.wallet import WalletScreen


class ShellScreen(QObject):

    def __init__(self):
        super().__init__(shell_names.shell_container)
        self.search_field = TextEdit(shell_names.shell_search_field)
        self.grid = QObject(shell_names.shell_grid)
        self.dock = QObject(shell_names.shell_dock)

        # Dock button mapping
        self.dock_buttons = {
            "Wallet": (shell_names.shell_regular_dock_button_wallet, WalletScreen),
            "Settings": (shell_names.shell_regular_dock_button_settings, SettingsScreen),
            "Messages": (shell_names.shell_regular_dock_button_messages, MessagesScreen),
            "Communities": (shell_names.shell_regular_dock_button_communities, CommunitiesPortal),
            "Market": (shell_names.shell_regular_dock_button_market, MarketScreen)
        }

    # =============================================================================
    # SEARCH FUNCTIONS
    # =============================================================================

    @allure.step('Search in Shell')
    def search(self, query: str):
        """Enter search query in the Shell search field"""
        self.search_field.clear()
        self.search_field.type_text(query)

    @allure.step('Clear Shell search')
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
        locator = shell_names.shell_grid_item.copy()
        locator["title"] = title
        grid_item = Button(locator)
        grid_item.click()

    @allure.step('Check if grid item exists by title')
    def has_grid_item_by_title(self, title: str) -> bool:
        """Check if a grid item with the given title exists in the Shell grid"""
        locator = shell_names.shell_grid_item.copy()
        locator["title"] = title
        grid_item = Button(locator)
        return grid_item.is_visible

    @allure.step('Wait for grid item to appear')
    def wait_for_grid_item_by_title(self, title: str, timeout_msec: int = 10000):
        """Wait for a grid item to appear in the Shell grid"""
        return driver.waitFor(
            lambda: self.has_grid_item_by_title(title), timeout_msec
        )

    @allure.step('Wait for grid item to be removed')
    def wait_for_grid_item_removed_by_title(self, title: str, timeout_msec: int = 10000):
        """Wait for a grid item to be removed from the Shell grid"""
        return driver.waitFor(
            lambda: not self.has_grid_item_by_title(title), timeout_msec
        )

    @allure.step('Open Communities Portal from shell grid')
    def open_communities_portal_from_grid(self) -> CommunitiesPortal:
        """Navigate to Communities Portal from shell grid"""
        self.click_grid_item_by_title("Communities")
        return CommunitiesPortal().wait_until_appears()

    # =============================================================================
    # DOCK FUNCTIONS
    # =============================================================================

    @allure.step('Open screen from shell dock')
    def open_from_dock(self, screen_name: str):
        """Navigate to a screen from shell dock"""
        self.wait_for_shell_ui_loaded()

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
            locator = shell_names.shell_generic_dock_button.copy()
            locator["text"] = text
            Button(locator).click()

    # =============================================================================
    # UTILITY FUNCTIONS
    # =============================================================================

    @allure.step('Wait for shell UI to be fully loaded')
    def wait_for_shell_ui_loaded(self):
        # TODO: Create method to confirm rendering has finished.
        time.sleep(0.5)
        return self
