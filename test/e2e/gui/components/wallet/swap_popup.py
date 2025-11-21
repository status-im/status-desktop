from gui.elements.object import QObject
from gui.objects_map import names


class SwapPopup(QObject):
    def __init__(self):
        super().__init__(names.swapPopup)
