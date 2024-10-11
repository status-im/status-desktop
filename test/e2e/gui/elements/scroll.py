import logging
import time

import allure

import driver
from .object import QObject

LOG = logging.getLogger(__name__)


class Scroll(QObject):

    @allure.step('Scroll vertical down to object {1}')
    def vertical_scroll_down(self, element: QObject, timeout_sec: int = 5):
        started_at = time.monotonic()
        while not element.is_visible:
            driver.mouse.scroll(self.object, self.object.width / 2, self.object.height / 2, 0, -30, 1, 0.1)
            if time.monotonic() - started_at > timeout_sec:
                raise LookupError(f'Object not found: {element}')

    @allure.step('Scroll vertical up to object {1}')
    def vertical_scroll_up(self, element: QObject, timeout_sec: int = 5):
        started_at = time.monotonic()
        while not element.is_visible:
            driver.mouse.scroll(self.object, self.object.width / 2, self.object.height / 2, 0, 30, 1, 0.1)
            if time.monotonic() - started_at > timeout_sec:
                raise LookupError(f'Object not found: {element}')
