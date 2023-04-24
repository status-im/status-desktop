import typing

from drivers.SquishDriver import *


class SocialLinksPopup(BaseElement):

    def __init__(self):
        super(SocialLinksPopup, self).__init__('statusDesktop_mainWindow_overlay')
        self._add_social_link_list_item = BaseElement('socialLink_StatusListItem')
        self._social_link_text_field = TextEdit('edit_TextEdit')
        self._add_button = Button('add_StatusButton')

    def _get_list_item(self, title: str) -> BaseElement:
        self._add_social_link_list_item.object_name['title'] = title
        return self._add_social_link_list_item

    def _get_text_field(self, occurrence: int) -> BaseElement:
        key = 'occurrence'
        if occurrence:
            self._social_link_text_field.object_name[key] = occurrence + 1
        else:
            if key in self._social_link_text_field.object_name:
                del self._social_link_text_field.object_name[key]
        return self._social_link_text_field

    def add_link(self, network: str, links: typing.List[str]):
        self._get_list_item(network).click()
        time.sleep(0.5)
        for occurrence, link in enumerate(links):
            self._get_text_field(occurrence).text = link
        self._add_button.click()
        self.wait_utill_hidden()
