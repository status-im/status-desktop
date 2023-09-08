import time

import allure
import pytest
from allure import step

import configs.timeouts
import constants
import driver
from gui.components.wallet.authenticate_popup import AuthenticatePopup
from gui.components.signing_phrase_popup import SigningPhrasePopup
from gui.main_window import MainWindow

pytestmark = allure.suite("Wallet")


@allure.testcase('https://ethstatus.testrail.net/index.php?/cases/view/703021', 'Manage a saved address')
@pytest.mark.case(703021)
@pytest.mark.parametrize('name, address, new_name', [
    pytest.param('Saved address name before', '0x8397bc3c5a60a1883174f722403d63a8833312b7', 'Saved address name after'),
    pytest.param('Ens name before', 'nastya.stateofus.eth', 'Ens name after')
])
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
        assert driver.waitFor(
            lambda: new_name not in wallet.left_panel.open_saved_addresses().address_names,
            configs.timeouts.UI_LOAD_TIMEOUT_MSEC), f'Address: {new_name} not found'


@allure.testcase('https://ethstatus.testrail.net/index.php?/cases/view/703022', 'Edit default wallet account')
@pytest.mark.case(703022)
@pytest.mark.parametrize('name, new_name, new_color, new_emoji, new_emoji_unicode', [
    pytest.param('Status account', 'MyPrimaryAccount', '#216266', 'sunglasses', '1f60e')
])
def test_edit_default_wallet_account(main_screen: MainWindow, name: str, new_name: str, new_color: str, new_emoji: str,
                                     new_emoji_unicode: str):
    with step('Select wallet account'):
        wallet = main_screen.left_panel.open_wallet()
        SigningPhrasePopup().wait_until_appears().confirm_phrase()
        wallet.left_panel.select_account(name)

    with step('Edit wallet account'):
        account_popup = wallet.left_panel.open_edit_account_popup(name)
        account_popup.set_name(new_name).set_emoji(new_emoji).set_color(new_color).save()

    with step('Verify that the account is correctly displayed in accounts list'):
        expected_account = constants.user.account_list_item(new_name, new_color.lower(), new_emoji_unicode)
        started_at = time.monotonic()
        while expected_account not in wallet.left_panel.accounts:
            time.sleep(1)
            if time.monotonic() - started_at > 15:
                raise LookupError(f'Account {expected_account} not found in {wallet.left_panel.accounts}')


@allure.testcase('https://ethstatus.testrail.net/index.php?/cases/view/703026', 'Manage a watch-only account')
@pytest.mark.case(703026)
@pytest.mark.parametrize('address, name, color, emoji, emoji_unicode, new_name, new_color,'
                         'new_emoji, new_emoji_unicode', [
                          pytest.param('0xea123F7beFF45E3C9fdF54B324c29DBdA14a639A', 'AccWatch1', '#2a4af5',
                                          'sunglasses', '1f60e', 'AccWatch1edited', '#216266', 'thumbsup', '1f44d')
                         ])
def test_manage_watch_only_account(main_screen: MainWindow, address: str, color: str, emoji: str, emoji_unicode: str,
                                   name: str, new_name: str, new_color: str, new_emoji: str, new_emoji_unicode: str):
    with step('Create watch-only wallet account'):
        wallet = main_screen.left_panel.open_wallet()
        SigningPhrasePopup().wait_until_appears().confirm_phrase()
        account_popup = wallet.left_panel.open_add_account_popup()
        account_popup.set_name(name).set_emoji(emoji).set_color(color).set_origin_eth_address(address).save()
        account_popup.wait_until_hidden()

    with step('Verify that the account is correctly displayed in accounts list'):
        expected_account = constants.user.account_list_item(name, color.lower(), emoji_unicode)
        started_at = time.monotonic()
        while expected_account not in wallet.left_panel.accounts:
            time.sleep(1)
            if time.monotonic() - started_at > 15:
                raise LookupError(f'Account {expected_account} not found in {wallet.left_panel.accounts}')

    with step('Delete wallet account'):
        wallet.left_panel.delete_account(name).confirm()

    with step('Verify that the account is not displayed in accounts list'):
        assert driver.waitFor(lambda: name not in [account.name for account in wallet.left_panel.accounts], 10000), \
            f'Account with {name} is still displayed even it should not be'

    with step('Create watch-only wallet account via context menu'):
        account_popup = wallet.left_panel.open_add_watch_only_account_popup()
        account_popup.set_name(name).set_emoji(emoji).set_color(color).set_eth_address(address).save()
        account_popup.wait_until_hidden()

    with step('Edit wallet account'):
        account_popup = wallet.left_panel.open_edit_account_popup(name)
        account_popup.set_name(new_name).set_emoji(new_emoji).set_color(new_color).save()

    with step('Verify that the account is correctly displayed in accounts list'):
        expected_account = constants.user.account_list_item(new_name, new_color.lower(), new_emoji_unicode)
        started_at = time.monotonic()
        while expected_account not in wallet.left_panel.accounts:
            time.sleep(1)
            if time.monotonic() - started_at > 15:
                raise LookupError(f'Account {expected_account} not found in {wallet.left_panel.accounts}')


@allure.testcase('https://ethstatus.testrail.net/index.php?/cases/view/703033', 'Manage a generated account')
@pytest.mark.case(703033)
@pytest.mark.parametrize('user_account', [constants.user.user_account_default])
@pytest.mark.parametrize('name, color, emoji, emoji_unicode, '
                         'new_name, new_color, new_emoji, new_emoji_unicode', [
                             pytest.param('GenAcc1', '#2a4af5', 'sunglasses', '1f60e',
                                          'GenAcc1edited', '#216266', 'thumbsup', '1f44d')
                         ])
def test_manage_generated_account(main_screen: MainWindow, user_account,
                                  color: str, emoji: str, emoji_unicode: str,
                                  name: str, new_name: str, new_color: str, new_emoji: str, new_emoji_unicode: str):
    with step('Create generated wallet account'):
        wallet = main_screen.left_panel.open_wallet()
        SigningPhrasePopup().wait_until_appears().confirm_phrase()
        account_popup = wallet.left_panel.open_add_account_popup()
        account_popup.set_name(name).set_emoji(emoji).set_color(color).save()
        AuthenticatePopup().wait_until_appears().authenticate(user_account.password)
        account_popup.wait_until_hidden()

    with step('Verify that the account is correctly displayed in accounts list'):
        expected_account = constants.user.account_list_item(name, color.lower(), emoji_unicode)
        started_at = time.monotonic()
        while expected_account not in wallet.left_panel.accounts:
            time.sleep(1)
            if time.monotonic() - started_at > 15:
                raise LookupError(f'Account {expected_account} not found in {wallet.left_panel.accounts}')

    with step('Edit wallet account'):
        account_popup = wallet.left_panel.open_edit_account_popup(name)
        account_popup.set_name(new_name).set_emoji(new_emoji).set_color(new_color).save()

    with step('Verify that the account is correctly displayed in accounts list'):
        expected_account = constants.user.account_list_item(new_name, new_color.lower(), new_emoji_unicode)
        started_at = time.monotonic()
        while expected_account not in wallet.left_panel.accounts:
            time.sleep(1)
            if time.monotonic() - started_at > 15:
                raise LookupError(f'Account {expected_account} not found in {wallet.left_panel.accounts}')

    with step('Delete wallet account with agreement'):
        wallet.left_panel.delete_account(new_name).agree_and_confirm()

    with step('Verify that the account is not displayed in accounts list'):
        assert driver.waitFor(lambda: new_name not in [account.name for account in wallet.left_panel.accounts], 10000), \
            f'Account with {new_name} is still displayed even it should not be'


@allure.testcase('https://ethstatus.testrail.net/index.php?/cases/view/703028', 'Manage a custom generated account')
@pytest.mark.case(703028)
@pytest.mark.parametrize('user_account', [constants.user.user_account_default])
@pytest.mark.parametrize('derivation_path, generated_address_index, name, color, emoji, emoji_unicode', [
    pytest.param('Ethereum', '5', 'Ethereum', '#216266', 'sunglasses', '1f60e'),
    pytest.param('Ethereum Testnet (Ropsten)', '10', 'Ethereum Testnet ', '#7140fd', 'sunglasses', '1f60e'),
    pytest.param('Ethereum (Ledger)', '15', 'Ethereum Ledger', '#2a799b', 'sunglasses', '1f60e'),
    pytest.param('Ethereum (Ledger Live/KeepKey)', '20', 'Ethereum Ledger Live', '#7140fd', 'sunglasses', '1f60e'),
    pytest.param('N/A', '95', 'Custom path', '#216266', 'sunglasses', '1f60e')
])
def test_manage_custom_generated_account(main_screen: MainWindow, user_account,
                                         derivation_path: str, generated_address_index: int,
                                         name: str, color: str, emoji: str, emoji_unicode: str):
    with step('Create generated wallet account'):
        wallet = main_screen.left_panel.open_wallet()
        SigningPhrasePopup().wait_until_appears().confirm_phrase()
        account_popup = wallet.left_panel.open_add_account_popup()
        account_popup.set_name(name).set_emoji(emoji).set_color(color).set_derivation_path(derivation_path, generated_address_index, user_account.password).save()

    with step('Verify that the account is correctly displayed in accounts list'):
        expected_account = constants.user.account_list_item(name, color.lower(), emoji_unicode)
        started_at = time.monotonic()
        while expected_account not in wallet.left_panel.accounts:
            time.sleep(1)
            if time.monotonic() - started_at > 15:
                raise LookupError(f'Account {expected_account} not found in {wallet.left_panel.accounts}')

    with step('Delete wallet account with agreement'):
        wallet.left_panel.delete_account(name).agree_and_confirm()

    with step('Verify that the account is not displayed in accounts list'):
        assert driver.waitFor(lambda: name not in [account.name for account in wallet.left_panel.accounts], 10000), \
            f'Account with {name} is still displayed even it should not be'


@allure.testcase('https://ethstatus.testrail.net/index.php?/cases/view/703029', 'Manage a private key imported account')
@pytest.mark.case(703029)
@pytest.mark.parametrize('user_account', [constants.user.user_account_default])
@pytest.mark.parametrize('name, color, emoji, emoji_unicode, '
                         'new_name, new_color, new_emoji, new_emoji_unicode, private_key', [
                             pytest.param('PrivKeyAcc1', '#2a4af5', 'sunglasses', '1f60e',
                                          'PrivKeyAcc1edited', '#216266', 'thumbsup', '1f44d',
                                          '2daa36a3abe381a9c01610bf10fda272fbc1b8a22179a39f782c512346e3e470')
                         ])
def test_private_key_imported_account(main_screen: MainWindow, user_account,
                                      name: str, color: str, emoji: str, emoji_unicode: str,
                                      new_name: str, new_color: str, new_emoji: str, new_emoji_unicode: str,
                                      private_key: str):
    with step('Create generated wallet account'):
        wallet = main_screen.left_panel.open_wallet()
        SigningPhrasePopup().wait_until_appears().confirm_phrase()
        account_popup = wallet.left_panel.open_add_account_popup()
        account_popup.set_name(name).set_emoji(emoji).set_color(color).set_origin_private_key(private_key).save()
        AuthenticatePopup().wait_until_appears().authenticate(user_account.password)
        account_popup.wait_until_hidden()

    with step('Verify that the account is correctly displayed in accounts list'):
        expected_account = constants.user.account_list_item(name, color.lower(), emoji_unicode)
        started_at = time.monotonic()
        while expected_account not in wallet.left_panel.accounts:
            time.sleep(1)
            if time.monotonic() - started_at > 15:
                raise LookupError(f'Account {expected_account} not found in {wallet.left_panel.accounts}')

    with step('Edit wallet account'):
        account_popup = wallet.left_panel.open_edit_account_popup(name)
        account_popup.set_name(new_name).set_emoji(new_emoji).set_color(new_color).save()

    with step('Verify that the account is correctly displayed in accounts list'):
        expected_account = constants.user.account_list_item(new_name, new_color.lower(), new_emoji_unicode)
        started_at = time.monotonic()
        while expected_account not in wallet.left_panel.accounts:
            time.sleep(1)
            if time.monotonic() - started_at > 15:
                raise LookupError(f'Account {expected_account} not found in {wallet.left_panel.accounts}')

    with step('Delete wallet account with agreement'):
        wallet.left_panel.delete_account(new_name).confirm()

    with step('Verify that the account is not displayed in accounts list'):
        assert driver.waitFor(lambda: new_name not in [account.name for account in wallet.left_panel.accounts], 10000), \
            f'Account with {new_name} is still displayed even it should not be'
