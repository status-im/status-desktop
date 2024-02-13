import allure

from gui.elements.button import Button
from gui.elements.object import QObject
from gui.elements.text_edit import TextEdit
from gui.objects_map import names


class AuthenticatePopup(QObject):

    def __init__(self):
        super(AuthenticatePopup, self).__init__(names.contextMenu_PopupItem)
        self._password_text_edit = TextEdit(names.sharedPopup_Password_Input)
        self._primary_button = Button(names.sharedPopup_Primary_Button)

    @allure.step('Authenticate action with password')
    def authenticate(self, password: str, attempt: int = 2):
        self._password_text_edit.text = password
        self._primary_button.click()
        try:
            self._primary_button.wait_until_hidden()
        except AssertionError as err:
            if attempt:
                self.authenticate(password, attempt - 1)
            else:
                raise err

    @allure.step('Check if authenticate button is present')
    def is_authenticate_button_visible(self):
        return self._primary_button.is_visible

