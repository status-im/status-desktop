from gui.components.base_popup import BasePopup
from gui.elements.button import Button
from gui.elements.check_box import CheckBox


class WelcomeStatusPopup(BasePopup):

    def __init__(self):
        self._agree_to_use_checkbox = CheckBox('agreeToUse_StatusCheckBox')
        self._ready_to_use_checkbox = CheckBox('readyToUse_StatusCheckBox')
        self._ready_to_use_button = Button('i_m_ready_to_use_Status_Desktop_Beta_StatusButton')
        super(WelcomeStatusPopup, self).__init__()

    def confirm(self):
        self._agree_to_use_checkbox.set(True)
        self._ready_to_use_checkbox.set(True)
        self._ready_to_use_button.click()
        self.wait_until_hidden()
