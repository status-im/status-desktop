import time
import typing

import allure

from .base_popup import BasePopup
from gui.elements.button import Button
from gui.elements.object import QObject
from gui.elements.text_edit import TextEdit


class SocialLinksPopup(BasePopup):

    def __init__(self):
        super(SocialLinksPopup, self).__init__()
        self._add_social_link_list_item = QObject('socialLink_StatusListItem')
        self._social_link_text_field = TextEdit('edit_TextEdit')
        self._back_button = Button('social_links_back_StatusBackButton')
        self._add_button = Button('social_links_add_StatusBackButton')

    @allure.step('Get social link')
    def _get_list_item(self, title: str) -> QObject:
        self._add_social_link_list_item.real_name['title'] = title
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
    def add_link(self, network: str, links: typing.List[str]):
        self._get_list_item(network).click()
        time.sleep(0.5)
        for occurrence, link in enumerate(links):
            self._get_text_field(occurrence).text = link
        self._add_button.click()
        self.wait_until_hidden()
        