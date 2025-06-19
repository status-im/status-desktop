import logging
import time

import allure

import driver
from gui.elements.object import QObject
from gui.objects_map import names

LOG = logging.getLogger(__name__)


class BasePopup(QObject):

    def __init__(self):
        super().__init__(names.basePopupItem)
        self.wait_until_enabled()

    @allure.step('Wait until enabled {0}')
    def wait_until_enabled(self, timeout_msec: int = 2000, check_interval=0.5):
        timeout_sec = timeout_msec / 1000
        start_time = time.time()

        while time.time() - start_time < timeout_sec:
            try:
                if self.is_enabled:
                    LOG.info('%s: is opened and enabled', self)
                    return self
            except Exception as e:
                LOG.warning("Exception during visibility check: %s", e)
            time.sleep(check_interval)

        LOG.error(f'Object {self} is not enabled within {timeout_msec} ms')
        raise TimeoutError(f'Object {self} is not enabled within {timeout_msec} ms')

    @allure.step('Close')
    def close(self):
        driver.type(self.object, '<Escape>')
