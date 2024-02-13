import time
import typing

import allure

import configs
import driver
from gui.components.base_popup import BasePopup
from gui.elements.button import Button
from gui.elements.object import QObject
from gui.objects_map import names


class TagsSelectPopup(BasePopup):

    def __init__(self):
        super().__init__()
        self._tag_template = QObject(names.o_StatusCommunityTag)
        self._save_button = Button(names.confirm_Community_Tags_StatusButton)

    @allure.step('Wait until appears {0}')
    def wait_until_appears(self, timeout_msec: int = configs.timeouts.UI_LOAD_TIMEOUT_MSEC):
        self._tag_template.wait_until_appears()
        return self

    @allure.step('Select tags')
    def select_tags(self, values: typing.List[str]):
        tags = []
        checked = []
        unchecked = []
        for obj in driver.findAllObjects(self._tag_template.real_name):
            name = str(obj.name)
            tags.append(name)
            if name in values:
                if not obj.removable:
                    driver.mouseClick(obj)
                    checked.append(name)
                    time.sleep(1)
                values.remove(name)
            else:
                # Selected and should be unselected
                if obj.removable:
                    driver.mouseClick(obj)
                    time.sleep(1)
                    unchecked.append(name)
        if values:
            raise LookupError(
                f'Tags: {values} not found in {tags}. Checked tags: {checked}, Unchecked tags: {unchecked}')
        self._save_button.click()
