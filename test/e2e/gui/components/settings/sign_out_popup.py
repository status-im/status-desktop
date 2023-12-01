import allure

from gui.components.base_popup import BasePopup
from gui.elements.button import Button


class SignOutPopup(BasePopup):

    def __init__(self):
        super().__init__()
        self._sign_out_and_quit_button = Button('signOutConfirmationButton')

    @allure.step('Click sign out and quit button')
    def sign_out_and_quit(self):
        self._sign_out_and_quit_button.click()