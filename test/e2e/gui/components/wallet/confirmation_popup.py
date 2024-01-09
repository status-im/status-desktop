import allure

from gui.elements.button import Button
from gui.elements.object import QObject
from gui.elements.text_label import TextLabel


class ConfirmationPopup(QObject):

    def __init__(self):
        super(ConfirmationPopup, self).__init__('contextMenu_PopupItem')
        self._confirm_button = Button('mainWallet_Saved_Addresses_More_Confirm_Delete')
        self._cancel_button = Button('mainWallet_Saved_Addresses_More_Confirm_Cancel')
        self._confirmation_notification = TextLabel('mainWallet_Saved_Addresses_More_Confirm_Notification')

    @allure.step('Confirm delete action')
    def confirm(self):
        self._confirm_button.click()
        self.wait_until_hidden()

    @allure.step('Get confirmation text')
    def get_confirmation_text(self):
        return self._confirmation_notification.text

