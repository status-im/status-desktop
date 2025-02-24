import allure

import configs.system
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

from scripts.utils.decorators import handle_settings_opening


class LeftPanel(QObject):

    def __init__(self):
        super().__init__(settings_names.mainWindow_LeftTabView)
        self._settings_section_template = QObject(settings_names.mainWindow_settingsList_SettingsListItem)
        self._scroll = Scroll(settings_names.mainWindow_settingsList_VerticalScroll)
        self.settings_section_back_up_seed_option = QObject(settings_names.settingsBackUpSeedPhraseOption)
        self.settings_section_wallet_option = QObject(settings_names.settingsWalletOption)
        self.settings_section_sign_out_quit_option = QObject(settings_names.settingsSignOutQuitOption)

    @allure.step('Wait until appears {0}')
    def wait_until_appears(self, timeout_msec: int = configs.timeouts.UI_LOAD_TIMEOUT_MSEC):
        self._settings_section_template.wait_until_appears(timeout_msec)
        return self

    def _open_settings(self, object_name: str):
        self._settings_section_template.real_name['objectName'] = object_name
        if not self._settings_section_template.is_visible:
            self._scroll.vertical_scroll_down(self._settings_section_template)
        self._settings_section_template.click()

    @allure.step('Choose back up seed phrase in settings')
    @handle_settings_opening(BackUpYourSeedPhrasePopUp, '18-MenuItem')
    def open_back_up_seed_phrase(self, click_attempts: int = 2) -> 'BackUpYourSeedPhrasePopUp':
        return BackUpYourSeedPhrasePopUp().wait_until_appears()

    @allure.step('Open wallet settings')
    @handle_settings_opening(WalletSettingsView, '5-MenuItem')
    def open_wallet_settings(self, click_attempts: int = 2) -> 'WalletSettingsView':
        return WalletSettingsView().wait_until_appears()

    @allure.step('Open messaging settings')
    @handle_settings_opening(MessagingSettingsView, '4-MenuItem')
    def open_messaging_settings(self, click_attempts: int = 2) -> 'MessagingSettingsView':
        return MessagingSettingsView().wait_until_appears()

    @allure.step('Open communities settings')
    @handle_settings_opening(CommunitiesSettingsView, '12-MenuItem')
    def open_communities_settings(self, attempts: int = 2) -> 'CommunitiesSettingsView':
        return CommunitiesSettingsView().wait_until_appears()

    @allure.step('Open profile settings')
    @handle_settings_opening(ProfileSettingsView, '0-MenuItem')
    def open_profile_settings(self, click_attempts: int = 2) -> 'ProfileSettingsView':
        return ProfileSettingsView().wait_until_appears()

    @allure.step('Open password settings')
    @handle_settings_opening(ChangePasswordView, '1-MenuItem')
    def open_password_settings(self, click_attempts: int = 2) -> 'ChangePasswordView':
        return ChangePasswordView().wait_until_appears()

    @allure.step('Open syncing settings')
    @handle_settings_opening(SyncingSettingsView, '9-MenuItem')
    def open_syncing_settings(self, click_attempts: int = 2) -> 'SyncingSettingsView':
        return SyncingSettingsView().wait_until_appears()

    @allure.step('Choose sign out and quit in settings')
    @handle_settings_opening(SignOutPopup, '17-MenuItem')
    def open_sign_out_and_quit(self, click_attempts: int = 2) -> 'SignOutPopup':
        return SignOutPopup().wait_until_appears()

    @allure.step('Open keycard settings')
    @handle_settings_opening(KeycardSettingsView, '13-MenuItem')
    def open_keycard_settings(self, click_attempts: int = 2) -> 'KeycardSettingsView':
        return KeycardSettingsView().wait_until_appears()

    @allure.step('Open ENS usernames settings')
    @handle_settings_opening(ENSSettingsView, '3-MenuItem')
    def open_ens_usernames_settings(self, click_attempts: int = 2) -> 'ENSSettingsView':
        return ENSSettingsView().wait_until_appears()

    @allure.step('Open advanced settings')
    @handle_settings_opening(AdvancedSettingsView, '10-MenuItem')
    def open_advanced_settings(self, click_attempts: int = 2) -> 'AdvancedSettingsView':
        return AdvancedSettingsView().wait_until_appears()


class SettingsScreen(QObject):

    def __init__(self):
        super().__init__(settings_names.mainWindow_ProfileLayout)
        self.left_panel = LeftPanel()
