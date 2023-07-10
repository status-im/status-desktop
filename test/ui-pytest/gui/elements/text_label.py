from gui.elements.base_element import BaseElement


class TextLabel(BaseElement):

    @property
    def text(self) -> str:
        return str(self._object.text)
