import logging

import allure

from gui.components.user_canvas import UserCanvas
from gui.elements.qt.button import Button
from gui.elements.qt.object import QObject
from gui.elements.qt.window import Window

_logger = logging.getLogger(__name__)


class LeftPanel(QObject):

    def __init__(self):
        super(LeftPanel, self).__init__('mainWindow_StatusAppNavBar')
        self._profile_button = Button('mainWindow_ProfileNavBarButton')

    @property
    @allure.step('Get user badge color')
    def user_badge_color(self) -> str:
        return str(self._profile_button.object.badge.color.name)

    @allure.step('Open user canvas')
    def open_user_canvas(self) -> UserCanvas:
        self._profile_button.click()
        return UserCanvas().wait_until_appears()

    @allure.step('Verify: User is online')
    def user_is_online(self) -> bool:
        return self.user_badge_color == '#4ebc60'

    @allure.step('Verify: User is offline')
    def user_is_offline(self):
        return self.user_badge_color == '#7f8990'

    @allure.step('Verify: User is set to automatic')
    def user_is_set_to_automatic(self):
        return self.user_badge_color == '#4ebc60'


class MainWindow(Window):

    def __init__(self):
        super(MainWindow, self).__init__('statusDesktop_mainWindow')
        self.left_panel = LeftPanel()
