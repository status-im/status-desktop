import time

import allure
import pytest
from allure import step

import constants
import driver
from gui.components.signing_phrase_popup import SigningPhrasePopup
from gui.components.wallet.authenticate_popup import AuthenticatePopup
from gui.components.wallet.wallet_toast_message import WalletToastMessage
from gui.main_window import MainWindow
from gui.screens.settings_keycard import KeycardSettingsView


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

    with step("Verify default status account can't be deleted"):
        context_menu = wallet.left_panel._open_context_menu_for_account(name)
        assert not context_menu.is_delete_account_option_present(), \
            f"Delete option should not be present for Status account"

    with step('Edit wallet account'):
        account_popup = wallet.left_panel.open_edit_account_popup_from_context_menu(name)
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

    # TODO: add toast verification when method is fixed

    with step('Verify that the account is correctly displayed in accounts list'):
        expected_account = constants.user.account_list_item(name, color.lower(), emoji_unicode)
        started_at = time.monotonic()
        while expected_account not in wallet.left_panel.accounts:
            time.sleep(1)
            if time.monotonic() - started_at > 15:
                raise LookupError(f'Account {expected_account} not found in {wallet.left_panel.accounts}')

    with step('Delete wallet account'):
        wallet.left_panel.delete_account_from_context_menu(name).confirm()

    # TODO: add toast check for deletion when https://github.com/status-im/status-desktop/issues/12541 fixed

    with step('Verify that the account is not displayed in accounts list'):
        assert driver.waitFor(lambda: name not in [account.name for account in wallet.left_panel.accounts], 10000), \
            f'Account with {name} is still displayed even it should not be'

    with step('Create watch-only wallet account via context menu'):
        account_popup = wallet.left_panel.select_add_watched_address_from_context_menu()
        account_popup.set_name(name).set_emoji(emoji).set_color(color).set_eth_address(address).save()
        account_popup.wait_until_hidden()

    # TODO: add toast verification when method is fixed

    with step('Edit wallet account'):
        account_popup = wallet.left_panel.open_edit_account_popup_from_context_menu(name)
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
@pytest.mark.parametrize('user_account', [constants.user.user_account_one])
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

    # TODO: add toast verification when method is fixed

    with step('Verify that the account is correctly displayed in accounts list'):
        expected_account = constants.user.account_list_item(name, color.lower(), emoji_unicode)
        started_at = time.monotonic()
        while expected_account not in wallet.left_panel.accounts:
            time.sleep(1)
            if time.monotonic() - started_at > 15:
                raise LookupError(f'Account {expected_account} not found in {wallet.left_panel.accounts}')

    with step('Edit wallet account'):
        account_popup = wallet.left_panel.open_edit_account_popup_from_context_menu(name)
        account_popup.set_name(new_name).set_emoji(new_emoji).set_color(new_color).save()

    with step('Verify that the account is correctly displayed in accounts list'):
        expected_account = constants.user.account_list_item(new_name, new_color.lower(), new_emoji_unicode)
        started_at = time.monotonic()
        while expected_account not in wallet.left_panel.accounts:
            time.sleep(1)
            if time.monotonic() - started_at > 15:
                raise LookupError(f'Account {expected_account} not found in {wallet.left_panel.accounts}')

    with step('Delete wallet account with agreement'):
        wallet.left_panel.delete_account_from_context_menu(new_name).agree_and_confirm()

    # TODO: add toast check for deletion when https://github.com/status-im/status-desktop/issues/12541 fixed

    with step('Verify that the account is not displayed in accounts list'):
        assert driver.waitFor(lambda: new_name not in [account.name for account in wallet.left_panel.accounts], 10000), \
            f'Account with {new_name} is still displayed even it should not be'


@allure.testcase('https://ethstatus.testrail.net/index.php?/cases/view/703028', 'Manage a custom generated account')
@pytest.mark.case(703028)
@pytest.mark.parametrize('user_account', [constants.user.user_account_one])
@pytest.mark.parametrize('derivation_path, generated_address_index, name, color, emoji, emoji_unicode', [
    pytest.param('Ethereum', '5', 'Ethereum', '#216266', 'sunglasses', '1f60e'),
    pytest.param('Ethereum Testnet (Ropsten)', '10', 'Ethereum Testnet ', '#7140fd', 'sunglasses', '1f60e'),
    pytest.param('Ethereum (Ledger)', '15', 'Ethereum Ledger', '#2a799b', 'sunglasses', '1f60e'),
    pytest.param('Ethereum (Ledger Live/KeepKey)', '20', 'Ethereum Ledger Live', '#7140fd', 'sunglasses', '1f60e'),
    pytest.param('N/A', '95', 'Custom path', '#216266', 'sunglasses', '1f60e')
])
@pytest.mark.skip(reason='https://github.com/status-im/desktop-qa-automation/issues/220')
def test_manage_custom_generated_account(main_screen: MainWindow, user_account,
                                         derivation_path: str, generated_address_index: int,
                                         name: str, color: str, emoji: str, emoji_unicode: str):
    with step('Create generated wallet account'):
        wallet = main_screen.left_panel.open_wallet()
        SigningPhrasePopup().wait_until_appears().confirm_phrase()
        account_popup = wallet.left_panel.open_add_account_popup()
        account_popup.set_name(name).set_emoji(emoji).set_color(color).set_derivation_path(derivation_path,
                                                                                           generated_address_index,
                                                                                           user_account.password).save()

    # TODO: add toast verification when method is fixed

    with step('Verify that the account is correctly displayed in accounts list'):
        expected_account = constants.user.account_list_item(name, color.lower(), emoji_unicode)
        started_at = time.monotonic()
        while expected_account not in wallet.left_panel.accounts:
            time.sleep(1)
            if time.monotonic() - started_at > 15:
                raise LookupError(f'Account {expected_account} not found in {wallet.left_panel.accounts}')

    with step('Delete wallet account with agreement'):
        wallet.left_panel.delete_account_from_context_menu(name).agree_and_confirm()

    # TODO: add toast check for deletion when https://github.com/status-im/status-desktop/issues/12541 fixed

    with step('Verify that the account is not displayed in accounts list'):
        assert driver.waitFor(lambda: name not in [account.name for account in wallet.left_panel.accounts], 10000), \
            f'Account with {name} is still displayed even it should not be'


@allure.testcase('https://ethstatus.testrail.net/index.php?/cases/view/703029', 'Manage a private key imported account')
@pytest.mark.case(703029)
@pytest.mark.parametrize('user_account', [constants.user.user_account_one])
@pytest.mark.parametrize('address_pair', [constants.user.private_key_address_pair_1])
@pytest.mark.parametrize('name, color, emoji, emoji_unicode, '
                         'new_name, new_color, new_emoji, new_emoji_unicode', [
                             pytest.param('PrivKeyAcc1', '#2a4af5', 'sunglasses', '1f60e',
                                          'PrivKeyAcc1edited', '#216266', 'thumbsup', '1f44d')
                         ])
def test_private_key_imported_account(main_screen: MainWindow, user_account, address_pair,
                                      name: str, color: str, emoji: str, emoji_unicode: str,
                                      new_name: str, new_color: str, new_emoji: str, new_emoji_unicode: str):
    with step('Import an account within private key'):
        wallet = main_screen.left_panel.open_wallet()
        SigningPhrasePopup().wait_until_appears().confirm_phrase()
        account_popup = wallet.left_panel.open_add_account_popup()
        account_popup.set_name(name).set_emoji(emoji).set_color(color).set_origin_private_key(
            address_pair.private_key).save()
        AuthenticatePopup().wait_until_appears().authenticate(user_account.password)
        account_popup.wait_until_hidden()

    # TODO: add toast verification when method is fixed

    with step('Verify that the account is correctly displayed in accounts list'):
        expected_account = constants.user.account_list_item(name, color.lower(), emoji_unicode)
        started_at = time.monotonic()
        while expected_account not in wallet.left_panel.accounts:
            time.sleep(1)
            if time.monotonic() - started_at > 15:
                raise LookupError(f'Account {expected_account} not found in {wallet.left_panel.accounts}')

    with step('Verify that importing private key reveals correct wallet address'):
        settings_acc_view = (
            main_screen.left_panel.open_settings().left_panel.open_wallet_settings().open_account_in_settings(name))
        address = settings_acc_view.get_account_address_value()
        assert address == address_pair.wallet_address, \
            f"Recovered account should have address {address_pair.wallet_address}, but has {address}"

    with step('Edit wallet account'):
        main_screen.left_panel.open_wallet()
        account_popup = wallet.left_panel.open_edit_account_popup_from_context_menu(name)
        account_popup.set_name(new_name).set_emoji(new_emoji).set_color(new_color).save()

    with step('Verify that the account is correctly displayed in accounts list'):
        expected_account = constants.user.account_list_item(new_name, new_color.lower(), new_emoji_unicode)
        started_at = time.monotonic()
        while expected_account not in wallet.left_panel.accounts:
            time.sleep(1)
            if time.monotonic() - started_at > 15:
                raise LookupError(f'Account {expected_account} not found in {wallet.left_panel.accounts}')

    with step('Delete wallet account'):
        wallet.left_panel.delete_account_from_context_menu(new_name).confirm()

    # TODO: add toast check for deletion when https://github.com/status-im/status-desktop/issues/12541 fixed

    with step('Verify that the account is not displayed in accounts list'):
        assert driver.waitFor(lambda: new_name not in [account.name for account in wallet.left_panel.accounts], 10000), \
            f'Account with {new_name} is still displayed even it should not be'


@allure.testcase('https://ethstatus.testrail.net/index.php?/cases/view/703030', 'Manage a seed phrase imported account')
@pytest.mark.case(703030)
@pytest.mark.parametrize('user_account', [constants.user.user_account_one])
@pytest.mark.parametrize('name, color, emoji, emoji_unicode, '
                         'new_name, new_color, new_emoji, new_emoji_unicode, seed_phrase', [
                             pytest.param('SPAcc24', '#2a4af5', 'sunglasses', '1f60e',
                                          'SPAcc24edited', '#216266', 'thumbsup', '1f44d',
                                          'elite dinosaur flavor canoe garbage palace antique dolphin virtual mixed sand '
                                          'impact solution inmate hair pipe affair cage vote estate gloom lamp robust like'),
                             pytest.param('SPAcc18', '#2a4af5', 'sunglasses', '1f60e',
                                          'SPAcc18edited', '#216266', 'thumbsup', '1f44d',
                                          'kitten tiny cup admit cactus shrug shuffle accident century faith roof plastic '
                                          'beach police barely vacant sign blossom'),
                             pytest.param('SPAcc12', '#2a4af5', 'sunglasses', '1f60e',
                                          'SPAcc12edited', '#216266', 'thumbsup', '1f44d',
                                          'pelican chief sudden oval media rare swamp elephant lawsuit wheat knife initial')
                         ])
def test_seed_phrase_imported_account(main_screen: MainWindow, user_account,
                                      name: str, color: str, emoji: str, emoji_unicode: str,
                                      new_name: str, new_color: str, new_emoji: str, new_emoji_unicode: str,
                                      seed_phrase: str):
    with step('Create imported seed phrase wallet account'):
        wallet = main_screen.left_panel.open_wallet()
        SigningPhrasePopup().wait_until_appears().confirm_phrase()
        account_popup = wallet.left_panel.open_add_account_popup()
        account_popup.set_name(name).set_emoji(emoji).set_color(color).set_origin_seed_phrase(
            seed_phrase.split()).save()
        AuthenticatePopup().wait_until_appears().authenticate(user_account.password)
        account_popup.wait_until_hidden()

    # TODO: add toast verification when method is fixed

    with step('Verify that the account is correctly displayed in accounts list'):
        expected_account = constants.user.account_list_item(name, color.lower(), emoji_unicode)
        started_at = time.monotonic()
        while expected_account not in wallet.left_panel.accounts:
            time.sleep(1)
            if time.monotonic() - started_at > 15:
                raise LookupError(f'Account {expected_account} not found in {wallet.left_panel.accounts}')

    with step('Edit wallet account'):
        account_popup = wallet.left_panel.open_edit_account_popup_from_context_menu(name)
        account_popup.set_name(new_name).set_emoji(new_emoji).set_color(new_color).save()

    with step('Verify that the account is correctly displayed in accounts list'):
        expected_account = constants.user.account_list_item(new_name, new_color.lower(), new_emoji_unicode)
        started_at = time.monotonic()
        while expected_account not in wallet.left_panel.accounts:
            time.sleep(1)
            if time.monotonic() - started_at > 15:
                raise LookupError(f'Account {expected_account} not found in {wallet.left_panel.accounts}')

    with step('Delete wallet account with agreement'):
        wallet.left_panel.delete_account_from_context_menu(new_name).agree_and_confirm()

    # TODO: add toast check for deletion when https://github.com/status-im/status-desktop/issues/12541 fixed

    with step('Verify that the account is not displayed in accounts list'):
        assert driver.waitFor(lambda: new_name not in [account.name for account in wallet.left_panel.accounts], 10000), \
            f'Account with {new_name} is still displayed even it should not be'


@allure.testcase('https://ethstatus.testrail.net/index.php?/cases/view/703036',
                 'Manage an account created from the generated seed phrase')
@pytest.mark.case(703036)
@pytest.mark.parametrize('user_account', [constants.user.user_account_one])
@pytest.mark.parametrize('name, color, emoji, emoji_unicode, '
                         'new_name, new_color, new_emoji, new_emoji_unicode, keypair_name', [
                             pytest.param('SPAcc', '#2a4af5', 'sunglasses', '1f60e',
                                          'SPAccedited', '#216266', 'thumbsup', '1f44d', 'SPKeyPair')])
def test_seed_phrase_generated_account(main_screen: MainWindow, user_account,
                                       name: str, color: str, emoji: str, emoji_unicode: str,
                                       new_name: str, new_color: str, new_emoji: str, new_emoji_unicode: str,
                                       keypair_name: str):
    with step('Create generated seed phrase wallet account'):
        wallet = main_screen.left_panel.open_wallet()
        SigningPhrasePopup().wait_until_appears().confirm_phrase()
        account_popup = wallet.left_panel.open_add_account_popup()
        account_popup.set_name(name).set_emoji(emoji).set_color(color).set_origin_new_seed_phrase(keypair_name).save()
        AuthenticatePopup().wait_until_appears().authenticate(user_account.password)
        account_popup.wait_until_hidden()

    # TODO: add toast verification when method is fixed

    with step('Verify that the account is correctly displayed in accounts list'):
        expected_account = constants.user.account_list_item(name, color.lower(), emoji_unicode)
        started_at = time.monotonic()
        while expected_account not in wallet.left_panel.accounts:
            time.sleep(1)
            if time.monotonic() - started_at > 15:
                raise LookupError(f'Account {expected_account} not found in {wallet.left_panel.accounts}')

    with step('Edit wallet account'):
        account_popup = wallet.left_panel.open_edit_account_popup_from_context_menu(name)
        account_popup.set_name(new_name).set_emoji(new_emoji).set_color(new_color).save()

    with step('Verify that the account is correctly displayed in accounts list'):
        expected_account = constants.user.account_list_item(new_name, new_color.lower(), new_emoji_unicode)
        started_at = time.monotonic()
        while expected_account not in wallet.left_panel.accounts:
            time.sleep(1)
            if time.monotonic() - started_at > 15:
                raise LookupError(f'Account {expected_account} not found in {wallet.left_panel.accounts}')

    with step('Delete wallet account with agreement'):
        wallet.left_panel.delete_account_from_context_menu(new_name).agree_and_confirm()

    # TODO: add toast check for deletion when https://github.com/status-im/status-desktop/issues/12541 fixed

    with step('Verify that the account is not displayed in accounts list'):
        assert driver.waitFor(lambda: new_name not in [account.name for account in wallet.left_panel.accounts], 10000), \
            f'Account with {new_name} is still displayed even it should not be'


@allure.testcase('https://ethstatus.testrail.net/index.php?/cases/view/703514',
                 'Choosing Use Keycard when adding account')
@pytest.mark.case(703514)
def test_use_keycard_when_adding_account(main_screen: MainWindow):
    with step('Choose continue in keycard settings'):
        wallet = main_screen.left_panel.open_wallet()
        SigningPhrasePopup().wait_until_appears().confirm_phrase()
        account_popup = wallet.left_panel.open_add_account_popup()
        account_popup.continue_in_keycard_settings()
        account_popup.wait_until_hidden()

    with (step('Verify that keycard settings view opened and all keycard settings available')):
        keycard_view = KeycardSettingsView()
        keycard_view.check_keycard_screen_loaded()
        keycard_view.all_keycard_options_available()
