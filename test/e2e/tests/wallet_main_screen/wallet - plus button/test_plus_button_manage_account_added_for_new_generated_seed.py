import time

import allure
import pytest
from allure import step

from constants import RandomUser
from helpers.WalletHelper import authenticate_with_password
from tests.wallet_main_screen import marks

import constants
from gui.components.signing_phrase_popup import SigningPhrasePopup
from gui.components.authenticate_popup import AuthenticatePopup
from gui.main_window import MainWindow

pytestmark = marks


@allure.testcase('https://ethstatus.testrail.net/index.php?/cases/view/703036',
                 'Manage an account created from the generated seed phrase')
@pytest.mark.case(703036)
@pytest.mark.parametrize('user_account', [RandomUser()])
@pytest.mark.parametrize('name, color, emoji, emoji_unicode, keypair_name', [
                             pytest.param('SPAcc', '#2a4af5', 'sunglasses', '1f60e',
                                          'SPKeyPair')])
def test_plus_button_manage_account_added_for_new_seed(main_screen: MainWindow, user_account,
                                                       name: str, color: str, emoji: str,
                                                       emoji_unicode: str,
                                                       keypair_name: str):
    with step('Create generated seed phrase wallet account'):
        wallet = main_screen.left_panel.open_wallet()
        SigningPhrasePopup().wait_until_appears().confirm_phrase()
        account_popup = wallet.left_panel.open_add_account_popup()
        account_popup.set_name(name).set_emoji(emoji).set_color(color).set_origin_new_seed_phrase(
            keypair_name).save_changes()
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

