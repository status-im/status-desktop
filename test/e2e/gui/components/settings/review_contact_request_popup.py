import allure

import configs
from gui.components.base_popup import BasePopup
from gui.elements.button import Button
from gui.objects_map import names


class AcceptRequestFromProfile(BasePopup):

    def __init__(self):
        super().__init__()
        self._accept_button = Button(names.accept_StatusButton)
        self._ignore_button = Button(names.ignore_StatusFlatButton)

    @allure.step('Wait until appears {0}')
    def wait_until_appears(self, timeout_msec: int = configs.timeouts.UI_LOAD_TIMEOUT_MSEC):
        self._accept_button.wait_until_appears(timeout_msec)
        return self

    @allure.step('Accept contact request')
    def accept(self):
        self._accept_button.click()

    @allure.step('Decline contact request')
    def decline(self):
        self._ignore_button.click()
