from gui.components.base_popup import BasePopup
from gui.objects_map import names
from gui.screens.settings_wallet import *
from gui.elements.button import Button
from gui.elements.text_label import TextLabel
from gui.elements.check_box import CheckBox


class RemoveAccountConfirmationSettings(BasePopup):

    def __init__(self):
        super(RemoveAccountConfirmationSettings, self).__init__()
        self._remove_confirmation_close_button = Button(names.removeConfirmationCrossCloseButton)
        self._remove_confirmation_title_text = TextLabel(names.removeConfirmationTextTitle)
        self._remove_confirmation_body_text = TextLabel(names.removeConfirmationTextBody)
        self._remove_confirmation_remove_account_button = Button(names.removeConfirmationRemoveButton)
        self._remove_confirmation_agreement_checkbox = CheckBox(names.removeConfirmationAgreementCheckBox)
        self._remove_confirmation_confirm_button = Button(names.removeConfirmationConfirmButton)

    @allure.step('Click Remove account button')
    def remove_account_with_confirmation(self):
        self._remove_confirmation_agreement_checkbox.set(True)
        self._remove_confirmation_confirm_button.click()

