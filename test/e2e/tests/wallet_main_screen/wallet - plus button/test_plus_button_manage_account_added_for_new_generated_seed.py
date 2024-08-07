import random
import string
import time

import allure
import pytest
from allure import step

from constants.wallet import WalletAccountPopup
from tests.wallet_main_screen import marks

import constants
import driver
from gui.components.signing_phrase_popup import SigningPhrasePopup
from gui.components.authenticate_popup import AuthenticatePopup
from gui.main_window import MainWindow

pytestmark = marks


@allure.testcase('https://ethstatus.testrail.net/index.php?/cases/view/703036',
                 'Manage an account created from the generated seed phrase')
@pytest.mark.case(703036)
@pytest.mark.parametrize('user_account', [constants.user.user_with_random_attributes_1])
@pytest.mark.parametrize('name, color, emoji, emoji_unicode, '
                         'new_name, new_color, new_emoji, new_emoji_unicode, keypair_name', [
                             pytest.param('SPAcc', '#2a4af5', 'sunglasses', '1f60e',
                                          'SPAccedited', '#216266', 'thumbsup', '1f44d', 'SPKeyPair')])
def test_plus_button_manage_account_added_for_new_seed(main_screen: MainWindow, user_account,
                                                       name: str, color: str, emoji: str,
                                                       emoji_unicode: str,
                                                       new_name: str, new_color: str, new_emoji: str,
                                                       new_emoji_unicode: str,
                                                       keypair_name: str):
    with step('Create generated seed phrase wallet account'):
        wallet = main_screen.left_panel.open_wallet()
        SigningPhrasePopup().wait_until_appears().confirm_phrase()
        account_popup = wallet.left_panel.open_add_account_popup()
        account_popup.set_name(name).set_emoji(emoji).set_color(color).set_origin_new_seed_phrase(
            keypair_name).save_changes()
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

    with step('Edit wallet account'):
        account_popup = wallet.left_panel.open_edit_account_popup_from_context_menu(name)

        with step('Verify that error appears when name consists of less then 5 characters'):
            account_popup.set_name(''.join(random.choices(string.ascii_letters +
                                                          string.digits, k=4)))
            assert account_popup.get_error_message() == WalletAccountPopup.WALLET_ACCOUNT_NAME_MIN.value

        account_popup.set_name(new_name).set_emoji(new_emoji).set_color(new_color).save_changes()

    with step('Verify that the account is correctly displayed in accounts list'):
        expected_account = constants.user.account_list_item(new_name, new_color.lower(), new_emoji_unicode)
        started_at = time.monotonic()
        while expected_account not in wallet.left_panel.accounts:
            time.sleep(1)
            if time.monotonic() - started_at > 15:
                raise LookupError(f'Account {expected_account} not found in {wallet.left_panel.accounts}')

    with step('Delete wallet account with agreement'):
        wallet.left_panel.delete_account_from_context_menu(new_name).agree_and_confirm()

    with step('Verify toast message notification when removing account'):
        messages = main_screen.wait_for_notification()
        assert f'"{new_name}" successfully removed' in messages, \
            f"Toast message about account removal is not correct or not present. Current list of messages: {messages}"

    with step('Verify that the account is not displayed in accounts list'):
        assert driver.waitFor(lambda: new_name not in [account.name for account in wallet.left_panel.accounts], 10000), \
            f'Account with {new_name} is still displayed even it should not be'
