import allure

import configs
import driver
from constants.settings import PasswordView
from gui.components.base_popup import BasePopup
from gui.elements.button import Button
from gui.elements.text_label import TextLabel


class ChangePasswordPopup(BasePopup):

    def __init__(self):
        super(ChangePasswordPopup, self).__init__()
        self._re_encrypt_data_restart_button = Button('reEncryptRestartButton')
        self._re_encryption_complete_element = TextLabel('reEncryptionComplete')

    @allure.step('Wait for Sign out and quit button and click it')
    def click_re_encrypt_data_restart_button(self):
        """
        Timeout is set as rough estimation of 15 seconds. What is happening when changing password is
        the process of re-hashing DB initiated. Taking into account the user is new , so DB is relatively small
        I assume, 15 seconds should be enough to finish re-hashing and show the Restart button
        This time is not really predictable, especially for huge DBs.
        """
        self._re_encrypt_data_restart_button.click()
        assert driver.waitForObject(self._re_encryption_complete_element.real_name, 15000), \
            f'Re-encryption confirmation is not present within 15 seconds'
        assert driver.waitForObject(self._re_encrypt_data_restart_button.real_name, 17000)
        assert getattr(self._re_encrypt_data_restart_button.object, 'text') == PasswordView.RESTART_STATUS.value
        self._re_encrypt_data_restart_button.click()



