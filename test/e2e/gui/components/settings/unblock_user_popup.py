import allure

import configs
from gui.components.base_popup import BasePopup
from gui.elements.button import Button
from gui.elements.text_label import TextLabel
from gui.objects_map import names


class UnblockUserPopup(BasePopup):

    def __init__(self):
        super().__init__()
        self._unblock_user_button = Button(names.unblock_StatusButton)
        self._cancel_button = Button(names.cancel_StatusButton)
        self._unblock_text = TextLabel(names.unblockingText_StatusBaseText)


    @allure.step('Wait until appears {0}')
    def wait_until_appears(self, timeout_msec: int = configs.timeouts.UI_LOAD_TIMEOUT_MSEC):
        self._unblock_user_button.wait_until_appears(timeout_msec)
        return self

    @allure.step('Unblock user')
    def unblock(self):
        self._unblock_user_button.click()

    @allure.step('Get warning text')
    def get_warning_text(self) -> str:
        return self._unblock_text.text
