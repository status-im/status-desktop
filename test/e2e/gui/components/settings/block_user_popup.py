import allure

from gui.elements.button import Button
from gui.elements.object import QObject
from gui.elements.text_label import TextLabel
from gui.objects_map import names


class BlockUserPopup(QObject):

    def __init__(self):
        super().__init__(names.blockUserPopup)
        self.block_user_button = Button(names.block_StatusButton)
        self.cancel_button = Button(names.cancel_StatusFlatButton)
        self.block_warning_box = QObject(names.blockWarningBox_StatusWarningBox)
        self.you_will_not_see_text = TextLabel(names.youWillNotSeeText_StatusBaseText)

    @allure.step('Get warning text')
    def get_warning_text(self) -> str:
        return str(self.block_warning_box.object.text)

    @allure.step('Get you will not see text')
    def get_you_will_not_see_text(self) -> str:
        return str(self.you_will_not_see_text.text)
