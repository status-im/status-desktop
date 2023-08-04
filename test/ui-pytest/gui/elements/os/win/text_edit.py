import allure

import configs
import constants
import driver
from .object import NativeObject


class TextEdit(NativeObject):

    @property
    @allure.step('Get current text {0}')
    def text(self) -> str:
        return str(self.object.text)

    @text.setter
    @allure.step('Type: {1} {0}')
    def text(self, value: str):
        self.clear()
        driver.nativeType(value)
        assert driver.waitFor(lambda: self.text == value, configs.timeouts.UI_LOAD_TIMEOUT_MSEC), \
            f'Type text failed, value in field: "{self.text}", expected: {value}'

    @allure.step('Clear {0}')
    def clear(self):
        # Set focus
        driver.nativeMouseClick(int(self.center.x), int(self.center.y), driver.Qt.LeftButton)
        driver.type(self.object, f'<{constants.commands.SELECT_ALL}>')
        driver.type(self.object, f'<{constants.commands.BACKSPACE}>')
        assert driver.waitFor(lambda: not self.text), \
            f'Clear text field failed, value in field: "{self.text}"'
        return self
