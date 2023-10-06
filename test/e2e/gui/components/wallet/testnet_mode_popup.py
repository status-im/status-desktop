import allure

from gui.components.base_popup import BasePopup
from gui.elements.button import Button


class TestnetModePopup(BasePopup):
    def __init__(self):
        super(TestnetModePopup, self).__init__()
        self._cancel_button = Button('testnet_mode_cancelButton')
        self._close_cross_button = Button('testnet_mode_closeCrossButton')
        self._turn_on_button = Button('turn_on_testnet_mode_StatusButton')
        self._turn_off_button = Button('turn_off_testnet_mode_StatusButton')

    @allure.step('Close testnet mode modal with cross button')
    def close_testnet_modal_with_cross_button(self):
        self._close_cross_button.click()
        self.wait_until_hidden()

    @allure.step('Choose turn on option in the testnet modal')
    def click_turn_on_testnet_mode_in_testnet_modal(self):
        self._turn_on_button.click()
        self.wait_until_hidden()

    @allure.step('Choose turn off option on the testnet modal')
    def turn_off_testnet_mode_in_testnet_modal(self):
        self._turn_off_button.click()
        self.wait_until_hidden()

    def click_cancel_button_in_testnet_modal(self):
        self._cancel_button.click()
        self.wait_until_hidden()
