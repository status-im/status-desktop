import logging
import time
import typing

import allure

import configs
import driver
from constants import UserAccount, RandomUser, RandomCommunity, CommunityData
from gui.components.community.invite_contacts import InviteContactsPopup
from gui.components.onboarding.share_usage_data_popup import ShareUsageDataPopup
from gui.components.context_menu import ContextMenu
from gui.components.onboarding.before_started_popup import BeforeStartedPopUp
from gui.components.onboarding.beta_consent_popup import BetaConsentPopup
from gui.components.signing_phrase_popup import SigningPhrasePopup
from gui.components.splash_screen import SplashScreen
from gui.components.toast_message import ToastMessage
from gui.components.online_identifier import OnlineIdentifier
from gui.elements.button import Button
from gui.elements.object import QObject
from gui.elements.window import Window
from gui.objects_map import names
from gui.screens.community import CommunityScreen
from gui.screens.community_portal import CommunitiesPortal
from gui.screens.messages import MessagesScreen
from gui.screens.onboarding import AllowNotificationsView, WelcomeToStatusView, BiometricsView, LoginView, \
    YourEmojihashAndIdenticonRingView
from gui.screens.settings import SettingsScreen
from gui.screens.wallet import WalletScreen
from scripts.tools.image import Image

LOG = logging.getLogger(__name__)


class LeftPanel(QObject):

    def __init__(self):
        super(LeftPanel, self).__init__(names.mainWindow_StatusAppNavBar)
        self.profile_button = Button(names.mainWindow_ProfileNavBarButton)
        self._messages_button = Button(names.messages_navbar_StatusNavBarTabButton)
        self._communities_portal_button = Button(names.communities_Portal_navbar_StatusNavBarTabButton)
        self._community_template_button = Button(names.statusCommunityMainNavBarListView_CommunityNavBarButton)
        self._settings_button = Button(names.settings_navbar_StatusNavBarTabButton)
        self._wallet_button = Button(names.wallet_navbar_StatusNavBarTabButton)
        self._community_invite_people_context_item = QObject(names.invite_People_StatusMenuItem)

    @property
    @allure.step('Get communities names')
    def communities(self) -> typing.List[str]:
        community_names = []
        for obj in driver.findAllObjects(self._community_template_button.real_name):
            community_names.append(obj.name)

        return community_names

    @property
    @allure.step('Get user badge color')
    def user_badge_color(self) -> str:
        return str(self.profile_button.object.badge.color.name)

    @allure.step('Open messages screen')
    def open_messages_screen(self) -> MessagesScreen:
        self._messages_button.click()
        return MessagesScreen()

    @allure.step('Open online identifier')
    def open_online_identifier(self, attempts: int = 2) -> OnlineIdentifier:
        time.sleep(0.5)
        self.profile_button.click()
        try:
            return OnlineIdentifier().wait_until_appears()
        except Exception as ex:
            if attempts:
                self.open_online_identifier(attempts - 1)
            else:
                raise ex

    @allure.step('Set user to online')
    def set_user_to_online(self):
        self.open_online_identifier().set_user_state_online()

    @allure.step('Verify: User is online')
    def user_is_online(self) -> bool:
        return self.user_badge_color == '#4ebc60'

    @allure.step('Set user to offline')
    def set_user_to_offline(self):
        self.open_online_identifier().set_user_state_offline()

    @allure.step('Verify: User is offline')
    def user_is_offline(self):
        return self.user_badge_color == '#7f8990'

    @allure.step('Set user to automatic')
    def set_user_to_automatic(self):
        self.open_online_identifier().set_user_automatic_state()

    @allure.step('Verify: User is set to automatic')
    def user_is_set_to_automatic(self):
        return self.user_badge_color == '#4ebc60'

    @allure.step('Open community portal')
    def open_communities_portal(self, attempts: int = 2) -> CommunitiesPortal:
        self._communities_portal_button.click()
        try:
            return CommunitiesPortal().wait_until_appears()
        except Exception as ex:
            if attempts:
                self.open_communities_portal(attempts - 1)
            else:
                raise ex

    def _get_community(self, name: str):
        community_names = []
        for obj in driver.findAllObjects(self._community_template_button.real_name):
            community_names.append(str(obj.name))
            if str(obj.name) == str(name):
                return obj
        raise LookupError(f'Community: {name} not found in {community_names}')

    @allure.step('Open community')
    def select_community(self, name: str) -> CommunityScreen:
        driver.mouseClick(self._get_community(name))
        return CommunityScreen().wait_until_appears()

    @allure.step('Get community logo')
    def get_community_logo(self, name: str) -> Image:
        return Image(driver.objectMap.realName(self._get_community(name)))

    @allure.step('Open context menu for community')
    def open_community_context_menu(self, name: str) -> ContextMenu:
        community = QObject(driver.objectMap.realName(self._get_community(name)))
        community.right_click()
        return ContextMenu().wait_until_appears()

    @allure.step('Invite people in community')
    def invite_people_in_community(self, contacts: typing.List[str], message: str, community_name: str):
        driver.mouseClick(self._get_community(community_name), driver.Qt.RightButton)
        self._community_invite_people_context_item.click()
        InviteContactsPopup().wait_until_appears().invite(contacts, message)

    @allure.step('Open settings')
    def open_settings(self, attempts: int = 2) -> SettingsScreen:
        self._settings_button.click()
        time.sleep(0.5)
        try:
            SettingsScreen().left_panel.wait_until_appears()
            return SettingsScreen()
        except Exception as ex:
            if attempts:
                self.open_settings(attempts - 1)
            else:
                raise ex

    @allure.step('Open Wallet section')
    def open_wallet(self, attempts: int = 3) -> WalletScreen:
        # TODO https://github.com/status-im/status-desktop/issues/15345
        self._wallet_button.click(timeout=30)
        try:
            return WalletScreen()
        except Exception as ex:
            if attempts:
                return self.open_wallet(attempts - 1)
            else:
                raise ex


class MainWindow(Window):

    def __init__(self):
        super(MainWindow, self).__init__(names.statusDesktop_mainWindow)
        self.left_panel = LeftPanel()

    def prepare(self) -> 'Window':
        return super().prepare()

    @allure.step('Sign Up user')
    def sign_up(self, user_account: UserAccount):
        BeforeStartedPopUp().get_started()
        welcome_screen = WelcomeToStatusView().wait_until_appears()
        profile_view = welcome_screen.get_keys().generate_new_keys()
        profile_view.set_display_name(user_account.name)
        create_password_view = profile_view.next()
        confirm_password_view = create_password_view.create_password(user_account.password)
        confirm_password_view.confirm_password(user_account.password)
        if configs.system.get_platform() == "Darwin":
            BiometricsView().wait_until_appears().prefer_password()
        SplashScreen().wait_until_appears().wait_until_hidden()
        YourEmojihashAndIdenticonRingView().verify_emojihash_view_present().next()
        if configs.system.get_platform() == "Darwin":
            AllowNotificationsView().start_using_status()
        SplashScreen().wait_until_appears().wait_until_hidden()
        if not configs.system.TEST_MODE and not configs._local.DEV_BUILD:
            time.sleep(1)
            BetaConsentPopup().confirm()
        assert SigningPhrasePopup().ok_got_it_button.is_visible
        SigningPhrasePopup().confirm_phrase()
        return self

    @allure.step('Log in user')
    def log_in(self, user_account: UserAccount):
        share_updates_popup = ShareUsageDataPopup()
        LoginView().log_in(user_account)
        SplashScreen().wait_until_appears().wait_until_hidden()
        if not configs.system.TEST_MODE and not configs._local.DEV_BUILD:
            BetaConsentPopup().confirm()
        if SigningPhrasePopup().is_visible:
            SigningPhrasePopup().confirm_phrase()
        if share_updates_popup.is_visible:
            share_updates_popup.skip()
        return self

    @allure.step('Authorize user')
    def authorize_user(self, user_account) -> 'MainWindow':
        assert isinstance(user_account, UserAccount)
        if LoginView().is_visible:
            return self.log_in(user_account)
        else:
            return self.sign_up(user_account)

    @allure.step('Create community')
    def create_community(self, community_data: CommunityData) -> CommunityScreen:
        communities_portal = self.left_panel.open_communities_portal()
        create_community_form = communities_portal.open_create_community_popup()
        assert isinstance(community_data, CommunityData)
        app_screen = create_community_form.create_community(community_data)
        return app_screen

    @allure.step('Wait for notification and get text')
    def wait_for_notification(self, timeout_msec: int = configs.timeouts.UI_LOAD_TIMEOUT_MSEC) -> list[str]:
        started_at = time.monotonic()
        while True:
            try:
                return ToastMessage().get_toast_messages()
            except LookupError as err:
                LOG.info(err)
                if time.monotonic() - started_at > timeout_msec:
                    raise LookupError(f'Notifications are not found')
