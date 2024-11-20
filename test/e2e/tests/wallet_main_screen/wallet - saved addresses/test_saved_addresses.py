import random
import string

import allure
import pytest
from allure import step

from gui.components.toast_message import ToastMessage
from gui.screens.wallet import SavedAddressesView
from tests.wallet_main_screen import marks

import configs
import driver
from gui.components.signing_phrase_popup import SigningPhrasePopup
from gui.main_window import MainWindow

pytestmark = marks


@allure.testcase('https://ethstatus.testrail.net/index.php?/cases/view/703021', 'Manage a saved address')
@pytest.mark.case(703021, 704987, 704988)
@pytest.mark.parametrize('name, address, new_name',
                         [
                             pytest.param(
                                 ''.join(random.choices(string.ascii_letters, k=24)),
                                 '0x8397bc3c5a60a1883174f722403d63a8833312b7',
                                 ''.join(random.choices(string.ascii_letters, k=24)))
                         ])
def test_manage_saved_address(main_screen: MainWindow, name: str, address: str, new_name: str):
    with step('Add new saved address'):
        wallet = main_screen.left_panel.open_wallet()
        wallet.left_panel.open_saved_addresses().open_add_saved_address_popup().add_saved_address(name, address)

    with step('Verify that saved address is in the list of saved addresses'):
        assert driver.waitFor(
            lambda: name in wallet.left_panel.open_saved_addresses().address_names,
            configs.timeouts.LOADING_LIST_TIMEOUT_MSEC), f'Address: {name} not found'

    with step('Verify toast message when adding saved address'):
        messages = main_screen.wait_for_notification()
        assert f'{name} successfully added to your saved addresses' in messages, \
            f"Toast message about adding saved address is not correct or not present. Current list of messages: {messages}"

    with step('Edit saved address to new name'):
        SavedAddressesView().open_edit_address_popup(name).edit_saved_address(new_name)

    with step('Verify that saved address with new name is in the list of saved addresses'):
        assert driver.waitFor(
            lambda: new_name in SavedAddressesView().address_names,
            configs.timeouts.LOADING_LIST_TIMEOUT_MSEC), f'Address: {new_name} not found'

    with step('Verify toast message when editing saved address'):
        messages = main_screen.wait_for_notification()
        assert f'{new_name} saved address successfully edited' in messages, \
            f"Toast message about editing saved address is not correct or not present. Current list of messages: {messages}"

    with step('Delete address with new name'):
        wallet.left_panel.open_saved_addresses().delete_saved_address(new_name)

    with step('Verify toast message when deleting saved address'):
        messages = main_screen.wait_for_notification()
        assert f'{new_name} was successfully removed from your saved addresses' in messages, \
            f"Toast message about deleting saved address is not correct or not present. Current list of messages: {messages}"

    with step('Verify that saved address with new name is not in the list of saved addresses'):
        assert not driver.waitFor(
            lambda: new_name in wallet.left_panel.open_saved_addresses().get_saved_addresses_list(),
            configs.timeouts.LOADING_LIST_TIMEOUT_MSEC), f'Address: {new_name} is still present'
