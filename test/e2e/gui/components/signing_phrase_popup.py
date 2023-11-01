import allure

from gui.components.base_popup import BasePopup
from gui.elements.button import Button
from gui.elements.object import QObject


class SigningPhrasePopup(QObject):

    def __init__(self):
        super(SigningPhrasePopup, self).__init__('signPhrase_Ok_Button')
        self._ok_got_it_button = Button('signPhrase_Ok_Button')

    @allure.step('Confirm signing phrase in popup')
    def confirm_phrase(self):
        self._ok_got_it_button.click()
        SigningPhrasePopup().wait_until_hidden()

    @allure.step('Verify if the signing phrase popup is visible')
    def is_ok_got_it_button_visible(self):
        return self._ok_got_it_button.is_visible

