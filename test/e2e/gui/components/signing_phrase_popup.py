import allure

from gui.elements.button import Button
from gui.elements.object import QObject
from gui.objects_map import names


class SigningPhrasePopup(QObject):

    def __init__(self):
        super(SigningPhrasePopup, self).__init__(names.signPhrase_Ok_Button)
        self._ok_got_it_button = Button(names.signPhrase_Ok_Button)

    @allure.step('Confirm signing phrase in popup')
    def confirm_phrase(self):
        self._ok_got_it_button.click(timeout=10)
        SigningPhrasePopup().wait_until_hidden()

    @allure.step('Verify if the signing phrase popup is visible')
    def is_ok_got_it_button_visible(self):
        return self._ok_got_it_button.is_visible
