import allure

from gui.elements.object import QObject
from gui.objects_map.names import statusDesktop_mainWindow


class MarketScreen(QObject):

    def __init__(self):
        # TODO: Add support for Market screen (https://github.com/status-im/status-app/issues/18235)
        super().__init__(statusDesktop_mainWindow)
