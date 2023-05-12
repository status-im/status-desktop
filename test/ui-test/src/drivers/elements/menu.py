import configs
import squish

from .base_element import BaseElement


class Menu(BaseElement):

    def select(self, menu_item: str):
        squish.activateItem(squish.waitForObjectItem(self.object_name, menu_item, configs.squish.UI_LOAD_TIMEOUT_MSEC))
        self.wait_until_hidden()
