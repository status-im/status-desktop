import typing

import driver
from gui.elements.base_object import QObject


class Button(QObject):

    def click(
            self,
            x: typing.Union[int, driver.UiTypes.ScreenPoint] = None,
            y: typing.Union[int, driver.UiTypes.ScreenPoint] = None,
            button: driver.MouseButton = None
    ):
        if None not in (x, y, button):
            getattr(self.object, 'clicked')()
        else:
            self.click(x, y, button)
