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
        self._settings_section_template = QObject(settings_names.scrollView_MenuItem_StatusNavigationListItem)
        self._scroll = Scroll(settings_names.mainWindow_scrollView_StatusScrollView)
        self.settings_section_back_up_seed_option = QObject(settings_names.settingsBackUpSeedPhraseOption)
        self._settings_section_wallet_option = QObject(settings_names.settingsWalletOption)

    @allure.step('Wait until appears {0}')
    def wait_until_appears(self, timeout_msec: int = configs.timeouts.UI_LOAD_TIMEOUT_MSEC):
        self._settings_section_template.wait_until_appears(timeout_msec)
        return self

    def _open_settings(self, object_name: str):
        self._settings_section_template.real_name['objectName'] = object_name
        if not self._settings_section_template.is_visible:
            self._scroll.vertical_scroll_down(self._settings_section_template)
        self._settings_section_template.click()

    @allure.step('Open messaging settings')
    @handle_settings_opening(MessagingSettingsView, '4-AppMenuItem')
    def open_messaging_settings(self, click_attempts: int = 2) -> 'MessagingSettingsView':
        assert MessagingSettingsView().wait_until_appears(), 'Messaging settings view was not opened'
        return MessagingSettingsView()

    @allure.step('Open communities settings')
    @handle_settings_opening(CommunitiesSettingsView, '12-AppMenuItem')
    def open_communities_settings(self, attempts: int = 2) -> 'CommunitiesSettingsView':
        assert CommunitiesSettingsView().exists, 'Community settings view was not opened'
        return CommunitiesSettingsView()

    @allure.step('Open wallet settings')
    @handle_settings_opening(WalletSettingsView, '5-AppMenuItem')
    def open_wallet_settings(self, click_attempts: int = 2) -> 'WalletSettingsView':
        assert WalletSettingsView().wait_until_appears(), 'Wallet settings view was not opened'
        return WalletSettingsView()

    @allure.step('Open profile settings')
    @handle_settings_opening(ProfileSettingsView, '0-MainMenuItem')
    def open_profile_settings(self, click_attempts: int = 2) -> 'ProfileSettingsView':
        assert ProfileSettingsView().exists, 'Profile settings view was not opened'
        return ProfileSettingsView()

    @allure.step('Open password settings')
    @handle_settings_opening(ChangePasswordView, '1-MainMenuItem')
    def open_password_settings(self, click_attempts: int = 2) -> 'ChangePasswordView':
        assert ChangePasswordView().exists, 'Password settings view was not opened'
        return ChangePasswordView()

    @allure.step('Choose back up seed phrase in settings')
    @handle_settings_opening(BackUpYourSeedPhrasePopUp, '18-MainMenuItem')
    def open_back_up_seed_phrase(self, click_attempts: int = 2) -> 'BackUpYourSeedPhrasePopUp':
        assert BackUpYourSeedPhrasePopUp().exists, 'Back up your seed phrase modal was not opened'
        return BackUpYourSeedPhrasePopUp()

    @allure.step('Open syncing settings')
    @handle_settings_opening(SyncingSettingsView, '9-MainMenuItem')
    def open_syncing_settings(self, click_attempts: int = 2) -> 'SyncingSettingsView':
        assert SyncingSettingsView().exists, 'Syncing settings view was not opened'
        return SyncingSettingsView()

    @allure.step('Choose sign out and quit in settings')
    @handle_settings_opening(SignOutPopup, '17-ExtraMenuItem')
    def open_sign_out_and_quit(self, click_attempts: int = 2) -> 'SignOutPopup':
        assert SignOutPopup().exists, 'Sign out modal was not opened'
        return SignOutPopup()

    @allure.step('Open keycard settings')
    @handle_settings_opening(KeycardSettingsView, '13-MainMenuItem')
    def open_keycard_settings(self, click_attempts: int = 2) -> 'KeycardSettingsView':
        assert KeycardSettingsView().wait_until_appears(), f'Keycard settings view was not opened'
        return KeycardSettingsView()

    @allure.step('Open ENS usernames settings')
    @handle_settings_opening(ENSSettingsView, '3-MainMenuItem')
    def open_ens_usernames_settings(self, click_attempts: int = 2) -> 'ENSSettingsView':
        assert ENSSettingsView().wait_until_appears(), 'ENS settings view was not opened'
        return ENSSettingsView()

    @allure.step('Open advanced settings')
    @handle_settings_opening(AdvancedSettingsView, '10-SettingsMenuItem')
    def open_advanced_settings(self, click_attempts: int = 2) -> 'AdvancedSettingsView':
        assert AdvancedSettingsView().wait_until_appears(), 'Advanced settings view was not opened'
        return AdvancedSettingsView()


class SettingsScreen(QObject):

    def __init__(self):
        super().__init__(settings_names.mainWindow_ProfileLayout)
        self.left_panel = LeftPanel()
