import allure
import pytest
from allure import step
from . import marks

import configs
import driver
from gui.components.signing_phrase_popup import SigningPhrasePopup
from gui.main_window import MainWindow

pytestmark = marks
@allure.testcase('https://ethstatus.testrail.net/index.php?/cases/view/703021', 'Manage a saved address')
@pytest.mark.case(703021)
@pytest.mark.parametrize('name, address, new_name', [
    pytest.param('Saved address name before', '0x8397bc3c5a60a1883174f722403d63a8833312b7', 'Saved address name after'),
    pytest.param('Ens name before', 'nastya.stateofus.eth', 'Ens name after')
])
@pytest.mark.xfail(reason="https://github.com/status-im/status-desktop/issues/12914")
def test_manage_saved_address(main_screen: MainWindow, name: str, address: str, new_name: str):
    with step('Add new address'):
        wallet = main_screen.left_panel.open_wallet()
        SigningPhrasePopup().wait_until_appears().confirm_phrase()
        wallet.left_panel.open_saved_addresses().open_add_address_popup().add_saved_address(name, address)

    with step('Verify that saved address is in the list of saved addresses'):
        assert driver.waitFor(
            lambda: name in wallet.left_panel.open_saved_addresses().address_names,
            configs.timeouts.UI_LOAD_TIMEOUT_MSEC), f'Address: {name} not found'

    with step('Edit saved address to new name'):
        wallet.left_panel.open_saved_addresses().open_edit_address_popup(name).edit_saved_address(new_name, address)

    with step('Verify that saved address with new name is in the list of saved addresses'):
        assert driver.waitFor(
            lambda: new_name in wallet.left_panel.open_saved_addresses().address_names,
            configs.timeouts.UI_LOAD_TIMEOUT_MSEC), f'Address: {new_name} not found'

    with step('Delete address with new name'):
        wallet.left_panel.open_saved_addresses().delete_saved_address(new_name)

    with step('Verify that saved address with new name is not in the list of saved addresses'):
        assert not driver.waitFor(
            lambda: new_name in wallet.left_panel.open_saved_addresses().address_names,
            configs.timeouts.UI_LOAD_TIMEOUT_MSEC), f'Address: {new_name} is still present'
