import allure
import pytest
from allure_commons._allure import step

import driver
from constants.wallet import WalletNetworkNaming, WalletEditNetworkErrorMessages, WalletNetworkSettings, \
    WalletNetworkDefaultValues
from gui.main_window import MainWindow


@allure.testcase('https://ethstatus.testrail.net/index.php?/cases/view/703515',
                 'Network:  Network: Editing network -> Restore defaults')
@pytest.mark.case(703515)
def test_settings_networks_edit_restore_defaults(main_screen: MainWindow):
    networks = main_screen.left_panel.open_settings().left_panel.open_wallet_settings().open_networks()

    with step('Check network items titles'):
        assert networks.get_network_item_attribute_by_id_and_attr_name('title',
                                                                       WalletNetworkNaming.ETHEREUM_MAINNET_NETWORK_ID.value) == WalletNetworkNaming.LAYER1_ETHEREUM.value
        assert networks.get_network_item_attribute_by_id_and_attr_name('title',
                                                                       WalletNetworkNaming.OPTIMISM_MAINNET_NETWORK_ID.value) == WalletNetworkNaming.LAYER2_OPTIMISIM.value
        assert networks.get_network_item_attribute_by_id_and_attr_name('title',
                                                                       WalletNetworkNaming.ARBITRUM_MAINNET_NETWORK_ID.value) == WalletNetworkNaming.LAYER2_ARBITRUM.value

    with step('Open Ethereum Mainnet network item to edit'):
        edit_network_form = networks.click_network_item_to_open_edit_view(
            WalletNetworkNaming.ETHEREUM_MAINNET_NETWORK_ID.value)

    with step('Check the elements on the form'):
        edit_network_form.wait_until_appears().check_available_elements_on_edit_view()

    with step('Click in Main JSON RPC URL and paste incorrect URL'):
        edit_network_form.edit_network_main_json_rpc_url_input("https://eth-archival.gateway.pokt.network/v1/lb/")

    with step('Check error message for Main JSON RPC URL input'):
        assert driver.waitFor(
            lambda: edit_network_form.get_main_rpc_url_error_message_text() == WalletEditNetworkErrorMessages.PINGUNSUCCESSFUL.value)

    with step('Click in Failover JSON RPC URL and paste incorrect URL'):
        edit_network_form.edit_network_failover_json_rpc_url_input("https://eth-archival.gateway.pokt.network/v1/lb/")

    with step('Check error message for Failover JSON RPC URL input'):
        assert driver.waitFor(
            lambda: edit_network_form.get_failover_rpc_url_error_message_text() == WalletEditNetworkErrorMessages.PINGUNSUCCESSFUL.value)

    with step('Check the acknowledgment checkbox'):
        edit_network_form.check_acknowledgement_checkbox(True)

    with step('Check the acknowledgment text'):
        assert edit_network_form.get_acknowledgement_checkbox_text(
            'text') == WalletNetworkSettings.ACKNOWLEDGMENT_CHECKBOX_TEXT.value

    with step('Click Revert to default button and restore values'):
        edit_network_form.revert_to_default()

    with step('Check value in Main JSON RPC URL input'):
        assert edit_network_form.get_edit_network_main_json_rpc_url_value() == WalletNetworkDefaultValues.ETHEREUM_LIVE_MAIN.value

    with step('Check successful connection message for Main JSON RPC URL input'):
        assert driver.waitFor(
            lambda: edit_network_form.get_main_rpc_url_error_message_text() == WalletEditNetworkErrorMessages.PINGVERIFIED.value)

    with (step('Check value in Failover JSON RPC URL input')):
        assert edit_network_form.get_edit_network_failover_json_rpc_url_value() == WalletNetworkDefaultValues.ETHEREUM_LIVE_FAILOVER.value

    with step('Check successful connection message for Failover JSON RPC URL input'):
        assert driver.waitFor(
            lambda: edit_network_form.get_failover_rpc_url_error_message_text() == WalletEditNetworkErrorMessages.PINGVERIFIED.value)

    with step('Verify the acknowledgment checkbox is unchecked'):
        assert edit_network_form.check_acknowledgement_checkbox(False)
