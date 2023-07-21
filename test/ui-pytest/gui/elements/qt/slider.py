from gui.elements.qt.object import QObject


class Slider(QObject):

    @property
    def min(self) -> int:
        return int(getattr(self, 'from', 0))

    @property
    def max(self) -> max:
        return int(getattr(self, 'to', 0))

    @property
    def value(self) -> int:
        return int(self.object.value)

    @value.setter
    def value(self, value: int):
        if value != self.value:
            if self.min <= value <= self.max:
                if self.value < value:
                    while self.value < value:
                        self.object.increase()
                if self.value > value:
                    while self.value > value:
                        self.object.decrease()
