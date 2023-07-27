import logging

import driver
from gui.elements.base_object import BaseObject

_logger = logging.getLogger(__name__)


class NativeObject(BaseObject):

    def __init__(self, name: str):
        super().__init__(name)

    @property
    def object(self):
        return driver.waitForObject(self.real_name)

    @property
    def is_visible(self):
        try:
            driver.waitForObject(self.real_name, 1)
            return True
        except (AttributeError, LookupError, RuntimeError):
            return False

    @property
    def bounds(self):
        return driver.object.globalBounds(self.object)

    @property
    def center(self):
        return self.bounds.center()

    def click(self):
        driver.mouseClick(self.object)
