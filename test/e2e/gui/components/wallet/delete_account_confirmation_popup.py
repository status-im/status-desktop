from gui.objects_map import names
from gui.screens.settings_wallet import *
from gui.elements.button import Button
from gui.elements.text_label import TextLabel
from gui.elements.check_box import CheckBox
from gui.elements.object import QObject


class RemoveAccountWithConfirmation(QObject):

    def __init__(self):
        super().__init__(names.removeAccountConfirmationPopup)
        self.remove_account_confirmation_popup = QObject(names.removeAccountConfirmationPopup)
        self.remove_confirmation_close_button = Button(names.removeConfirmationCrossCloseButton)
        self.remove_button = Button(names.removeButton)
        self.remove_confirmation_title_text = TextLabel(names.removeConfirmationTextTitle)
        self.remove_confirmation_body_text = TextLabel(names.removeConfirmationTextBody)
        self.remove_confirmation_remove_account_button = Button(names.removeConfirmationRemoveButton)
        self.remove_confirmation_agreement_checkbox = CheckBox(names.removeConfirmationAgreementCheckBox)
        self.remove_confirmation_confirm_button = Button(names.removeConfirmationConfirmButton)

    @allure.step('Click Remove account button')
    def remove_account_with_confirmation(self):
        self.remove_confirmation_agreement_checkbox.set(True)
        self.remove_confirmation_confirm_button.click()

