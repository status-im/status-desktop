import allure

import configs
from gui.elements.object import QObject
from gui.objects_map import names


class SplashScreen(QObject):

    def __init__(self):
        super(SplashScreen, self).__init__(names.splashScreen)

    @allure.step('Wait until appears {0}')
    def wait_until_appears(self, timeout_msec: int = configs.timeouts.UI_LOAD_TIMEOUT_MSEC):
        assert self.wait_for(lambda: self.exists, timeout_msec), f'Object {self} is not visible'
        return self

    @allure.step('Wait until hidden {0}')
    def wait_until_hidden(self, timeout_msec: int = configs.timeouts.APP_LOAD_TIMEOUT_MSEC):
        super().wait_until_hidden(timeout_msec)
