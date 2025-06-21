import time
import typing

import allure

from gui.elements.button import Button
from gui.elements.object import QObject
from gui.elements.text_edit import TextEdit
from .base_popup import BasePopup
from ..objects_map import names


class SocialLinksPopup(QObject):

    def __init__(self):
        super(SocialLinksPopup, self).__init__(names.socialLinksPopup)
        self._add_social_link_list_item = QObject(names.socialLink_StatusListItem)
        self._social_link_text_field = TextEdit(names.edit_TextEdit)
        self._back_button = Button(names.social_links_back_StatusBackButton)
        self._add_button = Button(names.social_links_add_StatusBackButton)

    @allure.step('Get social link')
    def _get_list_item(self, index: int) -> QObject:
        self._add_social_link_list_item.real_name['index'] = index
        return self._add_social_link_list_item

    @allure.step('Get social link field')
    def _get_text_field(self, occurrence: int) -> QObject:
        key = 'occurrence'
        if occurrence:
            self._social_link_text_field.real_name[key] = occurrence + 1
        else:
            if key in self._social_link_text_field.real_name:
                del self._social_link_text_field.real_name[key]
        return self._social_link_text_field

    @allure.step('Add link to link field')
    def add_link(self, index: int, links: typing.List[str]):
        self._get_list_item(index).click()
        time.sleep(0.5)
        for occurrence, link in enumerate(links):
            self._get_text_field(occurrence).text = link
        self._add_button.click()
        self.wait_until_hidden()
