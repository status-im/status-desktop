import time
import typing
import copy

import allure

from gui.elements.button import Button
from gui.elements.object import QObject
from gui.elements.text_edit import TextEdit
from gui.objects_map import names


class SocialLinksPopup(QObject):

    def __init__(self):
        super().__init__(names.socialLinksPopup)
        self._add_social_link_list_item = QObject(names.socialLink_StatusListItem)
        self._social_link_text_field = TextEdit(names.edit_TextEdit)
        self._back_button = Button(names.social_links_back_StatusBackButton)
        self._add_button = Button(names.social_links_add_StatusBackButton)

    @allure.step('Get social link')
    def _get_list_item(self, index: int) -> QObject:
        self._add_social_link_list_item.real_name['index'] = index
        return self._add_social_link_list_item

    @allure.step('Get social link field by index')
    def _get_text_field_by_index(self, index: int) -> TextEdit:
        """Get text field by index without modifying the original real_name"""
        # Create a copy of the real_name to avoid modifying the original
        text_field_real_name = copy.deepcopy(self._social_link_text_field.real_name)
        
        if index > 0:
            text_field_real_name['occurrence'] = index + 1
        
        # Create a temporary TextEdit with the modified real_name
        temp_text_field = TextEdit(text_field_real_name)
        return temp_text_field

    @allure.step('Add link to link field')
    def add_link(self, index: int, links: typing.List[str]):
        self._get_list_item(index).click()
        time.sleep(0.5)
        for field_index, link in enumerate(links):
            text_field = self._get_text_field_by_index(field_index)
            text_field.text = link
        self._add_button.click()
        self.wait_until_hidden()
