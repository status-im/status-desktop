import allure

import configs
import driver
from gui.elements.object import QObject


class CheckBox(QObject):

    @allure.step("Set {0} value: {1}")
    def set(self, value: bool, x: int = None, y: int = None):
        if self.is_checked is not value:
            self.click(x, y)
            assert driver.waitFor(
                lambda: self.is_checked is value, configs.timeouts.UI_LOAD_TIMEOUT_MSEC), 'Value not changed'
