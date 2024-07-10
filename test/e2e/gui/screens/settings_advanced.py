import allure

from gui.components.settings.confirm_switch_waku_mode_popup import SwitchWakuModePopup
from gui.elements.button import Button
from gui.elements.object import QObject
from gui.elements.scroll import Scroll
from gui.objects_map import settings_names


class AdvancedSettingsView(QObject):

    def __init__(self):
        super().__init__(settings_names.mainWindow_AdvancedView)
        self._scroll = Scroll(settings_names.settingsContentBase_ScrollView)
        self._manage_community_on_testnet_button = Button(
            settings_names.manageCommunitiesOnTestnetButton_StatusSettingsLineButton)
        self._enable_creation_community_button = Button(settings_names.enableCreateCommunityButton_StatusSettingsLineButton)
        self._light_mode_button = Button(settings_names.settingsContentBaseScrollViewLightWakuModeBloomSelectorButton)
        self._relay_mode_button = Button(settings_names.settingsContentBaseScrollViewRelayWakuModeBloomSelectorButton)

    @allure.step('Switch manage community on testnet option')
    def switch_manage_on_community(self):
        self._scroll.vertical_scroll_down(self._manage_community_on_testnet_button)
        self._manage_community_on_testnet_button.click()

    @allure.step('Enable creation of communities')
    def enable_creation_of_communities(self):
        self._scroll.vertical_scroll_down(self._enable_creation_community_button)
        self._enable_creation_community_button.click()

    @allure.step('Switch waku mode')
    def switch_waku_mode(self, mode):
        if not self._manage_community_on_testnet_button.is_visible:
            self._scroll.vertical_scroll_down(self._manage_community_on_testnet_button)
        if mode == 'light':
            self._light_mode_button.click()
        elif mode == 'relay':
            self._relay_mode_button.click()
        return SwitchWakuModePopup().wait_until_appears()

    @allure.step('Verify waku mode enabled states')
    def is_waku_mode_enabled(self, mode):
        if not self._manage_community_on_testnet_button.is_visible:
            self._scroll.vertical_scroll_down(self._manage_community_on_testnet_button)
        if mode == 'light':
            return self._light_mode_button.is_checked
        elif mode == 'relay':
            return self._relay_mode_button.is_checked
