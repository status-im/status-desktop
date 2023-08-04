import allure

from gui.elements.qt.object import QObject


class TextLabel(QObject):

    @property
    @allure.step('Get text {0}')
    def text(self) -> str:
        return str(self.object.text)
