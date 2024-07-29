import allure

import configs
from gui.components.base_popup import BasePopup
from gui.elements.button import Button
from gui.objects_map import names


class BanMemberPopup(BasePopup):

    def __init__(self):
        super().__init__()
        self._ban_confirm_button = Button(names.ban_StatusButton)

    @allure.step('Wait until appears {0}')
    def wait_until_appears(self, timeout_msec: int = configs.timeouts.UI_LOAD_TIMEOUT_MSEC):
        self._ban_confirm_button.wait_until_appears(timeout_msec)
        return self

    @allure.step('Confirm banning member')
    def confirm_banning(self):
        self._ban_confirm_button.click()
        