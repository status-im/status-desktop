import time

import allure

from gui.components.back_up_your_seed_phrase_popup import BackUpYourSeedPhrasePopUp
from gui.elements.object import QObject
from gui.elements.scroll import Scroll
from gui.screens.settings_communities import CommunitiesSettingsView
from gui.screens.settings_ens_usernames import ENSSettingsView
from gui.screens.settings_keycard import KeycardSettingsView
from gui.screens.settings_messaging import MessagingSettingsView
from gui.screens.settings_profile import ProfileSettingsView
from gui.screens.settings_syncing import SyncingSettingsView
from gui.screens.settings_wallet import WalletSettingsView
from gui.components.settings.sign_out_popup import SignOutPopup


class LeftPanel(QObject):

    def __init__(self):
        super().__init__('mainWindow_LeftTabView')
        self._settings_section_template = QObject('scrollView_MenuItem_StatusNavigationListItem')
        self._scroll = Scroll('scrollView_Flickable')
        self._settings_section_back_up_seed_option = QObject('settingsBackUpSeedPhraseOption')

    def _open_settings(self, object_name: str):
        self._settings_section_template.real_name['objectName'] = object_name
        if not self._settings_section_template.is_visible:
            self._scroll.vertical_down_to(self._settings_section_template)
        self._settings_section_template.click()

    @allure.step('Check back up seed option menu item presence')
    def check_back_up_seed_option_present(self):
        return self._settings_section_back_up_seed_option.exists

    @allure.step('Open messaging settings')
    def open_messaging_settings(self) -> 'MessagingSettingsView':
        self._open_settings('3-AppMenuItem')
        return MessagingSettingsView()

    @allure.step('Open communities settings')
    def open_communities_settings(self, attempts: int = 2) -> 'CommunitiesSettingsView':
        self._open_settings('12-AppMenuItem')
        try:
            return CommunitiesSettingsView()
        except Exception as ex:
            if attempts:
                self.open_communities_settings(attempts-1)
            else:
                raise ex

    @allure.step('Open wallet settings')
    def open_wallet_settings(self, attempts: int = 2) -> WalletSettingsView:
        self._open_settings('4-AppMenuItem')
        time.sleep(0.5)
        try:
            return WalletSettingsView()
        except Exception as ex:
            if attempts:
                self.open_wallet_settings(attempts-1)
            else:
                raise ex

    @allure.step('Open profile settings')
    def open_profile_settings(self) -> ProfileSettingsView:
        self._open_settings('0-MainMenuItem')
        return ProfileSettingsView()

    @allure.step('Choose back up seed phrase in settings')
    def open_back_up_seed_phrase(self) -> BackUpYourSeedPhrasePopUp:
        self._open_settings('18-MainMenuItem')
        return BackUpYourSeedPhrasePopUp()

    @allure.step('Open syncing settings')
    def open_syncing_settings(self, attempts: int = 2) -> SyncingSettingsView:
        self._open_settings('8-MainMenuItem')
        try:
            return SyncingSettingsView().wait_until_appears()
        except (AssertionError, LookupError) as ec:
            if attempts:
                return self.open_syncing_settings(attempts - 1)
            else:
                raise ec

    @allure.step('Choose sign out and quit in settings')
    def open_sign_out_and_quit(self):
        self._open_settings('17-ExtraMenuItem')
        return SignOutPopup()

    @allure.step('Open keycard settings')
    def open_keycard_settings(self) -> KeycardSettingsView:
        self._open_settings('13-MainMenuItem')
        return KeycardSettingsView()

    @allure.step('Open ENS usernames settings')
    def open_ens_usernames_settings(self) -> ENSSettingsView:
        time.sleep(1)
        self._open_settings('2-MainMenuItem')
        return ENSSettingsView()


class SettingsScreen(QObject):

    def __init__(self):
        super().__init__('mainWindow_ProfileLayout')
        self.left_panel = LeftPanel()
