import logging

import allure

import driver
from gui.elements.base_object import BaseObject

_logger = logging.getLogger(__name__)


class NativeObject(BaseObject):

    def __init__(self, name: str):
        super().__init__(name)

    @property
    @allure.step('Get object {0}')
    def object(self):
        return driver.atomacos.wait_for_object(self.real_name)

    @property
    @allure.step('Get visible {0}')
    def is_visible(self):
        try:
            return self.object is not None
        except (LookupError, ValueError) as err:
            _logger.debug(err)
            return False

    @property
    @allure.step('Get bounds {0}')
    def bounds(self):
        return self.object.AXFrame

    @property
    @allure.step('Get width {0}')
    def width(self) -> int:
        return int(self.object.AXSize.width)

    @property
    @allure.step('Get height {0}')
    def height(self) -> int:
        return int(self.object.AXSize.height)

    @property
    @allure.step('Get central coordinate {0}')
    def center(self):
        return self.bounds.center()
