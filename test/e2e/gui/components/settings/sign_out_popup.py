import allure

from gui.components.base_popup import BasePopup
from gui.elements.button import Button
from gui.objects_map import settings_names


class SignOutPopup(BasePopup):

    def __init__(self):
        super().__init__()
        self._sign_out_and_quit_button = Button(settings_names.signOutConfirmationButton)

    @allure.step('Click sign out and quit button')
    def sign_out_and_quit(self, attempts: int = 2):
        try:
            # TODO https://github.com/status-im/status-desktop/issues/15345
            self._sign_out_and_quit_button.click()
        except Exception as ec:
            if attempts:
                self.sign_out_and_quit(attempts-1)
            else:
                raise ec

