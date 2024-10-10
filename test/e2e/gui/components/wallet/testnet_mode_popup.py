import allure

from gui.components.base_popup import BasePopup
from gui.elements.button import Button
from gui.objects_map import names


class TestnetModePopup(BasePopup):
    def __init__(self):
        super(TestnetModePopup, self).__init__()
        self.cancel_button = Button(names.testnet_mode_cancelButton)
        self.close_cross_button = Button(names.closeCrossPopupButton)
        self.turn_on_button = Button(names.turn_on_testnet_mode_StatusButton)
        self.turn_off_button = Button(names.turn_off_testnet_mode_StatusButton)


