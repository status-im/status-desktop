import allure

import configs
from gui.elements.object import QObject
from gui.objects_map import names


class SplashScreen(QObject):

    def __init__(self):
        super().__init__(names.splashScreen)
        self.splash_screen = QObject(names.splashScreen)

