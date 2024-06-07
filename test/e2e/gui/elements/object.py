import logging
import time
import typing

import allure

import configs
import driver
from driver import isFrozen
from scripts.tools.image import Image

LOG = logging.getLogger(__name__)


class QObject:

    def __init__(self, real_name: [str, dict] = None):
        self.real_name = real_name
        self._image = Image(self.real_name)

    @property
    @allure.step('Get object {0}')
    def object(self):
        return driver.waitForObject(self.real_name, configs.timeouts.UI_LOAD_TIMEOUT_MSEC)

    @property
    @allure.step('Get object exists {0}')
    def exists(self) -> bool:
        return driver.object.exists(self.real_name)

    @property
    @allure.step('Get bounds {0}')
    def bounds(self):
        return driver.object.globalBounds(self.object)

    @property
    @allure.step('Get "x" coordinate {0}')
    def x(self) -> int:
        return self.bounds.x

    @property
    @allure.step('Get "y" coordinate {0}')
    def y(self) -> int:
        return self.bounds.y

    @property
    @allure.step('Get width {0}')
    def width(self) -> int:
        return int(self.bounds.width)

    @property
    @allure.step('Get height {0}')
    def height(self) -> int:
        return int(self.bounds.height)

    @property
    @allure.step('Get central coordinate {0}')
    def center(self):
        return self.bounds.center()

    @property
    @allure.step('Get enabled {0}')
    def is_enabled(self) -> bool:
        return getattr(self.object, 'enabled')

    @property
    @allure.step('Get selected {0}')
    def is_selected(self) -> bool:
        return getattr(self.object, 'selected')

    @property
    @allure.step('Get checked {0}')
    def is_checked(self) -> bool:
        return getattr(self.object, 'checked')

    @property
    @allure.step('Get visible {0}')
    def is_visible(self) -> bool:
        try:
            return driver.waitForObject(self.real_name, 0).visible
        except (AttributeError, LookupError, RuntimeError):
            return False

    @property
    @allure.step('Get image {0}')
    def image(self):
        self._image.update_view()
        return self._image

    @allure.step('Click {0}')
    def click(
            self,
            x: int = None,
            y: int = None,
            button=None,
    ):
        driver.mouseClick(
            self.object,
            x or int(self.object.width * 0.1),
            y or int(self.object.height * 0.1),
            button or driver.Qt.LeftButton
        )
        LOG.info('%s: is clicked with Qt.LeftButton', self)

    @allure.step('Native click {0}')
    def native_mouse_click(
            self,
            x: typing.Union[int, driver.UiTypes.ScreenPoint] = None,
            y: typing.Union[int, driver.UiTypes.ScreenPoint] = None,
            button: driver.MouseButton = None
    ):
        driver.nativeMouseClick(
            x or int(self.bounds.x + self.width // 2),
            y or int(self.bounds.y + self.height // 2),
            button or driver.MouseButton.LeftButton
        )
        LOG.info(f'{self}: native clicked')

    @allure.step('Hover {0}')
    def hover(self, timeout_msec: int = configs.timeouts.UI_LOAD_TIMEOUT_MSEC):
        def _hover():
            try:
                driver.mouseMove(self.object)
                LOG.info('%s: mouse hovered', self)
                return getattr(self.object, 'hovered', True)
            except RuntimeError as err:
                LOG.error(err)
                time.sleep(1)
                return False

        assert driver.waitFor(lambda: _hover(), timeout_msec)
        return self

    @allure.step('Right click on {0}')
    def right_click(
            self,
            x: typing.Union[int, driver.UiTypes.ScreenPoint] = None,
            y: typing.Union[int, driver.UiTypes.ScreenPoint] = None,
    ):
        self.click(
            x or int(self.width // 2),
            y or int(self.height // 2),
            driver.Qt.RightButton
        )
        LOG.info('%s: right clicked with Qt.RightButton', self)

    @allure.step('Wait until appears {0}')
    def wait_until_appears(self, timeout_msec: int = configs.timeouts.UI_LOAD_TIMEOUT_MSEC):
        assert driver.waitFor(lambda: self.is_visible, timeout_msec), f'Object {self} is not visible'
        LOG.info('%s: is visible', self)
        return self

    @allure.step('Wait until hidden {0}')
    def wait_until_hidden(self, timeout_msec: int = configs.timeouts.UI_LOAD_TIMEOUT_MSEC):
        assert driver.waitFor(lambda: not self.is_visible, timeout_msec), f'Object {self} is not hidden'
        LOG.info('%s: is hidden', self)

    @classmethod
    def wait_for(cls, condition, timeout_msec: int = configs.timeouts.UI_LOAD_TIMEOUT_MSEC) -> bool:
        return driver.waitFor(lambda: condition, timeout_msec)
