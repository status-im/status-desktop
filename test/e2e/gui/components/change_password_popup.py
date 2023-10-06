import allure

from gui.components.base_popup import BasePopup
from gui.elements.button import Button
from gui.elements.text_edit import TextEdit


class ChangePasswordPopup(BasePopup):

    def __init__(self):
        super(ChangePasswordPopup, self).__init__()
        self._current_password_text_field = TextEdit('change_password_menu_current_password')
        self._new_password_text_field = TextEdit('change_password_menu_new_password')
        self._confirm_password_text_field = TextEdit('change_password_menu_new_password_confirm')
        self._submit_button = Button('change_password_menu_submit_button')
        self._quit_button = Button('change_password_success_menu_sign_out_quit_button')

    @allure.step('Change password and confirm action')
    def change_password(self, old_pwd: str, new_pwd: str):
        self._current_password_text_field.text = old_pwd
        self._new_password_text_field.text = new_pwd
        self._confirm_password_text_field.text = new_pwd
        self._submit_button.click()
        self._quit_button.wait_until_appears(15000).click()
