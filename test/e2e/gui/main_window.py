import logging
import time
import typing

import allure

import configs
import driver
from constants import UserAccount, CommunityData
from gui.components.community.invite_contacts import InviteContactsPopup
from gui.components.introduce_yourself_popup import IntroduceYourselfPopup
from gui.components.context_menu import ContextMenu
from gui.components.toast_message import ToastMessage
from gui.components.online_identifier import OnlineIdentifier
from gui.elements.button import Button
from gui.elements.object import QObject
from gui.elements.window import Window
from gui.objects_map import names
from gui.screens.community import CommunityScreen
from gui.screens.community_portal import CommunitiesPortal
from gui.screens.messages import MessagesScreen
from gui.screens.onboarding import OnboardingWelcomeToStatusView, ReturningLoginView
from gui.screens.settings import SettingsScreen
from gui.screens.wallet import WalletScreen
from scripts.tools.image import Image

LOG = logging.getLogger(__name__)


class LeftPanel(QObject):

    def __init__(self):
        super(LeftPanel, self).__init__(names.mainWindow_LeftPanelNavBar)
        self.profile_button = Button(names.onlineIdentifierButton)
        self._messages_button = Button(names.chatButton)
        self._communities_portal_button = Button(names.communitiesPortalButton)
        self._community_template_button = Button(names.statusCommunityMainNavBarListView_CommunityNavBarButton)
        self._settings_button = Button(names.settingsGearButton)
        self._wallet_button = Button(names.mainWalletButton)
        self._community_invite_people_context_item = QObject(names.invite_People_StatusMenuItem)

    def _open_screen_from_left_nav(self, button, screen_class, attempts: int = 2):
        for _ in range(attempts):
            button.click()
            time.sleep(0.2)
            try:
                return screen_class().wait_until_appears()
            except Exception:
                pass  # Retry if attempts remain
        raise Exception(f"Failed to open {screen_class.__name__} after {attempts} attempts")

    @allure.step('Click Chat button and open Messages screen')
    def open_messages_screen(self, attempts: int = 2) -> MessagesScreen:
        return self._open_screen_from_left_nav(self._messages_button, MessagesScreen, attempts)

    @allure.step('Click Gear button and open Settings screen')
    def open_settings(self, attempts: int = 2) -> SettingsScreen:
        return self._open_screen_from_left_nav(self._settings_button, SettingsScreen, attempts)

    @allure.step('Click Wallet button and open Wallet main screen')
    def open_wallet(self, attempts: int = 2) -> WalletScreen:
        return self._open_screen_from_left_nav(self._wallet_button, WalletScreen, attempts)

    @allure.step('Click and open online identifier')
    def open_online_identifier(self, attempts: int = 2) -> OnlineIdentifier:
        return self._open_screen_from_left_nav(self.profile_button, OnlineIdentifier, attempts)

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
        for _ in range(attempts):
            self._communities_portal_button.click()
            introduce_yourself_popup = IntroduceYourselfPopup()
            if introduce_yourself_popup.is_visible:
                introduce_yourself_popup.skip_button.click()
                introduce_yourself_popup.wait_until_hidden()
            time.sleep(0.2)
            try:
                return CommunitiesPortal().wait_until_appears()
            except Exception:
                pass  # Retry if attempts remain
        raise Exception(f"Failed to open Communities Portal after {attempts} attempts")

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


class MainWindow(Window):

    def __init__(self):
        super().__init__(names.statusDesktop_mainWindow)
        self.left_panel = LeftPanel()

    @allure.step('Create new profile')
    def create_profile(self, user_account: UserAccount):
        welcome_screen = OnboardingWelcomeToStatusView().wait_until_appears()
        profile_view = welcome_screen.open_create_your_profile_view()
        create_password_view = profile_view.open_password_view()
        splash_screen = create_password_view.create_password(user_account.password)
        splash_screen.wait_until_appears()
        splash_screen.wait_until_hidden(timeout_msec=60000)
        # since we now struggle with 3 words names, I need to change display name first
        left_panel = LeftPanel()
        profile = left_panel.open_settings().left_panel.open_profile_settings()
        profile.set_name(user_account.name)
        profile.save_changes_button.click()
        left_panel.open_wallet()
        return self

    @allure.step('Log in returning user')
    def returning_log_in(self, user_account: UserAccount):
        splash_screen = ReturningLoginView().log_in(user_account)
        splash_screen.wait_until_appears()
        splash_screen.wait_until_hidden(timeout_msec=60000)
        return self

    @allure.step('Authorize user')
    def authorize_user(self, user_account) -> 'MainWindow':
        assert isinstance(user_account, UserAccount)
        if ReturningLoginView().is_visible:
            return self.returning_log_in(user_account)
        else:
            return self.create_profile(user_account)

    @allure.step('Create community')
    def create_community(self, community_data: CommunityData) -> CommunityScreen:
        communities_portal = self.left_panel.open_communities_portal()
        create_community_form = communities_portal.open_create_community_popup()
        assert isinstance(community_data, CommunityData)
        app_screen = create_community_form.create_community(community_data)
        return app_screen

    @allure.step('Wait for notification and get text')
    def wait_for_notification(self, timeout_sec: int = configs.timeouts.UI_LOAD_TIMEOUT_SEC) -> list[str]:
        start_time = time.monotonic()

        while time.monotonic() - start_time < timeout_sec:
            try:
                return ToastMessage().get_toast_messages()
            except LookupError as err:
                LOG.info(f"Notification not found: {err}")
                time.sleep(0.1)  # Small delay to prevent CPU overuse

        raise LookupError("Notifications were not found within the timeout period.")
