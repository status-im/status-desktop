import logging
import time

import driver
from gui import objects_map

_logger = logging.getLogger(__name__)


class BaseElement:

    def __init__(self, name: str):
        self.symbolic_name = name
        self.real_name = getattr(objects_map, name)

    def __str__(self):
        return f'{type(self).__qualname__}({self.symbolic_name})'

    @property
    def _object(self):
        return driver.waitForObject(self.real_name, driver.settings.UI_LOAD_TIMEOUT_MSEC)

    @property
    def _entity(self):
        return driver.waitForObjectExists(self.real_name)

    @property
    def _exists(self) -> bool:
        return driver.object.exists(self.real_name)

    @property
    def _bounds(self):
        return driver.object.globalBounds(self._object)

    @property
    def _width(self) -> int:
        return int(self._bounds.width)

    @property
    def _height(self) -> int:
        return int(self._bounds.height)

    @property
    def _center(self):
        return self._bounds.center()

    @property
    def _is_enabled(self) -> bool:
        return self._object.enabled

    @property
    def _is_selected(self) -> bool:
        return self._object.selected

    @property
    def _is_checked(self) -> bool:
        return self._object.checked

    @property
    def _is_visible(self) -> bool:
        try:
            return driver.waitForObject(self.real_name, 0).visible
        except (AttributeError, LookupError, RuntimeError):
            return False

    def _click(
            self,
            x: int = None,
            y: int = None,
            button=None
    ):
        driver.mouseClick(
            self._object,
            x or self._width // 2,
            y or self._height // 2,
            button or driver.Qt.LeftButton
        )

    def _hover(self, timeout_msec: int = driver.settings.UI_LOAD_TIMEOUT_MSEC):
        def __hover():
            try:
                driver.mouseMove(self._object)
                return getattr(self._object, 'hovered', True)
            except RuntimeError as err:
                _logger.info(err)
                time.sleep(1)
                return False

        assert driver.waitFor(lambda: __hover(), timeout_msec)

    def _wait_until_appears(self, timeout_msec: int = driver.settings.UI_LOAD_TIMEOUT_MSEC):
        assert driver.waitFor(lambda: self._is_visible, timeout_msec), f'Object {self} is not visible'
        return self

    def _wait_until_hidden(self, timeout_msec: int = driver.settings.UI_LOAD_TIMEOUT_MSEC):
        assert driver.waitFor(lambda: not self._is_visible, timeout_msec), f'Object {self} is not hidden'

    def _wait_for(self, condition, timeout_msec: int = driver.settings.UI_LOAD_TIMEOUT_MSEC) -> bool:
        return driver.waitFor(lambda: condition, timeout_msec)
