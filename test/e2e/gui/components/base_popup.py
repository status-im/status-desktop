import allure

import driver
from gui.elements.object import QObject


class BasePopup(QObject):

    def __init__(self):
        super(BasePopup, self).__init__('statusDesktop_mainWindow_overlay')

    @allure.step('Close')
    def close(self):
        driver.type(self.object, '<Escape>')
        self.wait_until_hidden()
