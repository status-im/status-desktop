import time

import allure
import pyperclip
import pytest
from allure_commons._allure import step

from constants.wallet import WalletSeedPhrase
from helpers.WalletHelper import authenticate_with_password
from scripts.utils.generators import random_mnemonic
from tests.wallet_main_screen import marks

import constants
from gui.components.signing_phrase_popup import SigningPhrasePopup
from gui.main_window import MainWindow
from scripts.utils.generators import get_wallet_address_from_mnemonic

pytestmark = marks


@allure.testcase('https://ethstatus.testrail.net/index.php?/cases/view/703030', 'Manage a seed phrase imported account')
@pytest.mark.case(703030)
@pytest.mark.parametrize('name, color, emoji, emoji_unicode, '
                         'new_name, new_color, new_emoji, new_emoji_unicode', [
                             pytest.param('SPAcc24', '#2a4af5', 'sunglasses', '1f60e',
                                          'SPAcc24edited', '#216266', 'thumbsup', '1f44d'
                                          )
                         ])
def test_plus_button_manage_account_from_seed_phrase(main_screen: MainWindow, user_account,
                                                     name: str, color: str, emoji: str, emoji_unicode: str,
                                                     new_name: str, new_color: str, new_emoji: str,
                                                     new_emoji_unicode: str):
    with step('Create imported seed phrase wallet account'):
        mnemonic_data = random_mnemonic()
        wallet = main_screen.left_panel.open_wallet()
        SigningPhrasePopup().wait_until_appears().confirm_phrase()
        account_popup = wallet.left_panel.open_add_account_popup()
        account_popup.set_name(name).set_emoji(emoji).set_color(
            color).open_add_new_account_popup().import_new_seed_phrase(mnemonic_data.split())
        account_popup.save_changes()
        authenticate_with_password(user_account)
        account_popup.wait_until_hidden()

    with step('Verify toast message notification when adding account'):
        assert len(main_screen.wait_for_notification()) == 1, \
            f"Multiple toast messages appeared"
        message = main_screen.wait_for_notification()[0]
        assert message == f'"{name}" successfully added'

    with step('Verify that the account is correctly displayed in accounts list'):
        expected_account = constants.user.account_list_item(name, color.lower(), emoji_unicode)
        started_at = time.monotonic()
        while expected_account not in wallet.left_panel.accounts:
            time.sleep(1)
            if time.monotonic() - started_at > 15:
                raise LookupError(f'Account {expected_account} not found in {wallet.left_panel.accounts}')

    with step('Verify account address from UI is correct for derived account '):
        address_in_ui = wallet.left_panel.copy_account_address_in_context_menu(name).split(':')[-1]
        address_from_mnemonic = get_wallet_address_from_mnemonic(mnemonic_data)
        assert address_in_ui == address_from_mnemonic, \
            f'Expected to recover {address_from_mnemonic} but got {address_in_ui}'

    with step('Try to re-import seed phrase and verify that correct error appears'):
        account_popup = wallet.left_panel.open_add_account_popup()
        add_new_account = account_popup.set_name(name).set_emoji(emoji).set_color(color).open_add_new_account_popup()
        add_new_account.enter_new_seed_phrase(mnemonic_data.split())
        assert add_new_account.get_already_added_error() == WalletSeedPhrase.WALLET_SEED_PHRASE_ALREADY_ADDED.value

    with step('Delete account'):
        with step('Delete wallet account'):
            wallet.left_panel.delete_account_from_context_menu(name).agree_and_confirm()

    with step('Add the same account again and check derivation path'):
        add_new_account_popup = wallet.left_panel.open_add_account_popup()
        add_same_account = add_new_account_popup.set_name(name).set_emoji(emoji).set_color(color).open_add_new_account_popup()
        add_same_account.import_new_seed_phrase(mnemonic_data.split())
        add_new_account_popup.save_changes()
        authenticate_with_password(user_account)
        add_new_account_popup.wait_until_hidden()

    with step('Verify derivation path'):
        edit_account_popup = wallet.left_panel.open_edit_account_popup_from_context_menu(name)
        edit_account_popup.copy_derivation_path_button.click()
        derivation_path = pyperclip.paste()
        assert derivation_path.endswith('0')

