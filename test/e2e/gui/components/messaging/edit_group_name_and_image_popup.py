import allure

from gui.components.base_popup import BasePopup
from gui.elements.button import Button
from gui.elements.object import QObject
from gui.elements.text_edit import TextEdit
from gui.objects_map import names


class EditGroupNameAndImagePopup(QObject):

    def __init__(self):
        super().__init__(names.renameGroupPopup)
        self.group_name_field = TextEdit(names.groupChatEdit_name_TextEdit)
        self.save_changes_button = Button(names.save_changes_StatusButton)

    @allure.step('Change group name')
    def change_group_name(self, name: str):
        self.group_name_field.text = name

    @allure.step('Save changes')
    def save_changes(self):
        self.save_changes_button.click()
        self.wait_until_hidden()
