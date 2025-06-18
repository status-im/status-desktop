import time

import allure

import driver
from gui.elements.button import Button
from gui.elements.object import QObject
from gui.elements.text_edit import TextEdit
from gui.objects_map import shell_names
from gui.objects_map.names import statusDesktop_mainWindow
from gui.screens.community_portal import CommunitiesPortal
from gui.screens.messages import MessagesScreen
from gui.screens.settings import SettingsScreen
from gui.screens.wallet import WalletScreen

class ShellScreen(QObject):

    def __init__(self):
        super().__init__(shell_names.shell_container)
        self.search_field = TextEdit(shell_names.shell_search_field)
        self.grid = QObject(shell_names.shell_grid)
        self.dock = QObject(shell_names.shell_dock)

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

    @allure.step('Get grid items count')
    def get_grid_items_count(self) -> int:
        """Get number of items currently visible in the grid"""
        return self.grid.object.count if hasattr(self.grid.object, 'count') else 0

    @allure.step('Open Wallet from shell dock')
    def open_wallet_from_dock(self) -> WalletScreen:
        """Navigate to Wallet from shell dock"""
        wallet_button = Button(shell_names.shell_regular_dock_button_wallet)
        wallet_button.click()
        return WalletScreen().wait_until_appears()

    @allure.step('Open Settings from shell dock')
    def open_settings_from_dock(self) -> SettingsScreen:
        """Navigate to Settings from shell dock"""
        self.wait_for_shell_ui_loaded()
        settings_button = Button(shell_names.shell_regular_dock_button_settings)
        settings_button.click()
        return SettingsScreen().wait_until_appears()

    @allure.step('Open Messages from shell dock')
    def open_messages_from_dock(self) -> MessagesScreen:
        """Navigate to Messages from shell dock"""
        messages_button = Button(shell_names.shell_regular_dock_button_messages)
        messages_button.click()
        return MessagesScreen().wait_until_appears()

    @allure.step('Open Communities from shell dock')
    def open_communities_from_dock(self) -> CommunitiesPortal:
        """Navigate to Communities from shell dock"""
        communities_button = Button(shell_names.shell_regular_dock_button_communities)
        communities_button.click()
        return CommunitiesPortal().wait_until_appears()

    @allure.step('Open Market from shell dock')
    def open_market_from_dock(self):
        """Navigate to Market from shell dock"""
        market_button = Button(shell_names.shell_regular_dock_button_market)
        market_button.click()

    @allure.step('Open Communities Portal from shell grid')
    def open_communities_portal_from_grid(self) -> CommunitiesPortal:
        """Navigate to Communities Portal from shell grid"""
        communities_item = Button({"container": shell_names.shell_grid, "title": "Communities", "type": "ShellGridItem", "visible": True})
        communities_item.click()
        return CommunitiesPortal().wait_until_appears()

    @allure.step('Click grid item by title')
    def click_grid_item(self, title: str):
        """Click a grid item by its title"""
        grid_item = Button({"container": shell_names.shell_grid, "title": title, "type": "ShellGridItem", "visible": True})
        grid_item.click()

    @allure.step('Click dock button by text')
    def click_dock_button(self, text: str):
        """Click a dock button by its text"""
        # Use specific static locators for known buttons
        if text == "Wallet":
            dock_button = Button(shell_names.shell_regular_dock_button_wallet)
        elif text == "Market":
            dock_button = Button(shell_names.shell_regular_dock_button_market)
        elif text == "Messages":
            dock_button = Button(shell_names.shell_regular_dock_button_messages)
        elif text == "Communities":
            dock_button = Button(shell_names.shell_regular_dock_button_communities)
        elif text == "Settings":
            dock_button = Button(shell_names.shell_regular_dock_button_settings)
        else:
            # Fallback to generic locator for unknown buttons
            dock_button = Button({"container": shell_names.shellDockButtonLoader_Loader, "text": text, "type": "ShellDockButton", "visible": True})
        
        dock_button.click()

    @allure.step('Wait for shell UI to be fully loaded')
    def wait_for_shell_ui_loaded(self):
        """Wait for shell UI to be fully loaded before interacting"""
        max_retries = 10
        for i in range(max_retries):
            all_objects_length = 10
            try:
                all_objects = driver.findAllObjects({"container": statusDesktop_mainWindow})
                if len(all_objects) > all_objects_length:  # UI appears to be loaded
                    break
                time.sleep(1)
            except Exception:
                raise Exception(f"all_objects did not reach {all_objects_length} after {max_retries} retries. Shell UI may not be fully loaded.")
        return self

