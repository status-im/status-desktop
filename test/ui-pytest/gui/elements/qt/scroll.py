import time

import allure

import driver
from .object import QObject


class Scroll(QObject):

    @allure.step('Scroll vertical to object')
    def vertical_scroll_to(self, element: QObject, timeout_sec: int = 5):
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
        if hasattr(element.object, 'y'):
            driver.flick(self.object, 0, int(element.object.y))

    @allure.step('Scroll down to object')
    def vertical_down_to(self, element: QObject, timeout_sec: int = 5):
        started_at = time.monotonic()
        step = 100
        while not element.is_visible:
            driver.flick(self.object, 0, step)
            if time.monotonic() - started_at > timeout_sec:
                raise LookupError(f'Object not found: {element}')
