import allure

from gui.elements.button import Button
from gui.elements.text_edit import TextEdit
from gui.elements.object import QObject


class AuthenticatePopup(QObject):

    def __init__(self):
        super(AuthenticatePopup, self).__init__('contextMenu_PopupItem')
        self._password_text_edit = TextEdit('sharedPopup_Password_Input')
        self._primary_button = Button('sharedPopup_Primary_Button')

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
