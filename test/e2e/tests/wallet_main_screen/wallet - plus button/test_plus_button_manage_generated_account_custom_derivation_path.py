import random
import time

import allure
import pytest
from allure_commons._allure import step

import driver
from constants import RandomWalletAccount
from constants.wallet import DerivationPathName
from scripts.utils.generators import random_wallet_acc_keypair_name
from tests.wallet_main_screen import marks

import constants
from gui.components.signing_phrase_popup import SigningPhrasePopup
from gui.main_window import MainWindow

pytestmark = marks


@allure.testcase('https://ethstatus.testrail.net/index.php?/cases/view/703028', 'Manage a custom generated account')
@pytest.mark.case(703028)
def test_plus_button_manage_generated_account_custom_derivation_path(main_screen: MainWindow, user_account):
    with step('Create generated wallet account'):
        wallet_account = RandomWalletAccount()

        wallet = main_screen.left_panel.open_wallet()
        account_popup = wallet.left_panel.open_add_account_popup()
        account_popup.set_name(wallet_account.name).set_derivation_path(
            DerivationPathName.select_random_path_name().value,
            random.randrange(2, 100),
            user_account.password).save_changes()

    with step('Verify toast message notification when adding account'):
        assert len(main_screen.wait_for_notification()) == 1, \
            f"Multiple toast messages appeared"
        message = main_screen.wait_for_notification()[0]
        assert message == f'"{wallet_account.name}" successfully added'

    with step('Verify that the account is correctly displayed in accounts list'):
        assert driver.waitFor(lambda: wallet_account.name in [account.name for account in wallet.left_panel.accounts],
                              10000), \
            f'Account with {wallet_account.name} is not displayed even it should be'



