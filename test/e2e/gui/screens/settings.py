from objectmaphelper import RegularExpression
import time
import typing

import allure

import configs.timeouts
import driver

from constants import UserCommunityInfo, wallet_account_list_item
from constants.syncing import SyncingSettings
from driver import objects_access
from driver.objects_access import walk_children
from gui.components.back_up_your_seed_phrase_popup import BackUpYourSeedPhrasePopUp
from gui.components.change_password_popup import ChangePasswordPopup
from gui.components.community.authenticate_popup import AuthenticatePopup
from gui.components.settings.send_contact_request_popup import SendContactRequest
from gui.components.settings.sync_new_device_popup import SyncNewDevicePopup
from gui.components.social_links_popup import SocialLinksPopup
from gui.components.wallet.testnet_mode_popup import TestnetModePopup
from gui.components.wallet.wallet_account_popups import AccountPopup
from gui.elements.button import Button
from gui.elements.check_box import CheckBox
from gui.elements.list import List
from gui.elements.object import QObject
from gui.elements.scroll import Scroll
from gui.elements.text_edit import TextEdit
from gui.elements.text_label import TextLabel
from gui.screens.community_settings import CommunitySettingsScreen
from gui.screens.messages import MessagesScreen
from scripts.tools.image import Image


class LeftPanel(QObject):

    def __init__(self):
        super().__init__('mainWindow_LeftTabView')
        self._settings_section_template = QObject('scrollView_MenuItem_StatusNavigationListItem')

    def _open_settings(self, object_name: str):
        self._settings_section_template.real_name['objectName'] = object_name
        self._settings_section_template.click()

    @allure.step('Check back up seed option menu item presence')
    def check_back_up_seed_option_present(self):
        self._settings_section_template.real_name['objectName'] = '17-MainMenuItem'
        return self._settings_section_template.is_visible

    @allure.step('Open messaging settings')
    def open_messaging_settings(self) -> 'MessagingSettingsView':
        self._open_settings('3-AppMenuItem')
        return MessagingSettingsView()

    @allure.step('Open communities settings')
    def open_communities_settings(self) -> 'CommunitiesSettingsView':
        self._open_settings('12-AppMenuItem')
        return CommunitiesSettingsView()

    @allure.step('Open wallet settings')
    def open_wallet_settings(self):
        self._open_settings('4-AppMenuItem')
        return WalletSettingsView()

    @allure.step('Open profile settings')
    def open_profile_settings(self):
        self._open_settings('0-MainMenuItem')
        return ProfileSettingsView()

    @allure.step('Choose back up seed phrase in settings')
    def open_back_up_seed_phrase(self):
        self._open_settings('17-MainMenuItem')
        return BackUpYourSeedPhrasePopUp()

    @allure.step('Open syncing settings')
    def open_syncing_settings(self):
        self._open_settings('8-MainMenuItem')
        return SyncingSettingsView()


class SettingsScreen(QObject):

    def __init__(self):
        super().__init__('mainWindow_ProfileLayout')
        self.left_panel = LeftPanel()


class ProfileSettingsView(QObject):

    def __init__(self):
        super().__init__('mainWindow_MyProfileView')
        self._scroll_view = Scroll('settingsContentBaseScrollView_Flickable')
        self._display_name_text_field = TextEdit('displayName_TextEdit')
        self._save_button = Button('settingsSave_StatusButton')
        self._change_password_button = Button('change_password_button')
        self._bio_text_field = TextEdit('bio_TextEdit')
        self._add_more_links_label = TextLabel('addMoreSocialLinks')
        self._links_list = QObject('linksView')

    @property
    @allure.step('Get display name')
    def display_name(self) -> str:
        self._scroll_view.vertical_scroll_to(self._display_name_text_field)
        return self._display_name_text_field.text

    @allure.step('Set user name')
    def set_name(self, value: str):
        self._scroll_view.vertical_scroll_to(self._display_name_text_field)
        self._display_name_text_field.text = value
        self.save_changes()

    @property
    @allure.step('Get bio')
    def bio(self) -> str:
        self._scroll_view.vertical_scroll_to(self._bio_text_field)
        return self._bio_text_field.text

    @bio.setter
    @allure.step('Set bio')
    def bio(self, value: str):
        self._scroll_view.vertical_scroll_to(self._bio_text_field)
        self._bio_text_field.text = value
        self.save_changes()

    @property
    @allure.step('Get social links')
    def social_links(self) -> dict:
        self._scroll_view.vertical_scroll_to(self._add_more_links_label)
        links = {}
        for link_name in walk_children(
                driver.waitForObjectExists(self._links_list.real_name, configs.timeouts.UI_LOAD_TIMEOUT_MSEC)):
            if getattr(link_name, 'id', '') == 'draggableDelegate':
                for link_value in walk_children(link_name):
                    if getattr(link_value, 'id', '') == 'textMouseArea':
                        links[str(link_name.title)] = str(driver.object.parent(link_value).text)
        return links

    @social_links.setter
    @allure.step('Set social links')
    def social_links(self, links):
        links = {
            'Twitter': [links[0]],
            'Personal site': [links[1]],
            'Github': [links[2]],
            'YouTube channel': [links[3]],
            'Discord handle': [links[4]],
            'Telegram handle': [links[5]],
            'Custom link': [links[6], links[7]],
        }

        for network, link in links.items():
            social_links_popup = self.open_social_links_popup()
            social_links_popup.add_link(network, link)

    @allure.step('Verify social links')
    def verify_social_links(self, links):
        twitter = links[0]
        personal_site = links[1]
        github = links[2]
        youtube = links[3]
        discord = links[4]
        telegram = links[5]
        custom_link_text = links[6]
        custom_link = links[7]

        actual_links = self.social_links

        assert actual_links['Twitter'] == twitter
        assert actual_links['Personal site'] == personal_site
        assert actual_links['Github'] == github
        assert actual_links['YouTube channel'] == youtube
        assert actual_links['Discord handle'] == discord
        assert actual_links['Telegram handle'] == telegram
        assert actual_links[custom_link_text] == custom_link

    @allure.step('Open social links form')
    def open_social_links_popup(self):
        self._scroll_view.vertical_scroll_to(self._add_more_links_label)
        self._add_more_links_label.click()
        return SocialLinksPopup().wait_until_appears()

    @allure.step('Save changes')
    def save_changes(self):
        self._save_button.click()

    @allure.step('Open change password form')
    def open_change_password_popup(self):
        self._change_password_button.click()
        return ChangePasswordPopup().wait_until_appears()


class MessagingSettingsView(QObject):

    def __init__(self):
        super().__init__('mainWindow_MessagingView')
        self._contacts_button = Button('contactsListItem_btn_StatusContactRequestsIndicatorListItem')

    @allure.step('Open contacts settings')
    def open_contacts_settings(self) -> 'ContactsSettingsView':
        self._contacts_button.click()
        return ContactsSettingsView().wait_until_appears()


class PendingRequest:

    def __init__(self, obj):
        self.object = obj
        self.icon: typing.Optional[Image] = None
        self.contact: typing.Optional[Image] = None
        self._accept_button: typing.Optional[Button] = None
        self._reject_button: typing.Optional[Button] = None
        self._open_canvas_button: typing.Optional[Button] = None
        self.init_ui()

    def __repr__(self):
        return self.contact

    def init_ui(self):
        for child in walk_children(self.object):
            if str(getattr(child, 'id', '')) == 'iconOrImage':
                self.icon = Image(driver.objectMap.realName(child))
            elif str(getattr(child, 'id', '')) == 'menuButton':
                self._open_canvas_button = Button(name='', real_name=driver.objectMap.realName(child))
            elif str(getattr(child, 'objectName', '')) == 'checkmark-circle-icon':
                self._accept_button = Button(name='', real_name=driver.objectMap.realName(child))
            elif str(getattr(child, 'objectName', '')) == 'close-circle-icon':
                self._reject_button = Button(name='', real_name=driver.objectMap.realName(child))
            elif str(getattr(child, 'id', '')) == 'statusListItemTitle':
                self.contact = str(child.text)

    def accept(self) -> MessagesScreen:
        assert self._accept_button is not None, 'Button not found'
        self._accept_button.click()
        return MessagesScreen().wait_until_appears()


class ContactsSettingsView(QObject):

    def __init__(self):
        super().__init__('mainWindow_ContactsView')
        self._contact_request_button = Button('mainWindow_Send_contact_request_to_chat_key_StatusButton')
        self._pending_request_tab = Button('contactsTabBar_Pending_Requests_StatusTabButton')
        self._pending_requests_list = List('settingsContentBaseScrollView_ContactListPanel')

    @property
    @allure.step('Get all pending requests')
    def pending_requests(self) -> typing.List[PendingRequest]:
        self._pending_request_tab.click()
        return [PendingRequest(item) for item in self._pending_requests_list.items]

    @allure.step('Open contacts request form')
    def open_contact_request_form(self) -> SendContactRequest:
        self._contact_request_button.click()
        return SendContactRequest().wait_until_appears()

    @allure.step('Open contacts request form')
    def send_contacts_request(self):
        LeftPanel().open_messaging_settings().open_contacts_settings().open_contact_request_form()

    @allure.step('Accept contact request')
    def accept_contact_request(
            self, contact: str, timeout_sec: int = configs.timeouts.MESSAGING_TIMEOUT_SEC) -> MessagesScreen:
        self._pending_request_tab.click()
        started_at = time.monotonic()
        request = None
        while request is None:
            requests = self.pending_requests
            for _request in requests:
                if _request.contact == contact:
                    request = _request
            assert time.monotonic() - started_at < timeout_sec, f'Contact: {contact} not found in {requests}'
        return request.accept()


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


class KeycardSettingsView(QObject):

    def __init__(self):
        super(KeycardSettingsView, self).__init__('mainWindow_KeycardView')
        self._scroll = Scroll('settingsContentBaseScrollView_Flickable')
        self._setup_keycard_with_existing_account_button = Button('setupFromExistingKeycardAccount_StatusListItem')
        self._create_new_keycard_account_button = Button('createNewKeycardAccount_StatusListItem')
        self._import_restore_via_seed_phrase_button = Button('importRestoreKeycard_StatusListItem')
        self._import_from_keycard_button = Button('importFromKeycard_StatusListItem')
        self._check_whats_on_keycard_button = Button('checkWhatsNewKeycard_StatusListItem')
        self._factory_reset_keycard_button = Button('factoryResetKeycard_StatusListItem')

    @allure.step('Check that keycard screen displayed')
    def check_keycard_screen_loaded(self):
        assert KeycardSettingsView().is_visible

    @allure.step('Check that all keycard options displayed')
    def all_keycard_options_available(self):
        assert self._setup_keycard_with_existing_account_button.is_visible, f'Setup keycard with existing account not visible'
        assert self._create_new_keycard_account_button.is_visible, f'Create new keycard button not visible'
        assert self._import_restore_via_seed_phrase_button.is_visible, f'Import and restore via seed phrase button not visible'
        self._scroll.vertical_down_to(self._import_from_keycard_button)
        assert driver.waitFor(lambda: self._import_from_keycard_button.is_visible,
                              configs.timeouts.UI_LOAD_TIMEOUT_MSEC), f'Import keycard button not visible'
        assert driver.waitFor(lambda: self._check_whats_on_keycard_button.is_visible,
                              configs.timeouts.UI_LOAD_TIMEOUT_MSEC), f'Check whats new keycard button not visible'
        assert driver.waitFor(lambda: self._factory_reset_keycard_button.is_visible,
                              configs.timeouts.UI_LOAD_TIMEOUT_MSEC), f'Factory reset keycard button not visible'


class WalletSettingsView(QObject):

    def __init__(self):
        super().__init__('mainWindow_WalletView')
        self._wallet_settings_add_new_account_button = Button('settings_Wallet_MainView_AddNewAccountButton')
        self._wallet_network_button = Button('settings_Wallet_MainView_Networks')
        self._account_order_button = Button('settingsContentBaseScrollView_accountOrderItem_StatusListItem')

    @allure.step('Open add account pop up in wallet settings')
    def open_add_account_pop_up(self):
        self._wallet_settings_add_new_account_button.click()
        return AccountPopup().wait_until_appears()

    @allure.step('Open networks in wallet settings')
    def open_networks(self):
        self._wallet_network_button.click()
        return NetworkWalletSettings().wait_until_appears()

    @allure.step('Open account order in wallet settings')
    def open_account_order(self):
        self._account_order_button.click()
        return EditAccountOrderSettings().wait_until_appears()


class NetworkWalletSettings(WalletSettingsView):

    def __init__(self):
        super(NetworkWalletSettings, self).__init__()
        self._testnet_text_item = QObject('settingsContentBaseScrollView_Goerli_testnet_active_StatusBaseText')
        self._testnet_mode_toggle = Button('settings_Wallet_NetworksView_TestNet_Toggle')
        self._testnet_mode_title = TextLabel('settings_Wallet_NetworksView_TestNet_Toggle_Title')
        self._back_button = Button('main_toolBar_back_button')
        self._mainnet_network_item = QObject('networkSettingsNetworks_Mainnet')
        self._mainnet_goerli_network_item = QObject('networkSettingsNetworks_Mainnet_Goerli')
        self._mainnet_goerli_network_item_test_label = TextLabel('networkSettingsNetowrks_Mainnet_Testlabel')
        self._optimism_network_item = QObject('networkSettingsNetworks_Optimism')
        self._optimism_goerli_network_item = QObject('networkSettingsNetworks_Optimism_Goerli')
        self._arbitrum_network_item = QObject('networkSettingsNetworks_Arbitrum')
        self._arbitrum__goerli_network_item = QObject('networkSettingsNetworks_Arbitrum_Goerli')
        self._wallet_network_item_template = QObject('settingsContentBaseScrollView_WalletNetworkDelegate_template')
        self._wallet_network_item_goerli_sensor = QObject('networkSettingsNetworks_Mainnet_Goerli_sensor')
        self._wallet_network_item_goerli_testlabel = TextLabel('networkSettingsNetowrks_Mainnet_Testlabel')

    @allure.step('Check networks item title')
    def get_network_item_attribute_by_id_and_attr_name(self, attribute_name, network_id):
        self._wallet_network_item_template.real_name['objectName'] = RegularExpression(
            f'walletNetworkDelegate_.*_{network_id}')
        return self._wallet_network_item_template.get_object_attribute(attribute_name)

    @allure.step('Open network to check the details')
    def click_network_item_to_open_edit_view(self, network_id):
        self._wallet_network_item_template.real_name['objectName'] \
            = RegularExpression(f'walletNetworkDelegate_.*_{network_id}')
        self._wallet_network_item_template.click()
        return EditNetworkSettings().wait_until_appears()

    @allure.step('Verify Testnet toggle subtitle')
    def get_testnet_toggle_subtitle(self):
        return self._testnet_mode_title.text

    @allure.step('Verify back to Wallet settings button')
    def is_back_to_wallet_settings_button_present(self):
        return self._back_button.is_visible

    @property
    @allure.step('Get amount of testnet active items')
    def testnet_items_amount(self) -> int:
        items_amount = 0
        for item in driver.findAllObjects(self._testnet_text_item.real_name):
            if item.text == 'Goerli testnet active':
                items_amount += 1
        return items_amount

    @allure.step('Switch testnet mode toggle')
    def switch_testnet_mode_toggle(self):
        self._testnet_mode_toggle.click()
        return TestnetModePopup().wait_until_appears()

    @allure.step('Get testnet mode toggle status')
    def is_testnet_mode_toggle_checked(self):
        return self._testnet_mode_toggle.is_checked


class EditNetworkSettings(WalletSettingsView):
    def __init__(self):
        super(EditNetworkSettings, self).__init__()
        self._live_network_tab = Button('editNetworkLiveButton')
        self._test_network_tab = Button('editNetworkTestButton')
        self._network_name = TextEdit('editNetworkNameInput')
        self._network_short_name = TextEdit('editNetworkShortNameInput')
        self._network_chaid_id = TextEdit('editNetworkChainIdInput')
        self._network_native_token_symbol = TextEdit('editNetworkSymbolInput')
        self._network_main_json_rpc_url = TextEdit('editNetworkMainRpcInput')
        self._network_failover_json_rpc_url = TextEdit('editNetworkFailoverRpcUrlInput')
        self._network_block_explorer = TextEdit('editNetworkExplorerInput')
        self._network_acknowledgment_checkbox = CheckBox('editNetworkAknowledgmentCheckbox')
        self._network_revert_to_default = Button('editNetworkRevertButton')
        self._network_save_changes = Button('editNetworkSaveButton')
        self._network_edit_view_back_button = Button('main_toolBar_back_button')
        self._network_edit_scroll = Scroll('settingsContentBaseScrollView_Flickable')
        self._network_edit_main_rpc_url_error_message = QObject('mainRpcUrlInputObject')
        self._network_edit_failover_rpc_url_error_message = QObject('failoverRpcUrlInputObject')

    @allure.step('Verify elements for the edit network view')
    def check_available_elements_on_edit_view(self):
        assert self._network_edit_view_back_button.exists, f"Back button is not present"
        assert self._live_network_tab.exists, f"Live tab is not present"
        assert self._test_network_tab.exists, f"Test tab is not present"
        assert self._network_name.exists, f"Network name input field is not present"
        assert self._network_short_name.exists, f"Short name input field is not present"
        assert self._network_chaid_id.exists, f"Chaid Id input field is not present"
        assert self._network_native_token_symbol.exists, f"Native token symbol input field is not present"
        assert self._network_main_json_rpc_url.exists, f"Main JSON RPC URL input field is not present"
        assert self._network_failover_json_rpc_url.exists, f"Failover JSON RPC URL input field is not present"
        assert self._network_block_explorer.exists, f"Block explorer input field is not present"

        self._network_edit_scroll.vertical_down_to(self._network_acknowledgment_checkbox)
        assert driver.waitFor(lambda: self._network_acknowledgment_checkbox.exists,
                              configs.timeouts.UI_LOAD_TIMEOUT_MSEC), f"Acknowldegment checkbox is not present"

        self._network_edit_scroll.vertical_down_to(self._network_revert_to_default)
        assert driver.waitFor(lambda: self._network_revert_to_default.exists,
                              configs.timeouts.UI_LOAD_TIMEOUT_MSEC), f"Revert to default button is not present"

        assert self._network_save_changes.exists, f"Save changes button is not present"

    @allure.step('Edit Main RPC url input field')
    def edit_network_main_json_rpc_url_input(self, test_value):
        self._network_main_json_rpc_url.text = test_value

    @allure.step('Edit Failover RPC url input field')
    def edit_network_failover_json_rpc_url_input(self, test_value):
        self._network_failover_json_rpc_url.text = test_value

    @allure.step('Check acknowledgment checkbox')
    def check_acknowledgement_checkbox(self, value: bool):
        self._network_acknowledgment_checkbox.set(value)
        return self

    @allure.step('Get the text for consent when changing RPC urls')
    def get_acknowledgement_checkbox_text(self, attr):
        text = str(self._network_acknowledgment_checkbox.get_object_attribute(attr))
        return text

    @allure.step('Get error message for Main RPC URL input')
    def get_main_rpc_url_error_message_text(self):
        error = str(self._network_edit_main_rpc_url_error_message.object.errorMessageCmp.text)
        return error

    @allure.step('Get error message for Failover RPC URL input')
    def get_failover_rpc_url_error_message_text(self):
        error = str(self._network_edit_failover_rpc_url_error_message.object.errorMessageCmp.text)
        return error

    @allure.step('Click Revert to default button')
    def revert_to_default(self, attempts=2):
        current_value_main = self._network_main_json_rpc_url.text
        current_value_failover = self._network_failover_json_rpc_url.text
        self._network_edit_scroll.vertical_down_to(self._network_revert_to_default)
        self._network_revert_to_default.click()
        if (current_value_main == self._network_main_json_rpc_url.text
                and current_value_failover == self._network_failover_json_rpc_url.text):
            assert attempts > 0, "value not reverted"
            time.sleep(1)
            self.revert_to_default(attempts-1)

    @allure.step('Get value from Main json rpc input')
    def get_edit_network_main_json_rpc_url_value(self):
        return self._network_main_json_rpc_url.text

    @allure.step('Get value from Failover json rpc input')
    def get_edit_network_failover_json_rpc_url_value(self):
        return self._network_failover_json_rpc_url.text


class EditAccountOrderSettings(WalletSettingsView):

    def __init__(self):
        super(EditAccountOrderSettings, self).__init__()
        self._account_item = QObject('settingsContentBaseScrollView_draggableDelegate_StatusDraggableListItem')
        self._accounts_list = QObject('statusDesktop_mainWindow')
        self._text_item = QObject('settingsContentBaseScrollView_StatusBaseText')
        self._back_button = Button('main_toolBar_back_button')

    @property
    @allure.step('Get edit account order recommendations')
    def account_recommendations(self):
        account_recommendations = []
        for obj in driver.findAllObjects(self._text_item.real_name):
            account_recommendations.append(obj.text)
        return account_recommendations

    @property
    @allure.step('Get accounts')
    def accounts(self) -> typing.List[wallet_account_list_item]:
        _accounts = []
        for account_item in driver.findAllObjects(self._account_item.real_name):
            element = QObject(name='', real_name=driver.objectMap.realName(account_item))
            name = str(account_item.title)
            icon = None
            for child in objects_access.walk_children(account_item):
                if getattr(child, 'objectName', '') == 'identicon':
                    icon = Image(driver.objectMap.realName(child))
                    break
            _accounts.append(wallet_account_list_item(name, icon, element))

        return sorted(_accounts, key=lambda account: account.object.y)

    @allure.step('Get account in accounts list')
    def _get_account_item(self, name: str):
        for obj in driver.findAllObjects(self._account_item.real_name):
            if getattr(obj, 'title', '') == name:
                return obj
        raise LookupError(f'Account item: {name} not found')

    @allure.step('Get eye icon on watch-only account')
    def get_eye_icon(self, name: str):
        for child in objects_access.walk_children(self._get_account_item(name)):
            if getattr(child, 'objectName', '') == 'show-icon':
                return child
        raise LookupError(f'Eye icon not found on {name} account item')

    @allure.step('Drag account to change the order')
    def drag_account(self, name: str, index: int):
        assert driver.waitFor(lambda: len([account for account in self.accounts if account.name == name]) == 1), \
            'Account not found or found more then one'
        bounds = [account for account in self.accounts if account.name == name][0].object.bounds
        d_bounds = self.accounts[index].object.bounds
        driver.mouse.press_and_move(self._accounts_list.object, bounds.x, bounds.y, d_bounds.x, d_bounds.y)

    @allure.step('Verify that back button is present')
    def is_back_button_present(self) -> bool:
        return self._back_button.is_visible


class SyncingSettingsView(QObject):

    def __init__(self):
        super().__init__('mainWindow_SyncingView')
        self._setup_syncing_button = Button('settings_Setup_Syncing_StatusButton')
        self._backup_data_button = Button('settings_Backup_Data_StatusButton')
        self._sync_new_device_instructions_header = TextLabel('settings_Sync_New_Device_Header')
        self._sync_new_device_instructions_subtitle = TextLabel('settings_Sync_New_Device_SubTitle')

    @allure.step('Checking instructions elements: back up button presence')
    def is_backup_button_present(self):
        assert self._backup_data_button.is_visible, f"Backup button is not visible"

    @allure.step('Checking instructions elements: header presence')
    def is_instructions_header_present(self):
        assert (self._sync_new_device_instructions_header.text
                == SyncingSettings.SYNC_A_NEW_DEVICE_INSTRUCTIONS_HEADER.value), f"Sync a new device title is incorrect"

    @allure.step('Checking instructions elements: subtitle presence')
    def is_instructions_subtitle_present(self):
        assert (self._sync_new_device_instructions_subtitle.text
                == SyncingSettings.SYNC_A_NEW_DEVICE_INSTRUCTIONS_SUBTITLE.value), f"Sync a new device subtitle is incorrect"

    @allure.step('Setup syncing')
    def set_up_syncing(self, password: str):
        self._setup_syncing_button.click()
        AuthenticatePopup().wait_until_appears().authenticate(password)
        return SyncNewDevicePopup().wait_until_appears()
