import time

import allure
import pytest
from allure import step

import configs
import constants
import driver
from constants.wallet import WalletNetworkSettings
from gui.components.signing_phrase_popup import SigningPhrasePopup
from gui.components.wallet.authenticate_popup import AuthenticatePopup
from gui.components.wallet.testnet_mode_banner import TestnetModeBanner
from gui.components.wallet.wallet_toast_message import WalletToastMessage
from gui.main_window import MainWindow
from scripts.tools import image

pytestmark = allure.suite("Wallet")


@allure.testcase('https://ethstatus.testrail.net/index.php?/cases/view/703505', 'Network: Testnet switching')
@pytest.mark.case(703505)
@pytest.mark.parametrize('first_network, second_network, third_network', [
    pytest.param('Mainnet', 'Optimism', 'Arbitrum')
])
def test_switch_testnet_mode(main_screen: MainWindow, first_network: str, second_network: str, third_network: str):
    with step('Verify that Testnet toggle has subtitle'):
        networks = main_screen.left_panel.open_settings().left_panel.open_wallet_settings().open_networks()
        subtitle = networks.get_testnet_toggle_subtitle()
        assert subtitle == WalletNetworkSettings.TESTNET_SUBTITLE.value, \
            f"Testnet title is incorrect, current subtitle is {subtitle}"

    with step('Verify back to Wallet settings button is present and text on top is correct'):
        assert networks.is_back_to_wallet_settings_button_present(), \
            f"Back to Wallet settings button is not visible on Networks screen"

    with step('Verify that Testnet mode toggle is turned off'):
        assert not networks.is_testnet_mode_toggle_checked(), f"Testnet toggle is on when it should not"

    with step('Turn on Testnet mode'):
        networks.switch_testnet_mode_toggle().click_turn_on_testnet_mode_in_testnet_modal()

    with step('Verify that Testnet mode turned on'):
        WalletToastMessage().get_toast_message(WalletNetworkSettings.TESTNET_ENABLED_TOAST_MESSAGE.value)
        TestnetModeBanner().wait_until_appears()
        assert networks.is_testnet_mode_toggle_checked(), f"Testnet toggle if off when it should not"

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
        networks.switch_testnet_mode_toggle().turn_off_testnet_mode_in_testnet_modal()

    with step('Verify that Testnet mode turned off'):
        WalletToastMessage().get_toast_message(WalletNetworkSettings.TESTNET_DISABLED_TOAST_MESSAGE.value)
        TestnetModeBanner().wait_until_hidden()
        assert not networks.is_testnet_mode_toggle_checked(), f"Testnet toggle is on when it should not"


@allure.testcase('https://ethstatus.testrail.net/index.php?/cases/view/703621',
                 'Network: Enable testnet toggle and click cross button in confirmation')
@pytest.mark.case(703621)
def test_toggle_testnet_toggle_on_and_close_the_confirmation(main_screen: MainWindow):
    networks = main_screen.left_panel.open_settings().left_panel.open_wallet_settings().open_networks()

    with step('Verify that Testnet mode toggle is turned off'):
        assert not networks.is_testnet_mode_toggle_checked(), f"Testnet toggle is enabled when it should not"

    with step('Toggle the Testnet mode toggle ON'):
        testnet_modal = networks.switch_testnet_mode_toggle()

    with step('Click cross button on the Testnet modal'):
        testnet_modal.close_testnet_modal_with_cross_button()
        assert not networks.is_testnet_mode_toggle_checked()

    with step('Verify that Testnet mode is not turned off'):
        assert not WalletToastMessage().is_visible
        assert not TestnetModeBanner().is_visible, f"Testnet banner is present when it should not"
        assert not networks.is_testnet_mode_toggle_checked(), \
            f"Testnet toggle is turned on when it should not"


@allure.testcase('https://ethstatus.testrail.net/index.php?/cases/view/703622',
                 'Network:  Network: Enable Testnets, toggle testnet toggle OFF, click cancel in confirmation')
@pytest.mark.case(703621)
# @pytest.mark.skip(reason="https://github.com/status-im/status-desktop/issues/12247"), bug is now fixed
def test_switch_testnet_off_by_toggle_and_cancel_in_confirmation(main_screen: MainWindow):
    networks = main_screen.left_panel.open_settings().left_panel.open_wallet_settings().open_networks()

    with step('Verify that Testnet mode toggle is turned off'):
        assert not networks.is_testnet_mode_toggle_checked(), f"Testnet toggle is enabled when it should not"

    with step('Toggle the Testnet mode toggle ON'):
        testnet_modal = networks.switch_testnet_mode_toggle()

    with step('Confirm enabling testnet mode in testnet modal'):
        testnet_modal.click_turn_on_testnet_mode_in_testnet_modal()

    with step('Verify testnet mode is enabled'):
        WalletToastMessage().get_toast_message(WalletNetworkSettings.TESTNET_ENABLED_TOAST_MESSAGE.value)
        TestnetModeBanner().wait_until_appears()
        assert networks.is_testnet_mode_toggle_checked(), f"testnet toggle is off"

    with step('Toggle the Testnet mode toggle Off'):
        testnet_modal = networks.switch_testnet_mode_toggle()

    with step('Click Cancel button on the Testnet modal'):
        testnet_modal.click_cancel_button_in_testnet_modal()
        assert networks.is_testnet_mode_toggle_checked(), f"Testnet toggle is turned OFF when it should not"

    with step('Verify that Testnet mode is not turned off'):
        assert TestnetModeBanner().is_visible, f"Testnet banner is not present when it should"


@allure.testcase('https://ethstatus.testrail.net/index.php?/cases/view/703415',
                 'Account order: account order could be changed with drag&drop')
@pytest.mark.case(703415)
@pytest.mark.parametrize('address, default_name, name, color, emoji, second_name, second_color, second_emoji', [
    pytest.param('0xea123F7beFF45E3C9fdF54B324c29DBdA14a639A', 'Status account',
                 'WatchOnly', '#2a4af5', 'sunglasses', 'Generated', '#216266', 'thumbsup')
])
def test_change_account_order_by_drag_and_drop(main_screen: MainWindow, user_account, address: str, default_name,
                                               name: str, color: str, emoji: str, second_name: str, second_color: str,
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


@allure.testcase('https://ethstatus.testrail.net/index.php?/cases/edit/703416',
                 'Account order: reordering is not possible having a single account')
@pytest.mark.case(703416)
@pytest.mark.parametrize('default_name, text_on_top', [
    pytest.param('Status account', 'This account looks a little lonely. Add another account'
                                   ' to enable re-ordering.')
])
def test_change_account_order_not_possible(main_screen: MainWindow, default_name: str, text_on_top: str):
    with step('Open edit account order view'):
        account_order = main_screen.left_panel.open_settings().left_panel.open_wallet_settings().open_account_order()

    with step('Verify that only default account displayed'):
        assert len(account_order.accounts) == 1
        assert account_order.accounts[0].name == default_name

    with step('Back button is present and text on top is correct'):
        assert account_order.account_recommendations[0] == text_on_top
        assert account_order.is_back_button_present() is True


@allure.testcase('https://ethstatus.testrail.net/index.php?/cases/edit/703598',
                 'Add new account from wallet settings screen')
@pytest.mark.case(703598)
@pytest.mark.parametrize('user_account', [constants.user.user_account_one])
@pytest.mark.parametrize('name, color, emoji, emoji_unicode, '
                         'new_name, new_color, new_emoji, new_emoji_unicode', [
                             pytest.param('GenAcc1', '#2a4af5', 'sunglasses', '1f60e',
                                          'GenAcc1edited', '#216266', 'thumbsup', '1f44d')
                         ])
def test_add_new_account_from_wallet_settings(main_screen: MainWindow, user_account,
                                              color: str, emoji: str, emoji_unicode: str,
                                              name: str, new_name: str, new_color: str, new_emoji: str,
                                              new_emoji_unicode: str):
    with step('Open add account pop up from wallet settings'):
        add_account_popup = \
            main_screen.left_panel.open_settings().left_panel.open_wallet_settings().open_add_account_pop_up()

    with step('Add a new generated account from wallet settings screen'):

        add_account_popup.set_name(name).set_emoji(emoji).set_color(color).save()
        AuthenticatePopup().wait_until_appears().authenticate(user_account.password)
        add_account_popup.wait_until_hidden()

    with step('Verify that the account is correctly displayed in accounts list'):

        wallet = main_screen.left_panel.open_wallet()
        SigningPhrasePopup().wait_until_appears().confirm_phrase()
        expected_account = constants.user.account_list_item(name, color.lower(), emoji_unicode)
        started_at = time.monotonic()
        while expected_account not in wallet.left_panel.accounts:
            time.sleep(1)
        if time.monotonic() - started_at > 15:
            raise LookupError(f'Account {expected_account} not found in {wallet.left_panel.accounts}')
