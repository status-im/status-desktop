from gui.elements.qt.object import QObject


class TextLabel(QObject):

    @property
    def text(self) -> str:
        return str(self.object.text)
