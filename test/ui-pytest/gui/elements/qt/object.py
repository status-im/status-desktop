import logging
import time

import configs
import driver
from gui.elements.base_object import BaseObject
from scripts.tools.image import Image

_logger = logging.getLogger(__name__)


class QObject(BaseObject):

    def __init__(self, name: str):
        super().__init__(name)
        self._image = Image(self.real_name)

    def __str__(self):
        return f'{type(self).__qualname__}({self.symbolic_name})'

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
    def x(self) -> int:
        return self.bounds.x

    @property
    def y(self) -> int:
        return self.bounds.y

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
        return self.object.enabled

    @property
    def is_selected(self) -> bool:
        return self.object.selected

    @property
    def is_checked(self) -> bool:
        return self.object.checked

    @property
    def is_visible(self) -> bool:
        try:
            return driver.waitForObject(self.real_name, 0).visible
        except (AttributeError, LookupError, RuntimeError):
            return False

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
                return getattr(self.object, 'hovered', True)
            except RuntimeError as err:
                _logger.debug(err)
                time.sleep(1)
                return False

        assert driver.waitFor(lambda: _hover(), timeout_msec)
