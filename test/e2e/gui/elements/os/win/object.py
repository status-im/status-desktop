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
        return driver.waitForObject(self.real_name)

    @property
    @allure.step('Get visible {0}')
    def is_visible(self):
        try:
            driver.waitForObject(self.real_name, 1)
            return True
        except (AttributeError, LookupError, RuntimeError):
            return False

    @property
    @allure.step('Get bounds {0}')
    def bounds(self):
        return driver.object.globalBounds(self.object)

    @property
    @allure.step('Get central coordinate {0}')
    def center(self):
        return self.bounds.center()

    @allure.step('Click {0}')
    def click(self):
        driver.mouseClick(self.object)
