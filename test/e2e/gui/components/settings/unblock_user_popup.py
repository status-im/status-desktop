import allure

from gui.elements.button import Button
from gui.elements.object import QObject
from gui.elements.text_label import TextLabel
from gui.objects_map import names


class UnblockUserPopup(QObject):

    def __init__(self):
        super().__init__(names.unblockUserPopup)
        self.unblock_user_button = Button(names.unblock_StatusButton)
        self.cancel_button = Button(names.cancel_StatusButton)
        self.unblock_text = TextLabel(names.unblockingText_StatusBaseText)

    @allure.step('Get warning text')
    def get_warning_text(self) -> str:
        return self.unblock_text.text
