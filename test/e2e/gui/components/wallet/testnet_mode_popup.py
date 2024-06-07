import allure

from gui.components.base_popup import BasePopup
from gui.elements.button import Button
from gui.objects_map import names


class TestnetModePopup(BasePopup):
    def __init__(self):
        super(TestnetModePopup, self).__init__()
        self._cancel_button = Button(names.testnet_mode_cancelButton)
        self._close_cross_button = Button(names.closeCrossPopupButton)
        self._turn_on_button = Button(names.turn_on_testnet_mode_StatusButton)
        self._turn_off_button = Button(names.turn_off_testnet_mode_StatusButton)

    @allure.step('Close testnet mode modal with cross button')
    def close_testnet_modal_with_cross_button(self, attempts: int = 2):
        try:
            self._close_cross_button.click()
        except Exception as ec:
            if attempts:
                self.close_testnet_modal_with_cross_button(attempts - 1)
            else:
                raise ec

    @allure.step('Confirm turning on in the testnet modal')
    def turn_on_testnet_mode_in_testnet_modal(self):
        self._turn_on_button.click()
        self.wait_until_hidden()

    @allure.step('Confirm turning off in the testnet modal')
    def turn_off_testnet_mode_in_testnet_modal(self):
        self._turn_off_button.click()
        self.wait_until_hidden()

    @allure.step('Cancel switching testnet mode in the testnet modal')
    def click_cancel_button_in_testnet_modal(self):
        self._cancel_button.click()
        self.wait_until_hidden()
