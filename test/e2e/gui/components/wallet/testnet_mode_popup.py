import allure

from gui.elements.button import Button
from gui.elements.object import QObject
from gui.objects_map import names


class TestnetModePopup(QObject):
    def __init__(self):
        super().__init__(names.testnetAlert)
        self.cancel_button = Button(names.testnet_mode_cancelButton)
        self.close_cross_button = Button(names.closeCrossPopupButton)
        self.turn_on_button = Button(names.turn_on_testnet_mode_StatusButton)
        self.turn_off_button = Button(names.turn_off_testnet_mode_StatusButton)

    @allure.step('Turn on testnet mode')
    def turn_on_testnet_mode(self):
        self.turn_on_button.click()
        return self
