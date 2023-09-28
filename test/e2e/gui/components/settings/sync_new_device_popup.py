import allure
import pyperclip

from gui.components.base_popup import BasePopup
from gui.elements.qt.button import Button
from gui.elements.qt.text_edit import TextEdit


class SyncNewDevicePopup(BasePopup):

    def __init__(self):
        super().__init__()
        self._copy_button = Button('copy_SyncCodeStatusButton')
        self._done_button = Button('done_SyncCodeStatusButton')
        self._sync_code_field = TextEdit('syncCodeInput_StatusPasswordInput')

    @property
    @allure.step('Get syncing code')
    def syncing_code(self):
        self._copy_button.click()
        return pyperclip.paste()

    @allure.step('Click done')
    def done(self):
        self._done_button.click()
        self.wait_until_hidden()
