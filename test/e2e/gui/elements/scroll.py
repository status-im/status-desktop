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
            self.object.scrollPageDown()
            time.sleep(0.1)
            if time.monotonic() - started_at > timeout_sec:
                raise LookupError(f'Object not found: {element}')

    @allure.step('Scroll vertical up to object {1}')
    def vertical_scroll_up(self, element: QObject, timeout_sec: int = 5):
        started_at = time.monotonic()
        while not element.is_visible:
            self.object.scrollPageUp()
            time.sleep(0.1)
            if time.monotonic() - started_at > timeout_sec:
                raise LookupError(f'Object not found: {element}')

    @allure.step('Scroll vertical to object {1}')
    def old_vertical_scroll_to(self, element: QObject, timeout_sec: int = 5):
        started_at = time.monotonic()
        step = 10
        direction = 1
        while not element.is_visible:
            step *= 2
            direction *= -1
            driver.flick(self.object, 0, step * direction)
            time.sleep(0.1)
            if time.monotonic() - started_at > timeout_sec:
                raise LookupError(f'Object not found: {element}')
        try:
            if hasattr(element.object, 'y'):
                y = int(element.object.y)
                if hasattr(element.object, 'height'):
                    y += int(element.object.height)
                driver.flick(self.object, 0, y)
                LOG.info('%s: scrolled to %s', self, element)
        except LookupError as err:
            LOG.error(err)

    @allure.step('Scroll down to object')
    def vertical_down_to(self, element: QObject, timeout_sec: int = 5):
        started_at = time.monotonic()
        step = 100
        while not element.is_visible:
            driver.flick(self.object, 0, step)
            if time.monotonic() - started_at > timeout_sec:
                raise LookupError(f'Object not found: {element}')
            LOG.info('%s: scrolled down to %s', self, element)
