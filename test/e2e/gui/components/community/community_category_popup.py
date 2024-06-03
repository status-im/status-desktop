import allure

import configs
import driver.objects_access
from gui.components.base_popup import BasePopup
from gui.elements.button import Button
from gui.elements.check_box import CheckBox
from gui.elements.object import QObject
from gui.elements.text_edit import TextEdit
from gui.objects_map import names


class CategoryPopup(BasePopup):

    def __init__(self):
        super(CategoryPopup, self).__init__()
        self._name_text_edit = TextEdit(names.createOrEditCommunityCategoryNameInput_TextEdit)
        self._channel_item_checkbox = CheckBox(names.channelItemCheckbox_StatusCheckBox)
        self._channels_view = QObject(names.createOrEditCommunityCategoryChannelList_StatusListView)

    @allure.step('Wait until appears {0}')
    def wait_until_appears(self, timeout_msec: int = configs.timeouts.UI_LOAD_TIMEOUT_MSEC):
        self._name_text_edit.wait_until_appears(timeout_msec)
        return self

    @allure.step('Enter category title in category popup')
    def enter_category_title(self, title):
        self._name_text_edit.text = title
        return self

    @allure.step('Click checkbox in category popup')
    def click_checkbox_by_index(self, index: int):
        checkboxes = []
        for child in driver.objects_access.walk_children(self._channels_view.object):
            if child.id == 'channelItemCheckbox':
                checkboxes.append(child)
        driver.mouseClick(checkboxes[index])
        return self


class NewCategoryPopup(CategoryPopup):

    def __init__(self):
        super(NewCategoryPopup, self).__init__()
        self._create_button = Button(names.create_StatusButton)

    @allure.step('Create category')
    def create(self, name: str, checkbox_state: bool):
        self._name_text_edit.text = name
        if checkbox_state:
            self._channel_item_checkbox.click()
        self._create_button.click()
        self.wait_until_hidden()


class EditCategoryPopup(CategoryPopup):

    def __init__(self):
        super(EditCategoryPopup, self).__init__()
        self._delete_button = Button(names.delete_Category_StatusButton)
        self._save_button = Button(names.save_StatusButton)

    @allure.step('Click save in edit category popup')
    def save(self):
        self._save_button.click()
        self.wait_until_hidden()
