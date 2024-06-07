import allure

import configs
from gui.components.base_popup import BasePopup
from gui.elements.button import Button
from gui.objects_map import names


class BuildShowcasePopup(BasePopup):

    def __init__(self):
        super().__init__()
        self._build_your_showcase_button = Button(names.build_your_showcase_StatusButton)
        self._close_button = Button(names.closeCrossPopupButton)

    @allure.step('Wait until appears {0}')
    def wait_until_appears(self, timeout_msec: int = configs.timeouts.UI_LOAD_TIMEOUT_MSEC):
        self._build_your_showcase_button.wait_until_appears(timeout_msec)
        return self

    @allure.step('Close build showcase popup')
    def close(self):
        self._close_button.click()
        self.wait_until_hidden()
