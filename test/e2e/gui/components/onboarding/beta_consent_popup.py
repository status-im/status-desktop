import allure

from gui.components.base_popup import BasePopup
from gui.elements.button import Button
from gui.elements.check_box import CheckBox
from gui.elements.object import QObject
from gui.objects_map import names


class BetaConsentPopup(QObject):

    def __init__(self):
        super().__init__(names.betaConsent_StatusModal)
        self._agree_to_use_checkbox = CheckBox(names.agreeToUse_StatusCheckBox)
        self._ready_to_use_checkbox = CheckBox(names.readyToUse_StatusCheckBox)
        self._ready_to_use_button = Button(names.i_m_ready_to_use_Status_Desktop_Beta_StatusButton)

    @allure.step('Confirm all')
    def confirm(self):
        self._agree_to_use_checkbox.set(True)
        self._ready_to_use_checkbox.set(True)
        # TODO https://github.com/status-im/status-desktop/issues/15345
        self._ready_to_use_button.click(timeout=60)
        self.wait_until_hidden()
