import driver
from .object import NativeObject


class TextEdit(NativeObject):

    @property
    def text(self) -> str:
        return str(self.object.AXValue)

    @text.setter
    def text(self, value: str):
        self.object.setString('AXValue', value)
        driver.waitFor(lambda: self.text == value)
