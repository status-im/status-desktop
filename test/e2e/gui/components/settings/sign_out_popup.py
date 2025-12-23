import allure

from gui.elements.button import Button
from gui.elements.object import QObject
from gui.objects_map import settings_names


class SignOutPopup(QObject):

    def __init__(self):
        super().__init__(settings_names.signOutDialog)
        self.sign_out_dialog = QObject(settings_names.signOutDialog)
        self._sign_out_and_quit_button = Button(settings_names.signOutConfirmationButton)

    @allure.step('Click sign out and quit button')
    def sign_out_and_quit(self, attempts: int = 2):
        try:
            # TODO https://github.com/status-im/status-app/issues/15345
            self._sign_out_and_quit_button.click()
        except Exception as ec:
            if attempts:
                self.sign_out_and_quit(attempts-1)
            else:
                raise ec

