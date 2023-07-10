import typing

import driver
from gui.elements.base_element import BaseElement


class Button(BaseElement):

    def click(
            self,
            x: typing.Union[int, driver.UiTypes.ScreenPoint] = None,
            y: typing.Union[int, driver.UiTypes.ScreenPoint] = None,
            button: driver.MouseButton = None
    ):
        if None not in (x, y, button):
            getattr(self._object, 'clicked')()
        else:
            self._click(x, y, button)
