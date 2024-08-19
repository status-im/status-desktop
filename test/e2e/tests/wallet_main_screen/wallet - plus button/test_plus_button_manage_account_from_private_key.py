import time

import allure
import pytest
from allure_commons._allure import step

from constants import UserAccount, RandomUser
from scripts.utils.generators import random_password_string
from tests.wallet_main_screen import marks

import constants
import driver
from gui.components.signing_phrase_popup import SigningPhrasePopup
from gui.components.authenticate_popup import AuthenticatePopup
from gui.main_window import MainWindow

pytestmark = marks


@allure.testcase('https://ethstatus.testrail.net/index.php?/cases/view/703029', 'Manage a private key imported account')
@pytest.mark.case(703029)
@pytest.mark.parametrize('user_account', [RandomUser()])
@pytest.mark.parametrize('address_pair', [constants.user.private_key_address_pair_1])
@pytest.mark.parametrize('name, color, emoji, emoji_unicode, '
                         'new_name, new_color, new_emoji, new_emoji_unicode', [
                             pytest.param('PrivKeyAcc1', '#2a4af5', 'sunglasses', '1f60e',
                                          'PrivKeyAcc1edited', '#216266', 'thumbsup', '1f44d')
                         ])
def test_plus_button_manage_account_from_private_key(main_screen: MainWindow, user_account, address_pair,
                                                     name: str, color: str, emoji: str, emoji_unicode: str,
                                                     new_name: str, new_color: str, new_emoji: str,
                                                     new_emoji_unicode: str):
    with step('Import an account within private key'):
        wallet = main_screen.left_panel.open_wallet()
        SigningPhrasePopup().wait_until_appears().confirm_phrase()
        account_popup = wallet.left_panel.open_add_account_popup()
        account_popup.set_name(name).set_emoji(emoji).set_color(color).set_origin_private_key(
            address_pair.private_key, address_pair.private_key[:5]).save_changes()
        AuthenticatePopup().wait_until_appears().authenticate(user_account.password)
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

    with step('Verify that importing private key reveals correct wallet address'):
        account_index = 0
        settings_acc_view = (
            main_screen.left_panel.open_settings().left_panel.open_wallet_settings().open_account_in_settings(name,
                                                                                                              account_index))
        address = settings_acc_view.get_account_address_value()
        assert address == address_pair.wallet_address, \
            f"Recovered account should have address {address_pair.wallet_address}, but has {address}"

    with step('Edit wallet account'):
        main_screen.left_panel.open_wallet()
        account_popup = wallet.left_panel.open_edit_account_popup_from_context_menu(name)
        account_popup.set_name(new_name).set_emoji(new_emoji).set_color(new_color).save_changes()

    with step('Verify that the account is correctly displayed in accounts list'):
        expected_account = constants.user.account_list_item(new_name, new_color.lower(), new_emoji_unicode)
        started_at = time.monotonic()
        while expected_account not in wallet.left_panel.accounts:
            time.sleep(1)
            if time.monotonic() - started_at > 15:
                raise LookupError(f'Account {expected_account} not found in {wallet.left_panel.accounts}')

    with step('Delete wallet account'):
        wallet.left_panel.delete_account_from_context_menu(new_name).agree_and_confirm()

    with step('Verify toast message notification when removing account'):
        messages = main_screen.wait_for_notification()
        assert f'"{new_name}" successfully removed' in messages, \
            f"Toast message about account removal is not correct or not present. Current list of messages: {messages}"

    with step('Verify that the account is not displayed in accounts list'):
        assert driver.waitFor(lambda: new_name not in [account.name for account in wallet.left_panel.accounts], 10000), \
            f'Account with {new_name} is still displayed even it should not be'
