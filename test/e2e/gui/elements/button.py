import typing

import allure

import driver
from gui.elements.object import QObject


class Button(QObject):

    @allure.step('Click {0}')
    def click(
            self,
            x: typing.Union[int, driver.UiTypes.ScreenPoint] = None,
            y: typing.Union[int, driver.UiTypes.ScreenPoint] = None,
            button: driver.MouseButton = None
    ):
        if None not in (x, y, button):
            getattr(self.object, 'clicked')()
        else:
            super(Button, self).click(x, y, button)
