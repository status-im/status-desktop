import configs
from gui.components.base_popup import BasePopup
from gui.elements.button import Button
from gui.elements.check_box import CheckBox
from gui.elements.text_edit import TextEdit


class CategoryPopup(BasePopup):

    def __init__(self):
        super(CategoryPopup, self).__init__()
        self._name_text_edit = TextEdit('createOrEditCommunityCategoryNameInput_TextEdit')
        self._general_item_checkbox = CheckBox('channelItemCheckbox_StatusCheckBox')

    def wait_until_appears(self, timeout_msec: int = configs.timeouts.UI_LOAD_TIMEOUT_MSEC):
        self._name_text_edit.wait_until_appears(timeout_msec)
        return self


class NewCategoryPopup(CategoryPopup):

    def __init__(self):
        super(NewCategoryPopup, self).__init__()
        self._create_button = Button('create_StatusButton')

    def create(self, name: str, checkbox_state: bool):
        self._name_text_edit.text = name
        if checkbox_state:
            self._general_item_checkbox.click()
        self._create_button.click()
        self.wait_until_hidden()
