import allure

from gui.components.base_popup import BasePopup
from gui.elements.qt.button import Button


class TestnetModePopup(BasePopup):
    def __init__(self):
        super(TestnetModePopup, self).__init__()
        self._cancel_button = Button('add_StatusButton')
        self._turn_on_button = Button('turn_on_testnet_mode_StatusButton')
        self._turn_off_button = Button('turn_off_testnet_mode_StatusButton')

    @allure.step('Choose turn on option')
    def turn_on_testnet_mode(self):
        self._turn_on_button.click()
        self.wait_until_hidden()

    @allure.step('Choose turn off option')
    def turn_off_testnet_mode(self):
        self._turn_off_button.click()
        self.wait_until_hidden()

    def cancel(self):
        self._cancel_button.click()
        self.wait_until_hidden()
