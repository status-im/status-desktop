import allure

from gui.components.base_popup import BasePopup
from gui.elements.button import Button


class SigningPhrasePopup(BasePopup):

    def __init__(self):
        super(SigningPhrasePopup, self).__init__()
        self._ok_got_it_button = Button('signPhrase_Ok_Button')

    @allure.step('Confirm signing phrase in popup')
    def confirm_phrase(self):
        self._ok_got_it_button.click()
        SigningPhrasePopup().wait_until_hidden()