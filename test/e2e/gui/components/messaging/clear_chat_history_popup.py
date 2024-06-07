import allure

import configs
from gui.components.base_popup import BasePopup
from gui.elements.button import Button
from gui.objects_map import names


class ClearChatHistoryPopup(BasePopup):

    def __init__(self):
        super().__init__()
        self._clear_button = Button(names.clear_StatusButton)

    @allure.step('Wait until appears {0}')
    def wait_until_appears(self, timeout_msec: int = configs.timeouts.UI_LOAD_TIMEOUT_MSEC):
        self._clear_button.wait_until_appears(timeout_msec)
        return self

    @allure.step("Confirm clearing chat")
    def confirm_clearing_chat(self):
        self._clear_button.click()
        self._clear_button.wait_until_hidden()
