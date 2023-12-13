import allure

import configs
from gui.components.base_popup import BasePopup
from gui.elements.button import Button
from gui.elements.check_box import CheckBox
from gui.elements.text_label import TextLabel
from gui.screens.settings_wallet import *
from gui.elements.object import QObject


class RemoveAccountConfirmationSettings(BasePopup):

    def __init__(self):
        super(RemoveAccountConfirmationSettings, self).__init__()
        self._remove_confirmation_close_button = Button('removeConfirmationCrossCloseButton')
        self._remove_confirmation_title_text = TextLabel('removeConfirmationTextTitle')
        self._remove_confirmation_body_text = TextLabel('removeConfirmationTextBody')
        self._remove_confirmation_remove_account_button = Button('removeConfirmationRemoveButton')
        self._remove_confirmation_agreement_checkbox = CheckBox('removeConfirmationAgreementCheckBox')
        self._remove_confirmation_confirm_button = Button('removeConfirmationConfirmButton')

    @allure.step('Click Remove account button')
    def remove_account_with_confirmation(self):
        self._remove_confirmation_agreement_checkbox.set(True)
        self._remove_confirmation_confirm_button.click()

