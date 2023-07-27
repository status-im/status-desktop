import logging

import driver
from gui.elements.base_object import BaseObject

_logger = logging.getLogger(__name__)


class NativeObject(BaseObject):

    def __init__(self, name: str):
        super().__init__(name)

    @property
    def object(self):
        return driver.atomacos.wait_for_object(self.real_name)

    @property
    def is_visible(self):
        try:
            return self.object is not None
        except LookupError as err:
            _logger.debug(err)
            return False

    @property
    def bounds(self):
        return self.object.AXFrame

    @property
    def width(self) -> int:
        return int(self.object.AXSize.width)

    @property
    def height(self) -> int:
        return int(self.object.AXSize.height)

    @property
    def center(self):
        return self.bounds.center()
