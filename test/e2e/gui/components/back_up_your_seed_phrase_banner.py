import allure

from gui.elements.button import Button
from gui.elements.object import QObject
from gui.objects_map import names


class BackUpSeedPhraseBanner(QObject):
    def __init__(self):
        super().__init__(names.mainWindow_secureYourSeedPhraseBanner_ModuleWarning)
        self.back_up_seed_banner = QObject(names.mainWindow_secureYourSeedPhraseBanner_ModuleWarning)
        self.back_up_seed_button = Button(names.mainWindow_secureYourSeedPhraseBanner_Button)

