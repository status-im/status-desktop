import configs
import driver
from gui.elements.base_object import QObject


class TextEdit(QObject):

    @property
    def text(self) -> str:
        return str(self.object.text)

    @text.setter
    def text(self, value: str):
        self.clear()
        self.type_text(value)
        assert driver.waitFor(lambda: self.text == value, configs.timeouts.UI_LOAD_TIMEOUT_MSEC), \
            f'Type text failed, value in field: "{self.text}", expected: {value}'

    def type_text(self, value: str):
        driver.type(self.object, value)
        return self

    def clear(self):
        self.object.clear()
        assert driver.waitFor(lambda: not self.text), \
            f'Clear text field failed, value in field: "{self.text}"'
        return self
