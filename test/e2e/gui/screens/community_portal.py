import time

import allure

import driver
from gui.components.community.create_community_popups import CreateNewCommunityPopup
from gui.components.community.import_community_popup import ImportCommunityPopup
from gui.elements.button import Button
from gui.elements.object import QObject
from gui.objects_map import communities_names
from helpers.chat_helper import skip_message_backup_popup_if_visible


class CommunitiesPortal(QObject):

    def __init__(self):
        super().__init__(communities_names.communityPortal)
        self.create_new_community_button = Button(communities_names.communityPortal_CreateCommunityButton)
        self.join_community_button = Button(communities_names.communityPortal_JoinCommunityButton)

    @allure.step('Open create community popup')
    def open_create_community_popup(self) -> CreateNewCommunityPopup:
        for i in range(2):
            self.create_new_community_button.click()
            time.sleep(0.1)
            try:
                return CreateNewCommunityPopup().wait_until_appears()
            except Exception:
                pass
        raise LookupError(f'Create Communities banner is not displayed')

    @allure.step('Open import community popup')
    def open_import_community_popup(self) -> ImportCommunityPopup:
        for i in range(2):
            self.join_community_button.click()
            time.sleep(0.1)
            try:
                return ImportCommunityPopup().wait_until_appears()
            except Exception:
                pass
        raise LookupError(f'Create Communities banner is not displayed')
