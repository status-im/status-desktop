import time

import allure

import driver
from gui.components.community.create_community_popups import CreateNewCommunityPopup
from gui.elements.button import Button
from gui.elements.object import QObject
from gui.objects_map import communities_names


class CommunitiesPortal(QObject):

    def __init__(self):
        super().__init__(communities_names.mainWindow_communitiesPortalLayout_CommunitiesPortalLayout)
        self.create_new_community_button = Button(communities_names.mainWindow_Create_New_Community_StatusButton)

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
