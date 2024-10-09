import allure

import driver
from gui.elements.object import QObject
from gui.objects_map import names


class BasePopup(QObject):

    def __init__(self):
        super(BasePopup, self).__init__(names.statusDesktop_mainWindow_overlay)

    @allure.step('Close')
    def close(self):
        driver.type(self.object, '<Escape>')
