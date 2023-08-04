import logging

import allure

import configs
import driver
from gui import objects_map

_logger = logging.getLogger(__name__)


class BaseObject:

    def __init__(self, name: str):
        self.symbolic_name = name
        self.real_name = getattr(objects_map, name)

    def __str__(self):
        return f'{type(self).__qualname__}({self.symbolic_name})'

    def __repr__(self):
        return f'{type(self).__qualname__}({self.symbolic_name})'

    @property
    def object(self):
        raise NotImplementedError

    @property
    def is_visible(self) -> bool:
        raise NotImplementedError

    @allure.step('Wait until appears {0}')
    def wait_until_appears(self, timeout_msec: int = configs.timeouts.UI_LOAD_TIMEOUT_MSEC):
        assert driver.waitFor(lambda: self.is_visible, timeout_msec), f'Object {self} is not visible'
        return self

    @allure.step('Wait until hidden {0}')
    def wait_until_hidden(self, timeout_msec: int = configs.timeouts.UI_LOAD_TIMEOUT_MSEC):
        assert driver.waitFor(lambda: not self.is_visible, timeout_msec), f'Object {self} is not hidden'

    @classmethod
    def wait_for(cls, condition, timeout_msec: int = configs.timeouts.UI_LOAD_TIMEOUT_MSEC) -> bool:
        return driver.waitFor(lambda: condition, timeout_msec)
