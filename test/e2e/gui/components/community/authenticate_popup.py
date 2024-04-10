import allure

import configs
from gui.components.base_popup import BasePopup
from gui.elements.button import Button
from gui.elements.object import QObject
from gui.elements.text_edit import TextEdit
from gui.objects_map import names


class AuthenticatePopup(BasePopup):

    def __init__(self):
        super().__init__()
        self._content = QObject(names.keycardSharedPopupContent_KeycardPopupContent)
        self._password_text_edit = TextEdit(names.password_PlaceholderText)
        self._authenticate_button = Button(names.authenticate_StatusButton)
        self._close_button = Button(names.headerCloseButton_StatusFlatRoundButton)

    @allure.step('Wait until appears {0}')
    def wait_until_appears(self, timeout_msec: int = configs.timeouts.UI_LOAD_TIMEOUT_MSEC):
        self._content.wait_until_appears(timeout_msec)
        return self

    @allure.step('Authenticate actions with password {0}')
    def authenticate(self, password: str):
        self._password_text_edit.type_text(password)
        self._authenticate_button.click()
        self._authenticate_button.wait_until_hidden(8000)

    @allure.step('Close authenticate popup by close button')
    def close_authenticate_popup(self):
        self._close_button.click()
