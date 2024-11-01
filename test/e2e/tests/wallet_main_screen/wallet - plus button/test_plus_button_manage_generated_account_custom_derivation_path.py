import random
import time

import allure
import pytest
from allure_commons._allure import step

from constants.wallet import DerivationPathName
from scripts.utils.generators import random_wallet_acc_keypair_name
from tests.wallet_main_screen import marks

import constants
from gui.components.signing_phrase_popup import SigningPhrasePopup
from gui.main_window import MainWindow

pytestmark = marks


@allure.testcase('https://ethstatus.testrail.net/index.php?/cases/view/703028', 'Manage a custom generated account')
@pytest.mark.case(703028)
@pytest.mark.xfail(reason="https://github.com/status-im/status-desktop/issues/16683")
def test_plus_button_manage_generated_account_custom_derivation_path(main_screen: MainWindow, user_account):
    with step('Create generated wallet account'):
        name = random_wallet_acc_keypair_name()
        wallet = main_screen.left_panel.open_wallet()
        SigningPhrasePopup().wait_until_appears().confirm_phrase()
        account_popup = wallet.left_panel.open_add_account_popup()
        account_popup.set_name(name).set_derivation_path(
            DerivationPathName.select_random_path_name().value,
            random.randrange(2, 100),
            user_account.password).save_changes()

    with step('Verify that the account is correctly displayed in accounts list'):
        expected_account = constants.user.account_list_item(name, None, None)
        started_at = time.monotonic()
        while expected_account not in wallet.left_panel.accounts:
            time.sleep(1)
            if time.monotonic() - started_at > 15:
                raise LookupError(f'Account {expected_account} not found in {wallet.left_panel.accounts}')

    with step('Verify toast message notification when adding account'):
        assert len(main_screen.wait_for_notification()) == 1, \
            f"Multiple toast messages appeared"
        message = main_screen.wait_for_notification()[0]
        assert message == f'"{name}" successfully added'

