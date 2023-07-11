import logging
import time

import configs
import driver
from gui import objects_map
from scripts.tools.capture.image import Image

_logger = logging.getLogger(__name__)


class QObject:

    def __init__(self, name: str):
        self.symbolic_name = name
        self.real_name = getattr(objects_map, name)
        self._image = Image(self.real_name)

    def __str__(self):
        return f'{type(self).__qualname__}({self.symbolic_name})'

    def __getattr__(self, attr: str):
        try:
            return getattr(driver.waitForObjectExists(self.real_name, 1000), attr, False)
        except (AttributeError, LookupError, RuntimeError):
            return False

    @property
    def object(self):
        return driver.waitForObject(self.real_name, configs.timeouts.UI_LOAD_TIMEOUT_MSEC)

    @property
    def exists(self) -> bool:
        return driver.object.exists(self.real_name)

    @property
    def bounds(self):
        return driver.object.globalBounds(self.object)

    @property
    def width(self) -> int:
        return int(self.bounds.width)

    @property
    def height(self) -> int:
        return int(self.bounds.height)

    @property
    def center(self):
        return self.bounds.center()

    @property
    def is_enabled(self) -> bool:
        return getattr(self, 'enabled')

    @property
    def is_selected(self) -> bool:
        return getattr(self, 'selected')

    @property
    def is_checked(self) -> bool:
        return getattr(self, 'checked')

    @property
    def is_visible(self) -> bool:
        return getattr(self, 'visible')

    @property
    def image(self):
        if self._image.view is None:
            self._image.update_view()
        return self._image

    def click(
            self,
            x: int = None,
            y: int = None,
            button=None
    ):
        driver.mouseClick(
            self.object,
            x or self.width // 2,
            y or self.height // 2,
            button or driver.Qt.LeftButton
        )

    def hover(self, timeout_msec: int = configs.timeouts.UI_LOAD_TIMEOUT_MSEC):
        def _hover():
            try:
                driver.mouseMove(self.object)
                return getattr(self, 'hovered', True)
            except RuntimeError as err:
                _logger.info(err)
                time.sleep(1)
                return False

        assert driver.waitFor(lambda: _hover(), timeout_msec)

    def wait_until_appears(self, timeout_msec: int = configs.timeouts.UI_LOAD_TIMEOUT_MSEC):
        assert driver.waitFor(lambda: self.is_visible, timeout_msec), f'Object {self} is not visible'
        return self

    def wait_until_hidden(self, timeout_msec: int = configs.timeouts.UI_LOAD_TIMEOUT_MSEC):
        assert driver.waitFor(lambda: not self.is_visible, timeout_msec), f'Object {self} is not hidden'

    def wait_for(self, condition, timeout_msec: int = configs.timeouts.UI_LOAD_TIMEOUT_MSEC) -> bool:
        return driver.waitFor(lambda: condition, timeout_msec)
