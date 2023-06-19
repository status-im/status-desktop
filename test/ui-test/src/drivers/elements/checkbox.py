import configs
import squish

from .base_element import BaseElement


class CheckBox(BaseElement):

    def set(self, value: bool, x: int = None, y: int = None):
        if self.is_checked is not value:
            self.click(x, y)
            assert squish.waitFor(
                lambda: self.is_checked is value, configs.squish.UI_LOAD_TIMEOUT_MSEC), 'Value has not been changed'
