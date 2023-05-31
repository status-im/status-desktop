import time

import squish

from .base_element import BaseElement


class Scroll(BaseElement):

    def vertical_scroll_to(self, element: BaseElement, timeout_sec: int = 5):
        started_at = time.monotonic()
        step = 10
        direction = 1
        while not element.is_visible:
            step *= 2
            direction *= -1
            squish.flick(self.object.flickable, 0, step * direction)
            time.sleep(0.1)
            if time.monotonic() - started_at > timeout_sec:
                raise LookupError(f'Object not found: {element.object_name}')

    def vertical_down_to(self, element: BaseElement, timeout_sec: int = 5):
        started_at = time.monotonic()
        step = 100
        while not element.is_visible:
            squish.flick(self.object.flickable, 0, step)
            if time.monotonic() - started_at > timeout_sec:
                raise LookupError(f'Object not found: {element.object_name}')
