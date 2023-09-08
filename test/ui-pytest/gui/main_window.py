import logging
import typing

import allure

import configs
import constants
import driver
from constants import UserAccount
from gui.components.community.invite_contacts import InviteContactsPopup
from gui.components.onboarding.before_started_popup import BeforeStartedPopUp
from gui.components.onboarding.welcome_status_popup import WelcomeStatusPopup
from gui.components.splash_screen import SplashScreen
from gui.components.user_canvas import UserCanvas
from gui.elements.qt.button import Button
from gui.elements.qt.object import QObject
from gui.elements.qt.window import Window
from gui.screens.community import CommunityScreen
from gui.screens.community_portal import CommunitiesPortal
from gui.screens.messages import MessagesScreen
from gui.screens.onboarding import AllowNotificationsView, WelcomeView, TouchIDAuthView, LoginView
from gui.screens.settings import SettingsScreen
from gui.screens.wallet import WalletScreen
from scripts.tools.image import Image

_logger = logging.getLogger(__name__)


class LeftPanel(QObject):

    def __init__(self):
        super(LeftPanel, self).__init__('mainWindow_StatusAppNavBar')
        self._profile_button = Button('mainWindow_ProfileNavBarButton')
        self._messages_button = Button('messages_navbar_StatusNavBarTabButton')
        self._communities_portal_button = Button('communities_Portal_navbar_StatusNavBarTabButton')
        self._community_template_button = Button('statusCommunityMainNavBarListView_CommunityNavBarButton')
        self._settings_button = Button('settings_navbar_StatusNavBarTabButton')
        self._wallet_button = Button('wallet_navbar_StatusNavBarTabButton')
        self._community_invite_people_context_item = QObject('invite_People_StatusMenuItem')

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
        return str(self._profile_button.object.badge.color.name)

    @allure.step('Open messages screen')
    def open_messages_screen(self) -> MessagesScreen:
        self._messages_button.click()
        return MessagesScreen().wait_until_appears()

    @allure.step('Open user canvas')
    def open_user_canvas(self) -> UserCanvas:
        self._profile_button.click()
        return UserCanvas().wait_until_appears()

    @allure.step('Verify: User is online')
    def user_is_online(self) -> bool:
        return self.user_badge_color == '#4ebc60'

    @allure.step('Verify: User is offline')
    def user_is_offline(self):
        return self.user_badge_color == '#7f8990'

    @allure.step('Verify: User is set to automatic')
    def user_is_set_to_automatic(self):
        return self.user_badge_color == '#4ebc60'

    @allure.step('Open community portal')
    def open_communities_portal(self) -> CommunitiesPortal:
        self._communities_portal_button.click()
        return CommunitiesPortal().wait_until_appears()

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

    @allure.step('Invite people in community')
    def invite_people_in_community(self, contacts: typing.List[str], message: str, community_name: str):
        driver.mouseClick(self._get_community(community_name), driver.Qt.RightButton)
        self._community_invite_people_context_item.click()
        InviteContactsPopup().wait_until_appears().invite(contacts, message)

    @allure.step('Open settings')
    def open_settings(self) -> CommunitiesPortal:
        self._settings_button.click()
        return SettingsScreen().wait_until_appears()

    @allure.step('Open Wallet section')
    def open_wallet(self) -> WalletScreen:
        self._wallet_button.click()
        return WalletScreen().wait_until_appears()


class MainWindow(Window):

    def __init__(self):
        super(MainWindow, self).__init__('statusDesktop_mainWindow')
        self.left_panel = LeftPanel()

    @allure.step('Sign Up user')
    def sign_up(self, user_account: UserAccount = constants.user.community_params):
        if configs.system.IS_MAC:
            AllowNotificationsView().wait_until_appears().allow()
        BeforeStartedPopUp().get_started()
        wellcome_screen = WelcomeView().wait_until_appears()
        profile_view = wellcome_screen.get_keys().generate_new_keys()
        profile_view.set_display_name(user_account.name)
        details_view = profile_view.next()
        create_password_view = details_view.next()
        confirm_password_view = create_password_view.create_password(user_account.password)
        confirm_password_view.confirm_password(user_account.password)
        if configs.system.IS_MAC:
            TouchIDAuthView().wait_until_appears().prefer_password()
        SplashScreen().wait_until_appears().wait_until_hidden()
        if not configs.DEV_BUILD:
            WelcomeStatusPopup().confirm()
        return self

    @allure.step('Log in user')
    def log_in(self, user_account: UserAccount):
        LoginView().log_in(user_account)
        SplashScreen().wait_until_appears().wait_until_hidden()
        if not configs.DEV_BUILD:
            WelcomeStatusPopup().wait_until_appears().confirm()
        return self

    @allure.step('Authorize user')
    def authorize_user(self, user_account) -> 'MainWindow':
        self.prepare()
        assert isinstance(user_account, UserAccount)
        if LoginView().is_visible:
            return self.log_in(user_account)
        else:
            return self.sign_up(user_account)

    @allure.step('Create community')
    def create_community(self, params: dict) -> CommunityScreen:
        communities_portal = self.left_panel.open_communities_portal()
        create_community_form = communities_portal.open_create_community_popup()
        app_screen = create_community_form.create(params)
        return app_screen
