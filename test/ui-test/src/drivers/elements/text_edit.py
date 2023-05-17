import configs
import squish

from .base_element import BaseElement


class TextEdit(BaseElement):

    @property
    def text(self) -> str:
        return str(self.object.text)

    @text.setter
    def text(self, value: str):
        self.clear()
        self.type_text(value)
        assert squish.waitFor(lambda: self.text == value, configs.squish.UI_LOAD_TIMEOUT_MSEC), \
            f'Type text failed, value in field: "{self.text}", expected: {value}'

    def type_text(self, value: str):
        self.click()
        squish.type(self.object, value)
        return self

    def clear(self, verify: bool = True):
        self.object.clear()
        if verify:
            assert squish.waitFor(lambda: not self.text, configs.squish.UI_LOAD_TIMEOUT_MSEC), \
                f'Field did not cleared, value in field: "{self.text}"'
        return self
