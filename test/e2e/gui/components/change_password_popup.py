import allure

import driver
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

    @allure.step('Fill in the form, submit and sign out')
    def change_password(self, old_pwd: str, new_pwd: str):
        self._current_password_text_field.text = old_pwd
        self._new_password_text_field.text = new_pwd
        self._confirm_password_text_field.text = new_pwd
        self._submit_button.click()
        self.click_sign_out_and_quit_button()

    @allure.step('Wait for Sign out and quit button and click it')
    def click_sign_out_and_quit_button(self):
        """
        Timeout is set as rough estimation of 15 seconds. What is happening when changing password is
        the process of re-hashing DB initiated. Taking into account the user is new , so DB is relatively small
        I assume, 15 seconds should be enough to finish re-hashing and show the Sign-out and quit button
        This time is not really predictable, especially for huge DBs. We might implement other solution, but since
        this is_visible method is barely working, I suggest this solution for now
        """
        try:
            assert driver.waitForObjectExists(self._quit_button.real_name, 15000), \
                f'Sign out and quit button is not present within 15 seconds'
            self._quit_button.click()
        except (Exception, AssertionError) as ex:
            raise ex


