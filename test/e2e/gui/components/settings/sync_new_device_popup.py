import allure
import pyperclip

from gui.components.base_popup import BasePopup
from gui.elements.button import Button
from gui.elements.object import QObject
from gui.elements.text_edit import TextEdit


class SyncNewDevicePopup(BasePopup):

    def __init__(self):
        super().__init__()
        self._copy_button = Button('copy_SyncCodeStatusButton')
        self._done_button = Button('done_SyncCodeStatusButton')
        self._sync_code_field = TextEdit('syncCodeInput_StatusPasswordInput')
        self._close_button = Button('close_StatusButton')
        self._error_message = QObject('errorView_SyncingErrorMessage')

    @property
    @allure.step('Get primary error message')
    def primary_error_message(self) -> str:
        return str(self._error_message.object.primaryText)

    @property
    @allure.step('Get secondary error message')
    def secondary_error_message(self) -> str:
        return str(self._error_message.object.secondaryText)

    @property
    @allure.step('Get syncing code')
    def syncing_code(self):
        self._copy_button.click()
        return pyperclip.paste()

    @allure.step('Click done')
    def done(self):
        self._done_button.click()
        self.wait_until_hidden()

    @allure.step('Click close')
    def close(self):
        self._close_button.click()
        self.wait_until_hidden()
