import allure

from gui.elements.button import Button
from gui.elements.object import QObject
from gui.elements.scroll import Scroll
from gui.objects_map import names


class AdvancedSettingsView(QObject):

    def __init__(self):
        super().__init__(names.mainWindow_AdvancedView)
        self._scroll = Scroll(names.settingsContentBaseScrollView_Flickable)
        self._manage_community_on_testnet_button = Button(
            names.manageCommunitiesOnTestnetButton_StatusSettingsLineButton)
        self._enable_creation_community_button = Button(names.enableCreateCommunityButton_StatusSettingsLineButton)

    @allure.step('Switch manage community on testnet option')
    def switch_manage_on_community(self):
        self._scroll.vertical_down_to(self._manage_community_on_testnet_button)
        self._manage_community_on_testnet_button.click()

    @allure.step('Enable creation of communities')
    def enable_creation_of_communities(self):
        self._scroll.vertical_down_to(self._enable_creation_community_button)
        self._enable_creation_community_button.click()
