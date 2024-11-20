import time

import allure
import pytest
from allure import step

from helpers.WalletHelper import authenticate_with_password
from scripts.utils.generators import random_wallet_acc_keypair_name
from tests.wallet_main_screen import marks

import constants
from gui.components.signing_phrase_popup import SigningPhrasePopup
from gui.main_window import MainWindow

pytestmark = marks


@allure.testcase('https://ethstatus.testrail.net/index.php?/cases/view/703036',
                 'Manage an account created from the generated seed phrase')
@pytest.mark.case(703036)
def test_plus_button_manage_account_added_for_new_seed(main_screen: MainWindow, user_account):
    name = random_wallet_acc_keypair_name()
    keypair_name = random_wallet_acc_keypair_name()

    with step('Create generated seed phrase wallet account'):
        wallet = main_screen.left_panel.open_wallet()
        account_popup = wallet.left_panel.open_add_account_popup()
        account_popup.set_name(name).set_origin_new_seed_phrase(
            keypair_name).save_changes()
        authenticate_with_password(user_account)
        account_popup.wait_until_hidden()

    with step('Verify toast message notification when adding account'):
        assert len(main_screen.wait_for_notification()) == 1, \
            f"Multiple toast messages appeared"
        message = main_screen.wait_for_notification()[0]
        assert message == f'"{name}" successfully added'

    with step('Verify that the account is correctly displayed in accounts list'):
        expected_account = constants.user.account_list_item(name, None, None)
        started_at = time.monotonic()
        while expected_account not in wallet.left_panel.accounts:
            time.sleep(1)
            if time.monotonic() - started_at > 15:
                raise LookupError(f'Account {expected_account} not found in {wallet.left_panel.accounts}')

