import typing

import allure

import driver
from constants import UserCommunity
from driver import objects_access
from gui.elements.qt.button import Button
from gui.elements.qt.object import QObject
from gui.elements.qt.scroll import Scroll
from gui.elements.qt.text_label import TextLabel
from gui.screens.community_settings import CommunitySettingsScreen


class SettingsScreen(QObject):

    def __init__(self):
        super().__init__('mainWindow_ProfileLayout')
        self._settings_section_template = QObject('scrollView_AppMenuItem_StatusNavigationListItem')

    def _open_settings(self, index: int):
        self._settings_section_template.real_name['objectName'] = f'{index}-AppMenuItem'
        self._settings_section_template.click()

    @allure.step('Open communities settings')
    def open_communities_settings(self):
        self._open_settings(12)
        return CommunitiesSettingsView()


class CommunitiesSettingsView(QObject):

    def __init__(self):
        super().__init__('mainWindow_CommunitiesView')
        self._community_item = QObject('settingsContentBaseScrollView_listItem_StatusListItem')
        self._community_template_image = QObject('settings_iconOrImage_StatusSmartIdenticon')
        self._community_template_name = TextLabel('settings_Name_StatusTextWithLoadingState')
        self._community_template_description = TextLabel('settings_statusListItemSubTitle')
        self._community_template_members = TextLabel('settings_member_StatusTextWithLoadingState')
        self._community_template_button = Button('settings_StatusFlatButton')

    @property
    @allure.step('Get communities')
    def communities(self) -> typing.List[UserCommunity]:
        _communities = []
        for obj in driver.findAllObjects(self._community_item.real_name):
            container = driver.objectMap.realName(obj)
            self._community_template_image.real_name['container'] = container
            self._community_template_name.real_name['container'] = container
            self._community_template_description.real_name['container'] = container
            self._community_template_members.real_name['container'] = container

            _communities.append(UserCommunity(
                self._community_template_name.text,
                self._community_template_description.text,
                self._community_template_members.text,
                self._community_template_image.image
            ))
        return _communities

    def _get_community_item(self, name: str):
        for obj in driver.findAllObjects(self._community_item.real_name):
            for item in objects_access.walk_children(obj):
                if getattr(item, 'text', '') == name:
                    return obj
        raise LookupError(f'Community item: {name} not found')

    @allure.step('Open community info')
    def get_community_info(self, name: str) -> UserCommunity:
        for community in self.communities:
            if community.name == name:
                return community
        raise LookupError(f'Community item: {name} not found')

    @allure.step('Open community overview settings')
    def open_community_overview_settings(self, name: str):
        driver.mouseClick(self._get_community_item(name))
        return CommunitySettingsScreen().wait_until_appears()


class KeycardSettingsView(QObject):

    def __init__(self):
        super(KeycardSettingsView, self).__init__('mainWindow_KeycardView')
        self._scroll = Scroll('settingsContentBaseScrollView_Flickable')
        self._setup_keycard_with_existing_account_button = Button('settingsContentBaseScrollView_setupFromExistingKeycardAccount_StatusListItem')
        self._create_new_keycard_account_button = Button('settingsContentBaseScrollView_createNewKeycardAccount_StatusListItem')
        self._import_restore_via_seed_phrase_button = Button('settingsContentBaseScrollView_importRestoreKeycard_StatusListItem')
        self._import_from_keycard_button = Button('settingsContentBaseScrollView_importFromKeycard_StatusListItem')
        self._check_whats_on_keycard_button = Button('settingsContentBaseScrollView_checkWhatsNewKeycard_StatusListItem')
        self._factory_reset_keycard_button = Button('settingsContentBaseScrollView_factoryResetKeycard_StatusListItem')

    @allure.step('Check that keycard screen displayed')
    def check_keycard_screen_loaded(self):
        assert KeycardSettingsView().is_visible

    @allure.step('Check that all keycard options displayed')
    def all_keycard_options_available(self):
        assert self._setup_keycard_with_existing_account_button.is_visible, f'Setup keycard with existing account not visible'
        assert self._create_new_keycard_account_button.is_visible, f'Create new keycard button not visible'
        assert self._import_restore_via_seed_phrase_button.is_visible, f'Import and restore via seed phrase button not visible'
        self._scroll.vertical_scroll_to(self._import_from_keycard_button)
        assert driver.waitFor(lambda: self._import_from_keycard_button.is_visible, 10000), f'Import keycard button not visible'
        assert driver.waitFor(lambda: self._check_whats_on_keycard_button.is_visible, 10000), f'Check whats new keycard button not visible'
        assert driver.waitFor(lambda: self._factory_reset_keycard_button.is_visible, 10000), f'Factory reset keycard button not visible'
