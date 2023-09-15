import allure
import pytest
from allure import step

import configs
import driver
from gui.components.signing_phrase_popup import SigningPhrasePopup
from gui.components.wallet.authenticate_popup import AuthenticatePopup
from gui.components.wallet.testnet_mode_banner import TestnetModeBanner
from gui.components.wallet.wallet_toast_message import WalletToastMessage
from gui.main_window import MainWindow
from scripts.tools import image


@allure.testcase('https://ethstatus.testrail.net/index.php?/cases/view/703505', 'Network: Testnet switching')
@pytest.mark.case(703505)
@pytest.mark.parametrize('first_network, second_network, third_network, message_turned_on, message_turned_off', [
                             pytest.param('Mainnet', 'Optimism', 'Arbitrum', 'Testnet mode turned on', 'Testnet mode turned off')
                         ])
def test_switch_testnet_mode(main_screen: MainWindow, first_network: str, second_network: str, third_network: str,
                             message_turned_on: str, message_turned_off: str):
    with step('Started to turn on Testnet mode but cancel it'):
        networks = main_screen.left_panel.open_settings().left_panel.open_wallet_settings().open_networks()
        assert networks.get_testnet_mode_button_checked_state() is False
        networks.switch_testnet_mode().cancel()

    with step('Verify that Testnet mode not turned on'):
        assert networks.get_testnet_mode_button_checked_state() is False

    with step('Turn on Testnet mode'):
        networks.switch_testnet_mode().turn_on_testnet_mode()

    with step('Verify that Testnet mode turned on'):
        WalletToastMessage().get_toast_message(message_turned_on)
        TestnetModeBanner().wait_until_appears()
        assert networks.get_testnet_mode_button_checked_state() is True

    with step('Verify that all networks are in the list and text for testnet active is shown on each'):
        assert networks.testnet_items_amount == 3
        assert driver.waitFor(
            lambda: first_network in networks.networks_names,
            configs.timeouts.UI_LOAD_TIMEOUT_MSEC), f'Network: {first_network} not found'
        assert driver.waitFor(
            lambda: second_network in networks.networks_names,
            configs.timeouts.UI_LOAD_TIMEOUT_MSEC), f'Network: {second_network} not found'
        assert driver.waitFor(
            lambda: third_network in networks.networks_names,
            configs.timeouts.UI_LOAD_TIMEOUT_MSEC), f'Network: {third_network} not found'

    with step('Turn off Testnet mode in wallet settings'):
        networks.switch_testnet_mode().turn_off_testnet_mode()

    with step('Verify that Testnet mode turned off'):
        WalletToastMessage().get_toast_message(message_turned_off)
        TestnetModeBanner().wait_until_hidden()
        assert networks.get_testnet_mode_button_checked_state() is False


@allure.testcase('https://ethstatus.testrail.net/index.php?/cases/view/703415', 'Account order: account order could be changed with drag&drop')
@pytest.mark.case(703415)
@pytest.mark.parametrize('address, default_name, name, color, emoji, second_name, second_color, second_emoji', [
                          pytest.param('0xea123F7beFF45E3C9fdF54B324c29DBdA14a639A', 'Status account',
                                       'WatchOnly', '#2a4af5', 'sunglasses', 'Generated', '#216266', 'thumbsup')
                         ])
def test_change_account_order_by_drag_and_drop(main_screen: MainWindow, user_account, address: str, default_name,
                                               name: str, color: str, emoji: str, second_name: str , second_color: str,
                                               second_emoji: str):
    with step('Create watch-only wallet account'):
        wallet = main_screen.left_panel.open_wallet()
        SigningPhrasePopup().wait_until_appears().confirm_phrase()
        account_popup = wallet.left_panel.open_add_account_popup()
        account_popup.set_name(name).set_emoji(emoji).set_color(color).set_origin_eth_address(address).save()
        account_popup.wait_until_hidden()

    with step('Create generated wallet account'):
        account_popup = wallet.left_panel.open_add_account_popup()
        account_popup.set_name(second_name).set_emoji(second_emoji).set_color(second_color).save()
        AuthenticatePopup().wait_until_appears().authenticate(user_account.password)
        account_popup.wait_until_hidden()

    with step('Verify accounts in wallet settings'):
        account_order = main_screen.left_panel.open_settings().left_panel.open_wallet_settings().open_account_order()
        with step('Account order is correct'):
            assert account_order.accounts[0].name == default_name
            assert account_order.accounts[1].name == name
            assert account_order.accounts[2].name == second_name
        with step('Eye icon is displayed on watch-only account'):
            account_order.get_eye_icon(name)
        with step('Icons on accounts are correct'):
            image.compare(account_order.accounts[1].icon, 'watch_only_account_icon.png')
            image.compare(account_order.accounts[2].icon, 'generated_account_icon.png')

    with step('Drag first account to the end of the list'):
        account_order.drag_account(default_name, 2)

    with step('Verify the account order'):
        with step('Account order is correct in wallet settings'):
            assert driver.waitFor(lambda: account_order.accounts[0].name == name)
            assert driver.waitFor(lambda: account_order.accounts[1].name == second_name)
            assert driver.waitFor(lambda: account_order.accounts[2].name == default_name)
        with step('Account order is correct in wallet'):
            wallet = main_screen.left_panel.open_wallet()
            assert driver.waitFor(lambda: wallet.left_panel.accounts[0].name == name)
            assert driver.waitFor(lambda: wallet.left_panel.accounts[1].name == second_name)
            assert driver.waitFor(lambda: wallet.left_panel.accounts[2].name == default_name)

    with step('Drag second account to the top of the list'):
        account_order = main_screen.left_panel.open_settings().left_panel.open_wallet_settings().open_account_order()
        account_order.drag_account(second_name, 0)

    with step('Verify the account order'):
        with step('Account order is correct in wallet settings'):
            assert driver.waitFor(lambda: account_order.accounts[0].name == second_name)
            assert driver.waitFor(lambda: account_order.accounts[1].name == name)
            assert driver.waitFor(lambda: account_order.accounts[2].name == default_name)
        with step('Account order is correct in wallet'):
            wallet = main_screen.left_panel.open_wallet()
            assert driver.waitFor(lambda: wallet.left_panel.accounts[0].name == second_name)
            assert driver.waitFor(lambda: wallet.left_panel.accounts[1].name == name)
            assert driver.waitFor(lambda: wallet.left_panel.accounts[2].name == default_name)
