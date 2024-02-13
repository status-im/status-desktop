from gui.elements.button import Button
from gui.elements.object import QObject
from gui.objects_map import names


class TestnetModeBanner(QObject):
    def __init__(self):
        super(TestnetModeBanner, self).__init__(names.mainWindow_testnetBanner_ModuleWarning)
        self._turn_off_button = Button(names.mainWindow_Turn_off_Button)
