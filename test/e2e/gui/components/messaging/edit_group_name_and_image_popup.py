import allure

from gui.components.base_popup import BasePopup
from gui.elements.button import Button
from gui.elements.text_edit import TextEdit


class EditGroupNameAndImagePopup(BasePopup):

    def __init__(self):
        super(EditGroupNameAndImagePopup, self).__init__()
        self._group_name_field = TextEdit('groupChatEdit_name_TextEdit')
        self._save_changes_button = Button('save_changes_StatusButton')

    @allure.step('Change group name')
    def change_group_name(self, name: str):
        self._group_name_field.text = name

    @allure.step('Save changes')
    def save_changes(self):
        self._save_changes_button.click()
        self.wait_until_hidden()
