import time

import allure

import driver
from gui.components.back_up_your_seed_phrase_popup import BackUpYourSeedPhrasePopUp
from gui.elements.object import QObject
from gui.elements.scroll import Scroll
from gui.objects_map import settings_names
from gui.screens.settings_advanced import AdvancedSettingsView
from gui.screens.settings_communities import CommunitiesSettingsView
from gui.screens.settings_ens_usernames import ENSSettingsView
from gui.screens.settings_keycard import KeycardSettingsView
from gui.screens.settings_messaging import MessagingSettingsView
from gui.screens.settings_profile import ProfileSettingsView
from gui.screens.settings_syncing import SyncingSettingsView
from gui.screens.settings_wallet import WalletSettingsView
from gui.screens.settings_password import ChangePasswordView
from gui.components.settings.sign_out_popup import SignOutPopup


class LeftPanel(QObject):

    def __init__(self):
        super().__init__(settings_names.mainWindow_LeftTabView)
        self._settings_section_template = QObject(settings_names.scrollView_MenuItem_StatusNavigationListItem)
        self._scroll = Scroll(settings_names.mainWindow_scrollView_StatusScrollView)
        self.settings_section_back_up_seed_option = QObject(settings_names.settingsBackUpSeedPhraseOption)
        self._settings_section_wallet_option = QObject(settings_names.settingsWalletOption)

    def _open_settings(self, object_name: str):
        self._settings_section_template.real_name['objectName'] = object_name
        if not self._settings_section_template.is_visible:
            self._scroll.vertical_scroll_down(self._settings_section_template)
        self._settings_section_template.click()

    @allure.step('Open messaging settings')
    def open_messaging_settings(self) -> 'MessagingSettingsView':
        self._open_settings('4-AppMenuItem')
        return MessagingSettingsView()

    @allure.step('Open communities settings')
    def open_communities_settings(self, attempts: int = 2) -> 'CommunitiesSettingsView':
        self._open_settings('13-AppMenuItem')
        try:
            return CommunitiesSettingsView()
        except Exception as ex:
            if attempts:
                self.open_communities_settings(attempts-1)
            else:
                raise ex

    @allure.step('Open wallet settings')
    def open_wallet_settings(self) -> 'WalletSettingsView':
        self._open_settings('5-AppMenuItem')
        assert WalletSettingsView().exists, 'Wallet view was not opened'
        return WalletSettingsView()

    @allure.step('Open profile settings')
    def open_profile_settings(self) -> 'ProfileSettingsView':
        self._open_settings('0-MainMenuItem')
        return ProfileSettingsView()

    @allure.step('Open password settings')
    def open_password_settings(self) -> 'ChangePasswordView':
        self._open_settings('1-MainMenuItem')
        return ChangePasswordView()

    @allure.step('Choose back up seed phrase in settings')
    def open_back_up_seed_phrase(self) -> 'BackUpYourSeedPhrasePopUp':
        self._open_settings('18-MainMenuItem')
        return BackUpYourSeedPhrasePopUp()

    @allure.step('Open syncing settings')
    def open_syncing_settings(self, attempts: int = 2) -> 'SyncingSettingsView':
        self._open_settings('9-MainMenuItem')
        try:
            return SyncingSettingsView().wait_until_appears()
        except (AssertionError, LookupError) as ec:
            if attempts:
                return self.open_syncing_settings(attempts - 1)
            else:
                raise ec

    @allure.step('Choose sign out and quit in settings')
    def open_sign_out_and_quit(self) -> 'SignOutPopup':
        self._open_settings('17-ExtraMenuItem')
        return SignOutPopup()

    @allure.step('Open keycard settings')
    def open_keycard_settings(self) -> 'KeycardSettingsView':
        self._open_settings('14-MainMenuItem')
        return KeycardSettingsView()

    @allure.step('Open ENS usernames settings')
    def open_ens_usernames_settings(self) -> 'ENSSettingsView':
        time.sleep(1)
        self._open_settings('3-MainMenuItem')
        return ENSSettingsView()

    @allure.step('Open advanced settings')
    def open_advanced_settings(self) -> 'AdvancedSettingsView':
        time.sleep(1)
        self._open_settings('11-SettingsMenuItem')
        return AdvancedSettingsView()


class SettingsScreen(QObject):

    def __init__(self):
        super().__init__(settings_names.mainWindow_ProfileLayout)
        self.left_panel = LeftPanel()
