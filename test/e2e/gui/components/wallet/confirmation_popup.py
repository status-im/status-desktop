import allure

from gui.elements.button import Button
from gui.elements.object import QObject


class ConfirmationPopup(QObject):

    def __init__(self):
        super(ConfirmationPopup, self).__init__('contextMenu_PopupItem')
        self._confirm_button = Button('confirmButton')

    @allure.step('Confirm action')
    def confirm(self):
        self._confirm_button.click()
        self.wait_until_hidden()