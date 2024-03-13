import logging

import allure

import configs
import driver
from gui.elements.object import QObject

LOG = logging.getLogger(__name__)


class CheckBox(QObject):

    @allure.step("Set {0} value: {1}")
    def set(self, value: bool):
        if self.is_checked is not value:
            self.click()
            assert driver.waitFor(
                lambda: self.is_checked is value, configs.timeouts.UI_LOAD_TIMEOUT_MSEC), 'Value not changed'
        LOG.info('%s: value changed to "%s"', self, value)
