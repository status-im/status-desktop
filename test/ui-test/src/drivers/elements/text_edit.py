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
        assert squish.waitFor(lambda: self.text == value)

    def type_text(self, value: str):
        self.click()
        squish.type(self.object, value)
        assert squish.waitFor(lambda: self.text == value), \
            f'Type text failed, value in field: "{self.text}", expected: {value}'
        return self

    def clear(self):
        self.object.clear()
        assert squish.waitFor(lambda: not self.text), \
            f'Field did not cleared, value in field: "{self.text}"'
        return self
