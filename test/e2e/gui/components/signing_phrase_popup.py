import allure

from gui.components.base_popup import BasePopup
from gui.elements.button import Button
from gui.objects_map import names


class SigningPhrasePopup(BasePopup):

    def __init__(self):
        super().__init__()
        self.ok_got_it_button = Button(names.signPhrase_Ok_Button)

    @allure.step('Confirm signing phrase in popup')
    def confirm_phrase(self):
        self.ok_got_it_button.click()
        SigningPhrasePopup().wait_until_hidden()

