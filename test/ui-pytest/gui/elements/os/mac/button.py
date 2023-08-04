import allure

from .object import NativeObject


class Button(NativeObject):

    @allure.step('Click {0}')
    def click(self):
        self.object.Press()
