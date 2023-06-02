import constants
from drivers.SquishDriver import *


class AuthenticatePopup(BaseElement):

    def __init__(self):
        super(AuthenticatePopup, self).__init__('contextMenu_PopupItem')
        self._password_text_edit = TextEdit('sharedPopup_Password_Input')
        self._primary_button = Button('sharedPopup_Primary_Button')
        self._cancel_buttom = Button('sharedPopup_Cancel_Button')

    def authenticate(self, password: str = constants.user_account.PASSWORD, attempt: int = 2):
        self._password_text_edit.text = password
        self._primary_button.click()
        try:
            self._primary_button.wait_until_hidden()
        except AssertionError as err:
            if attempt:
                self.authenticate(password, attempt-1)
            else:
                raise err

    def cancel(self):
        self._cancel_buttom.click()
        self._cancel_buttom.wait_until_hidden()
