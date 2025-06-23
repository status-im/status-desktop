import allure

from gui.elements.object import QObject
from gui.objects_map.names import statusDesktop_mainWindow


class MarketScreen(QObject):

    def __init__(self):
        # TODO: Using main window as container until we have specific market locators
        super().__init__(statusDesktop_mainWindow)

    @allure.step('Wait until Market screen appears')
    def wait_until_appears(self, timeout_msec: int = 10000):
        """Wait for Market screen to appear"""
        super().wait_until_appears(timeout_msec)
        return self 