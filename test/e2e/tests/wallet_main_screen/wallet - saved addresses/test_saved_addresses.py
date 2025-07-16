import allure
import pytest
from allure import step

import configs
import driver
from gui.main_window import MainWindow
from gui.screens.wallet import SavedAddressesView
from scripts.utils.generators import random_wallet_acc_keypair_name
from tests.wallet_main_screen import marks

pytestmark = marks


@allure.testcase('https://ethstatus.testrail.net/index.php?/cases/view/703021', 'Manage a saved address')
@pytest.mark.case(703021, 704987, 704988)
@pytest.mark.parametrize('address', [pytest.param('0x8397bc3c5a60a1883174f722403d63a8833312b7',)])
def test_manage_saved_address(main_screen: MainWindow, address: str):
    name = random_wallet_acc_keypair_name()
    new_name = random_wallet_acc_keypair_name()

    with step('Add new saved address'):
        wallet = main_screen.left_panel.open_wallet()
        wallet.left_panel.open_saved_addresses().open_add_edit_saved_address_popup().add_saved_address(name, address)

    with step('Verify that saved address is in the list of saved addresses'):
        assert driver.waitFor(
            lambda: name in wallet.left_panel.open_saved_addresses().address_names,
            configs.timeouts.LOADING_LIST_TIMEOUT_MSEC), f'Address: {name} not found'

    with step('Verify toast message when adding saved address'):
        messages = main_screen.wait_for_notification()
        assert f'{name} successfully added to your saved addresses' in messages, \
            f"Toast message about adding saved address is not correct or not present. Current list of messages: {messages}"

    with step('Edit saved address to new name'):
        SavedAddressesView().right_click_edit_saved_address_popup(name).edit_saved_address(new_name)

    with step('Verify that saved address is in the list of saved addresses'):
        assert driver.waitFor(
            lambda: new_name in wallet.left_panel.open_saved_addresses().address_names,
            10000), f'Address: {new_name} is not present when it should be'

    with step('Verify toast message when editing saved address'):
        messages = main_screen.wait_for_notification()
        assert f'{new_name} saved address successfully edited' in messages, \
            f"Toast message about editing saved address is not correct or not present. Current list of messages: {messages}"

    with step('Delete address with new name'):
        wallet.left_panel.open_saved_addresses().open_context_menu_for_saved_address(new_name)

    with step('Verify toast message when deleting saved address'):
        messages = main_screen.wait_for_notification()
        assert f'{new_name} was successfully removed from your saved addresses' in messages, \
            f"Toast message about deleting saved address is not correct or not present. Current list of messages: {messages}"

    with step('Verify that saved address with new name is not in the list of saved addresses'):
        assert driver.waitFor(
            lambda: new_name not in wallet.left_panel.open_saved_addresses().get_saved_addresses_list(),
            10000), f'Address: {new_name} is still present'
