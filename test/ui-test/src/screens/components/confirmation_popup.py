from drivers.SquishDriver import *


class ConfirmationPopup(BaseElement):

    def __init__(self):
        super(ConfirmationPopup, self).__init__('contextMenu_PopupItem')
        self._confirm_button = Button('confirmButton')

    def confirm(self):
        self._confirm_button.click()
        self.wait_until_hidden()
