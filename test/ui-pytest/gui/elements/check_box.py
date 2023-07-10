import configs
import driver
from gui.elements.base_object import QObject


class CheckBox(QObject):

    def set(self, value: bool, x: int = None, y: int = None):
        if self.is_checked is not value:
            self.click(x, y)
            assert driver.waitFor(
                lambda: self.is_checked is value, configs.timeouts.UI_LOAD_TIMEOUT_MSEC), 'Value not changed'
