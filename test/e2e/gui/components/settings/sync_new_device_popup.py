import time

import allure
import pyperclip

from gui.components.base_popup import BasePopup
from gui.elements.button import Button
from gui.elements.object import QObject
from gui.elements.text_edit import TextEdit
from gui.objects_map import names


class SyncNewDevicePopup(QObject):

    def __init__(self):
        super().__init__(names.setupSyncingPopup)
        self._copy_button = Button(names.copy_SyncCodeStatusButton)
        self._done_button = Button(names.done_SyncCodeStatusButton)
        self._sync_code_field = TextEdit(names.syncCodeInput_StatusPasswordInput)
        self._close_button = Button(names.close_SyncCodeStatusFlatRoundButton)
        self._error_message = QObject(names.errorView_SyncingErrorMessage)

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
