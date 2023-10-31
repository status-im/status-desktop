import allure

import configs
from gui.elements.button import Button
from gui.elements.text_label import TextLabel
from gui.screens.settings_wallet import *
from gui.elements.object import QObject


class RemoveAccountConfirmationSettings(QObject):

    def __init__(self):
        super(RemoveAccountConfirmationSettings, self).__init__('removeConfirmationTextTitle')
        self._remove_confirmation_close_button = Button('removeConfirmationCrossCloseButton')
        self._remove_confirmation_title_text = TextLabel('removeConfirmationTextTitle')
        self._remove_confirmation_body_text = TextLabel('removeConfirmationTextBody')
        self._remove_confirmation_remove_account_button = Button('removeConfirmationRemoveButton')

    @allure.step('Click Remove account button')
    def click_remove_account_button(self):
        self._remove_confirmation_remove_account_button.click()
