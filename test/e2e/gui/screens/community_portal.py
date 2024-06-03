import allure

import driver
from gui.components.community.create_community_popups import CreateCommunitiesBanner, CreateCommunityPopup
from gui.elements.button import Button
from gui.elements.object import QObject
from gui.objects_map import communities_names


class CommunitiesPortal(QObject):

    def __init__(self):
        super().__init__(communities_names.mainWindow_communitiesPortalLayout_CommunitiesPortalLayout)
        self._create_community_button = Button(communities_names.mainWindow_Create_New_Community_StatusButton)

    @allure.step('Open create community popup')
    def open_create_community_popup(self) -> CreateCommunityPopup:
        self._create_community_button.click()
        try:
            assert driver.waitForObjectExists(CreateCommunitiesBanner().real_name, 5000), \
                f'Create community banner is not present within 5 seconds'
        except (Exception, AssertionError) as ex:
            raise ex
        return CreateCommunitiesBanner().open_create_community_popup()
