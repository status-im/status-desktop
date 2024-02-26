import time
import typing

import allure
from objectmaphelper import RegularExpression

import configs.timeouts
import driver
from constants import wallet_account_list_item
from constants.wallet import WalletNetworkSettings, WalletNetworkDefaultValues
from driver import objects_access
from gui.components.wallet.add_saved_address_popup import AddressPopup
from gui.components.wallet.popup_delete_account_from_settings import RemoveAccountConfirmationSettings
from gui.components.wallet.testnet_mode_popup import TestnetModePopup

from gui.components.wallet.wallet_account_popups import AccountPopup, EditAccountFromSettingsPopup
from gui.components.toast_message import ToastMessage
from gui.elements.button import Button
from gui.elements.check_box import CheckBox
from gui.elements.object import QObject
from gui.elements.scroll import Scroll
from gui.elements.text_edit import TextEdit
from gui.elements.text_label import TextLabel
from gui.objects_map import names


class WalletSettingsView(QObject):

    def __init__(self):
        super().__init__(names.mainWindow_WalletView)
        self._wallet_settings_add_new_account_button = Button(names.settings_Wallet_MainView_AddNewAccountButton)
        self._wallet_network_button = Button(names.settings_Wallet_MainView_Networks)
        self._account_order_button = Button(names.settingsContentBaseScrollView_accountOrderItem_StatusListItem)
        self._saved_addresses_button = Button(names.settingsContentBaseScrollView_savedAddressesItem_StatusListItem)
        self._status_account_in_keypair = QObject(names.settingsWalletAccountDelegate_Status_account)
        self._wallet_account_from_keypair = QObject(names.settingsWalletAccountDelegate)
        self._wallet_settings_keypair_item = QObject(names.settingsWalletKeyPairDelegate)
        self._wallet_settings_total_balance_item = QObject(names.settingsWalletAccountTotalBalance)
        self._wallet_settings_total_balance_toggle = CheckBox(names.settingsWalletAccountTotalBalanceToggle)

    @allure.step('Open add account pop up in wallet settings')
    def open_add_account_pop_up(self, attempts: int = 2) -> 'AccountPopup':
        self._wallet_settings_add_new_account_button.click()
        try:
            return AccountPopup().verify_account_popup_present()
        except Exception as ex:
            if attempts:
                return self.open_add_account_pop_up(attempts - 1)
            else:
                raise ex

    @allure.step('Open saved addresses in wallet settings')
    def open_saved_addresses(self, attempts: int = 2) -> 'SavedAddressesWalletSettings':
        self._saved_addresses_button.click()
        try:
            return SavedAddressesWalletSettings()
        except Exception as ex:
            if attempts:
                return self.open_saved_addresses(attempts - 1)
            else:
                raise ex

    @allure.step('Open networks in wallet settings')
    def open_networks(self, attempts: int = 2) -> 'NetworkWalletSettings':
        self._wallet_network_button.click()
        try:
            return NetworkWalletSettings().wait_until_appears()
        except Exception as err:
            if attempts:
                return self.open_networks(attempts - 1)
            else:
                raise err

    @allure.step('Open account order in wallet settings')
    def open_account_order(self):
        self._account_order_button.click()
        return EditAccountOrderSettings().wait_until_appears()

    @allure.step('Open Status account view in wallet settings')
    def open_status_account_in_settings(self):
        self._status_account_in_keypair.click()
        return AccountDetailsView().wait_until_appears()

    @allure.step('Get keypair names')
    def get_keypairs_names(self):
        keypair_names = []
        for item in driver.findAllObjects(self._wallet_settings_keypair_item.real_name):
            keypair_names.append(str(getattr(item, 'title', '')))
        if len(keypair_names) == 0:
            raise LookupError(
                'No keypairs found on the wallet settings screen')
        else:
            return keypair_names

    @allure.step('Open account view in wallet settings by name')
    def open_account_in_settings(self, name):
        self._wallet_account_from_keypair.real_name['objectName'] = name
        self._wallet_account_from_keypair.click()
        return AccountDetailsView().wait_until_appears()

    @allure.step('Check Include in total balance item is visible')
    def is_include_in_total_balance_visible(self):
        return self._wallet_settings_total_balance_item.is_visible

    @allure.step('Interact with the total balance toggle')
    def toggle_total_balance(self, value: bool):
        self._wallet_settings_total_balance_toggle.set(value)


class AccountDetailsView(WalletSettingsView):
    def __init__(self):
        super(AccountDetailsView, self).__init__()
        self._back_button = Button(names.main_toolBar_back_button)
        self._edit_account_button = Button(names.walletAccountViewEditAccountButton)
        self._remove_account_button = Button(names.walletAccountViewRemoveAccountButton)
        self._wallet_account_title = TextLabel(names.walletAccountViewAccountName)
        self._wallet_account_emoji = QObject(names.walletAccountViewAccountEmoji)
        self._wallet_account_details_label = TextLabel(names.walletAccountViewDetailsLabel)
        self._wallet_account_balance = QObject(names.walletAccountViewBalance)
        self._wallet_account_keypair_item = QObject(names.walletAccountViewKeypairItem)
        self._wallet_account_address = QObject(names.walletAccountViewAddress)
        self._wallet_account_origin = TextLabel(names.walletAccountViewOrigin)
        self._wallet_account_derivation_path = QObject(names.walletAccountViewDerivationPath)
        self._wallet_account_stored = TextLabel(names.walletAccountViewStored)
        self._wallet_preferred_networks = QObject(names.walletAccountViewPreferredNetworks)

    @allure.step('Click Edit button')
    def click_edit_account_button(self):
        self._edit_account_button.click()
        return EditAccountFromSettingsPopup().wait_until_appears()

    @allure.step('Click Remove account button')
    def click_remove_account_button(self):
        self._remove_account_button.click()
        return RemoveAccountConfirmationSettings().wait_until_appears()

    @allure.step('Check if Remove account button is visible')
    def is_remove_account_button_visible(self):
        return self._remove_account_button.is_visible

    @allure.step('Get account name')
    def get_account_name_value(self):
        return self._wallet_account_title.text

    @allure.step('Get account balance value')
    def get_account_balance_value(self):
        balance = str(getattr(self._wallet_account_balance.object, 'subTitle'))[:-4]
        return balance

    @allure.step("Get account address value")
    def get_account_address_value(self):
        raw_value = str(getattr(self._wallet_account_address.object, 'subTitle'))
        address = raw_value.split(">")[-1]
        return address

    @allure.step('Get account color value')
    def get_account_color_value(self):
        color_name = str(getattr(self._wallet_account_title.object, 'color')['name'])
        return color_name

    @allure.step('Get account emoji id')
    def get_account_emoji_id(self):
        emoji_id = str(getattr(self._wallet_account_emoji.object, 'emojiId'))
        return emoji_id

    @allure.step('Get account origin value')
    def get_account_origin_value(self):
        return str(getattr(self._wallet_account_origin.object, 'subTitle'))

    @allure.step('Get account derivation path value')
    def get_account_derivation_path_value(self):
        return str(getattr(self._wallet_account_derivation_path.object, 'subTitle'))

    @allure.step('Get derivation path visibility')
    def is_derivation_path_visible(self):
        return self._wallet_account_derivation_path.is_visible

    @allure.step('Get account storage value')
    def get_account_storage_value(self):
        raw_value = str(getattr(self._wallet_account_stored.object, 'subTitle'))
        storage = raw_value.split(">")[-1]
        return storage

    @allure.step('Get account storage visibility')
    def is_account_storage_visible(self):
        return self._wallet_account_stored.is_visible

    @allure.step('Click back button')
    def click_back_button(self):
        self._back_button.click()


class SavedAddressesWalletSettings(WalletSettingsView):
    def __init__(self):
        super(SavedAddressesWalletSettings, self).__init__()
        self.add_new_address_button = Button(names.settings_Wallet_SavedAddresses_AddAddressButton)
        self.saved_address_item = QObject(names.settings_Wallet_SavedAddress_ItemDelegate)

    @allure.step('Click add new address button')
    def open_add_saved_address_popup(self, attempt: int = 2) -> 'AddressPopup':
        self.add_new_address_button.click()
        try:
            return AddressPopup()
        except AssertionError as err:
            if attempt:
                self.open_add_saved_address_popup(attempt - 1)
            else:
                raise err

    @allure.step('Get saved addresses names list')
    def get_saved_address_names_list(self):
        names = [str(address.name) for address in driver.findAllObjects(self.saved_address_item.real_name)]
        return names


class NetworkWalletSettings(WalletSettingsView):

    def __init__(self):
        super(NetworkWalletSettings, self).__init__()
        self._testnet_text_item = QObject(names.settingsContentBaseScrollView_Goerli_testnet_active_StatusBaseText)
        self._testnet_mode_toggle = Button(names.settings_Wallet_NetworksView_TestNet_Toggle)
        self._testnet_mode_title = TextLabel(names.settings_Wallet_NetworksView_TestNet_Toggle_Title)
        self._back_button = Button(names.main_toolBar_back_button)
        self._mainnet_network_item = QObject(names.networkSettingsNetworks_Mainnet)
        self._mainnet_goerli_network_item = QObject(names.networkSettingsNetworks_Mainnet_Goerli)
        self._mainnet_goerli_network_item_test_label = TextLabel(names.networkSettingsNetowrks_Mainnet_Testlabel)
        self._optimism_network_item = QObject(names.networkSettingsNetworks_Optimism)
        self._optimism_goerli_network_item = QObject(names.networkSettingsNetworks_Optimism_Goerli)
        self._arbitrum_network_item = QObject(names.networkSettingsNetworks_Arbitrum)
        self._arbitrum__goerli_network_item = QObject(names.networkSettingsNetworks_Arbitrum_Goerli)
        self._wallet_network_item_template = QObject(names.settingsContentBaseScrollView_WalletNetworkDelegate_template)
        self._wallet_network_item_goerli_sensor = QObject(names.networkSettingsNetworks_Mainnet_Goerli_sensor)
        self._wallet_network_item_goerli_testlabel = TextLabel(names.networkSettingsNetowrks_Mainnet_Testlabel)

    @allure.step('Check networks item title')
    def get_network_item_attribute_by_id_and_attr_name(self, attribute_name, network_id):
        self._wallet_network_item_template.real_name['objectName'] = RegularExpression(
            f'walletNetworkDelegate_.*_{network_id}')
        return str(getattr(self._wallet_network_item_template.object, attribute_name))

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
    def switch_testnet_mode_toggle(self) -> TestnetModePopup:
        self._testnet_mode_toggle.click()
        return TestnetModePopup().wait_until_appears()

    @allure.step('Get testnet mode toggle status')
    def is_testnet_mode_toggle_checked(self) -> bool:
        return self._testnet_mode_toggle.is_checked


class EditNetworkSettings(WalletSettingsView):
    def __init__(self):
        super(EditNetworkSettings, self).__init__()
        self._live_network_tab = Button(names.editNetworkLiveButton)
        self._test_network_tab = Button(names.editNetworkTestButton)
        self._network_name = TextEdit(names.editNetworkNameInput)
        self._network_short_name = TextEdit(names.editNetworkShortNameInput)
        self._network_chaid_id = TextEdit(names.editNetworkChainIdInput)
        self._network_native_token_symbol = TextEdit(names.editNetworkSymbolInput)
        self._network_main_json_rpc_url = TextEdit(names.editNetworkMainRpcInput)
        self._network_failover_json_rpc_url = TextEdit(names.editNetworkFailoverRpcUrlInput)
        self._network_block_explorer = TextEdit(names.editNetworkExplorerInput)
        self._network_acknowledgment_checkbox = CheckBox(names.editNetworkAknowledgmentCheckbox)
        self._network_revert_to_default = Button(names.editNetworkRevertButton)
        self._network_save_changes = Button(names.editNetworkSaveButton)
        self._network_edit_view_back_button = Button(names.main_toolBar_back_button)
        self._network_edit_scroll = Scroll(names.settingsContentBaseScrollView_Flickable)
        self._network_edit_main_rpc_url_error_message = QObject(names.mainRpcUrlInputObject)
        self._network_edit_failover_rpc_url_error_message = QObject(names.failoverRpcUrlInputObject)

    @allure.step('Select Live Network tab')
    def click_live_network_tab(self):
        self._live_network_tab.click()

    @allure.step('Select Test Network tab')
    def click_test_network_tab(self):
        self._test_network_tab.click()

    @allure.step('Click Revert to default button and redirect to Networks screen')
    def click_revert_to_default_and_go_to_networks_main_screen(self, attempts: int = 2):
        self._network_edit_scroll.vertical_down_to(self._network_revert_to_default)
        self._network_revert_to_default.click()
        try:
            return NetworkWalletSettings().wait_until_appears()
        except AssertionError:
            if attempts:
                return self.click_revert_to_default_and_go_to_networks_main_screen(attempts - 1)
            else:
                raise f"Networks screen was not opened"

    @allure.step('Check toast message')
    def check_toast_message(self, network_tab):
        match network_tab:
            case WalletNetworkSettings.EDIT_NETWORK_LIVE_TAB.value:
                assert len(ToastMessage().get_toast_messages) == 1, \
                    f"Multiple toast messages appeared"
                message = ToastMessage().get_toast_messages[0]
                assert message == WalletNetworkSettings.REVERT_TO_DEFAULT_LIVE_MAINNET_TOAST_MESSAGE.value, \
                    f"Toast message is incorrect, current message is {message}"
            case WalletNetworkSettings.EDIT_NETWORK_TEST_TAB.value:
                assert len(ToastMessage().get_toast_messages) == 1, \
                    f"Multiple toast messages appeared"
                message = ToastMessage().get_toast_messages[0]
                assert message == WalletNetworkSettings.REVERT_TO_DEFAULT_TEST_MAINNET_TOAST_MESSAGE.value, \
                    f"Toast message is incorrect, current message is {message}"

    @allure.step('Verify elements for the edit network view')
    def check_available_elements_on_edit_view(self, network_tab):
        match network_tab:
            case WalletNetworkSettings.EDIT_NETWORK_LIVE_TAB.value:
                self._live_network_tab.click()
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

                assert not driver.waitForObjectExists(self._network_revert_to_default.real_name,
                                                      configs.timeouts.UI_LOAD_TIMEOUT_MSEC).enabled, \
                    f"Revert to default button is enabled"

                assert not driver.waitForObjectExists(self._network_save_changes.real_name,
                                                      configs.timeouts.UI_LOAD_TIMEOUT_MSEC).enabled, \
                    f"Save changes button is enabled"

            case WalletNetworkSettings.EDIT_NETWORK_TEST_TAB.value:
                self._test_network_tab.click()
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

                assert not driver.waitForObjectExists(self._network_revert_to_default.real_name,
                                                      configs.timeouts.UI_LOAD_TIMEOUT_MSEC).enabled, \
                    f"Revert to default button is enabled"

                assert not driver.waitForObjectExists(self._network_save_changes.real_name,
                                                      configs.timeouts.UI_LOAD_TIMEOUT_MSEC).enabled, \
                    f"Save changes button is enabled"

    @allure.step('Edit Main RPC url input field')
    def edit_network_main_json_rpc_url_input(self, test_value, network_tab):
        match network_tab:
            case WalletNetworkSettings.EDIT_NETWORK_LIVE_TAB.value:
                self._live_network_tab.click()
                self._network_main_json_rpc_url.text = test_value
            case WalletNetworkSettings.EDIT_NETWORK_TEST_TAB.value:
                self._test_network_tab.click()
                self._network_main_json_rpc_url.text = test_value

    @allure.step('Edit Failover RPC url input field')
    def edit_network_failover_json_rpc_url_input(self, test_value, network_tab):
        match network_tab:
            case WalletNetworkSettings.EDIT_NETWORK_LIVE_TAB.value:
                self._live_network_tab.click()
                self._network_failover_json_rpc_url.text = test_value
            case WalletNetworkSettings.EDIT_NETWORK_TEST_TAB.value:
                self._test_network_tab.click()
                self._network_failover_json_rpc_url.text = test_value

    @allure.step('Check acknowledgment checkbox')
    def check_acknowledgement_checkbox(self, value: bool, network_tab):
        match network_tab:
            case WalletNetworkSettings.EDIT_NETWORK_LIVE_TAB.value:
                self._live_network_tab.click()
                self._network_edit_scroll.vertical_down_to(self._network_acknowledgment_checkbox)
                self._network_acknowledgment_checkbox.set(value)
            case WalletNetworkSettings.EDIT_NETWORK_TEST_TAB.value:
                self._test_network_tab.click()
                self._network_edit_scroll.vertical_down_to(self._network_acknowledgment_checkbox)
                self._network_acknowledgment_checkbox.set(value)
        return self

    @allure.step('Get the text for consent when changing RPC urls')
    def get_acknowledgement_checkbox_text(self, attr):
        text = str(getattr(self._network_acknowledgment_checkbox.object, attr))
        return text

    @allure.step('Get error message for Main RPC URL input')
    def get_main_rpc_url_error_message_text(self):
        error = str(self._network_edit_main_rpc_url_error_message.object.errorMessageCmp.text)
        return error

    @allure.step('Get error message for Failover RPC URL input')
    def get_failover_rpc_url_error_message_text(self):
        error = str(self._network_edit_failover_rpc_url_error_message.object.errorMessageCmp.text)
        return error

    @allure.step('Click Revert button and make sure values are reset')
    def revert_to_default(self, attempts=2):
        current_value_main = self._network_main_json_rpc_url.text
        current_value_failover = self._network_failover_json_rpc_url.text
        self._network_edit_scroll.vertical_down_to(self._network_revert_to_default)
        self._network_revert_to_default.click()
        if (current_value_main == self._network_main_json_rpc_url.text
                and current_value_failover == self._network_failover_json_rpc_url.text):
            assert attempts > 0, "value not reverted"
            time.sleep(1)
            self.revert_to_default(attempts - 1)

    @allure.step('Click Revert to default button and redirect to Networks screen')
    def click_revert_to_default_and_go_to_networks_main_screen(self):
        self._network_edit_scroll.vertical_down_to(self._network_revert_to_default)
        self._network_revert_to_default.click()
        return NetworkWalletSettings().wait_until_appears()

    @allure.step('Get value from Main json rpc input')
    def get_edit_network_main_json_rpc_url_value(self):
        return self._network_main_json_rpc_url.text

    @allure.step('Get value from Failover json rpc input')
    def get_edit_network_failover_json_rpc_url_value(self):
        return self._network_failover_json_rpc_url.text

    @allure.step('Verify value in Main JSON RPC input')
    def verify_edit_network_main_json_rpc_url_value(self, network_tab):
        match network_tab:
            case WalletNetworkSettings.EDIT_NETWORK_LIVE_TAB.value:
                self._live_network_tab.click()
                current_value = self.get_edit_network_main_json_rpc_url_value()
                return True if current_value.startswith(
                    WalletNetworkDefaultValues.ETHEREUM_LIVE_MAIN.value) and current_value.endswith("****") else False
            case WalletNetworkSettings.EDIT_NETWORK_TEST_TAB.value:
                self._test_network_tab.click()
                current_value = self.get_edit_network_main_json_rpc_url_value()
                return True if current_value.startswith(
                    WalletNetworkDefaultValues.ETHEREUM_TEST_MAIN.value) and current_value.endswith("****") else False

    @allure.step('Verify value in Failover JSON RPC input')
    def verify_edit_network_failover_json_rpc_url_value(self, network_tab):
        match network_tab:
            case WalletNetworkSettings.EDIT_NETWORK_LIVE_TAB.value:
                self._live_network_tab.click()
                current_value = self.get_edit_network_failover_json_rpc_url_value()
                return True if current_value.startswith(
                    WalletNetworkDefaultValues.ETHEREUM_LIVE_FAILOVER.value) and current_value.endswith(
                    "****") else False
            case WalletNetworkSettings.EDIT_NETWORK_TEST_TAB.value:
                self._test_network_tab.click()
                current_value = self.get_edit_network_failover_json_rpc_url_value()
                return True if current_value.startswith(
                    WalletNetworkDefaultValues.ETHEREUM_TEST_FAILOVER.value) and current_value.endswith(
                    "****") else False


class EditAccountOrderSettings(WalletSettingsView):

    def __init__(self):
        super(EditAccountOrderSettings, self).__init__()
        self._account_item = QObject(names.settingsContentBaseScrollView_draggableDelegate_StatusDraggableListItem)
        self._accounts_list = QObject(names.statusDesktop_mainWindow)
        self._text_item = QObject(names.settingsContentBaseScrollView_StatusBaseText)
        self._back_button = Button(names.main_toolBar_back_button)

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
            element = QObject(real_name=driver.objectMap.realName(account_item))
            name = str(account_item.title)
            icon_color = None
            icon_emoji = None
            for child in objects_access.walk_children(account_item):
                if getattr(child, 'objectName', '') == 'identicon':
                    icon_color = str(child.color.name)
                    icon_emoji = str(child.emoji)
                    break
            _accounts.append(wallet_account_list_item(name, icon_color, icon_emoji, element))

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
