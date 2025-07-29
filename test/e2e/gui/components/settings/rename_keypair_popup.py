import allure
from gui.elements.button import Button
from gui.elements.object import QObject
from gui.elements.text_edit import TextEdit
from gui.objects_map import names


class RenameKeypairPopup(QObject):

    def __init__(self):
        super().__init__(names.renameKeypairPopup)
        self.rename_text_input = TextEdit(names.edit_TextEdit)
        self.save_changes_button = Button(names.save_changes_rename_StatusButton)
        self.name_input = QObject(names.nameInput_StatusInput)

    @allure.step('Rename keypair')
    def rename_keypair(self, name):
        self.rename_text_input.clear()
        self.rename_text_input.type_text(name)
        assert self.save_changes_button.is_visible
        self.save_changes_button.click()
        self.wait_until_hidden()

    @allure.step('Get error message')
    def get_error_message(self) -> str:
        return str(self.name_input.object.errorMessageCmp.text)
