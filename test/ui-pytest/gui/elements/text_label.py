from gui.elements.base_object import QObject


class TextLabel(QObject):

    @property
    def text(self) -> str:
        return str(self.object.text)
