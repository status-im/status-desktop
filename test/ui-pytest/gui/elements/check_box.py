import driver
from gui.elements.base_element import BaseElement


class CheckBox(BaseElement):

    def set(self, value: bool, x: int = None, y: int = None):
        if self._is_checked is not value:
            self._click(x, y)
            assert driver.waitFor(
                lambda: self._is_checked is value, driver.settings.UI_LOAD_TIMEOUT_MSEC), 'Value not changed'
