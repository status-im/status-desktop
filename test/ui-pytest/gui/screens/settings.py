import typing

import allure

import driver
from constants import UserCommunityInfo
from driver import objects_access
from gui.components.wallet.testnet_mode_popup import TestnetModePopup
from gui.elements.qt.button import Button
from gui.elements.qt.object import QObject
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

    @allure.step('Open wallet settings')
    def open_wallet_settings(self):
        self._open_settings(4)
        return WalletSettingsView()


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
    def communities(self) -> typing.List[UserCommunityInfo]:
        _communities = []
        for obj in driver.findAllObjects(self._community_item.real_name):
            container = driver.objectMap.realName(obj)
            self._community_template_image.real_name['container'] = container
            self._community_template_name.real_name['container'] = container
            self._community_template_description.real_name['container'] = container
            self._community_template_members.real_name['container'] = container

            _communities.append(UserCommunityInfo(
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
    def get_community_info(self, name: str) -> UserCommunityInfo:
        for community in self.communities:
            if community.name == name:
                return community
        raise LookupError(f'Community item: {name} not found')

    @allure.step('Open community overview settings')
    def open_community_overview_settings(self, name: str):
        driver.mouseClick(self._get_community_item(name))
        return CommunitySettingsScreen().wait_until_appears()


class WalletSettingsView(QObject):

    def __init__(self):
        super().__init__('mainWindow_WalletView')
        self._wallet_network_button = Button('settings_Wallet_MainView_Networks')

    def open_networks(self):
        self._wallet_network_button.click()
        return NetworkWalletSettings().wait_until_appears()


class NetworkWalletSettings(WalletSettingsView):

    def __init__(self):
        super(NetworkWalletSettings, self).__init__()
        self._wallet_networks_item = QObject('settingsContentBaseScrollView_WalletNetworkDelegate')
        self._testnet_text_item = QObject('settingsContentBaseScrollView_Goerli_testnet_active_StatusBaseText')
        self._testnet_mode_button = Button('settings_Wallet_NetworksView_TestNet_Toggle')

    @property
    @allure.step('Get wallet networks items')
    def networks_names(self) -> typing.List[str]:
        return [str(network.title) for network in driver.findAllObjects(self._wallet_networks_item.real_name)]

    @property
    @allure.step('Get amount of testnet active items')
    def testnet_items_amount(self) -> int:
        items_amount = 0
        for item in driver.findAllObjects(self._testnet_text_item.real_name):
            if item.text == 'Goerli testnet active':
                items_amount += 1
        return items_amount

    @allure.step('Switch testnet mode')
    def switch_testnet_mode(self):
        self._testnet_mode_button.click()
        return TestnetModePopup().wait_until_appears()

    @allure.step('Check state of testnet mode switch')
    def get_testnet_mode_button_checked_state(self):
        return self._testnet_mode_button.is_checked
