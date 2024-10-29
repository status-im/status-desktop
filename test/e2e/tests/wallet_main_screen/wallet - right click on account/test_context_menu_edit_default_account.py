import time

import allure
import pytest
from allure_commons._allure import step

from constants.wallet import WalletNetworkSettings
from scripts.utils.generators import random_wallet_acc_keypair_name
from tests.wallet_main_screen import marks

import constants
from gui.components.signing_phrase_popup import SigningPhrasePopup
from gui.main_window import MainWindow

pytestmark = marks
@allure.testcase('https://ethstatus.testrail.net/index.php?/cases/view/703022', 'Edit default wallet account')
@pytest.mark.case(703022)
def test_context_menu_edit_default_account(main_screen: MainWindow, user_account):

    name = WalletNetworkSettings.STATUS_ACCOUNT_DEFAULT_NAME.value
    new_name = random_wallet_acc_keypair_name()

    with step('Select wallet account'):
        wallet = main_screen.left_panel.open_wallet()
        SigningPhrasePopup().wait_until_appears().confirm_phrase()
        wallet.left_panel.select_account(name)

    with step("Verify default status account can't be deleted"):
        context_menu = wallet.left_panel._open_context_menu_for_account(name)
        assert not context_menu.delete_from_context.is_visible, \
            f"Delete option should not be present for Status account"

    with step('Edit wallet account'):
        account_popup = wallet.left_panel.open_edit_account_popup_from_context_menu(name)
        account_popup.set_name(new_name).save_changes()

    with step('Verify that the account is correctly displayed in accounts list'):
        expected_account = constants.user.account_list_item(new_name, None, None)
        started_at = time.monotonic()
        while expected_account not in wallet.left_panel.accounts:
            time.sleep(1)
            if time.monotonic() - started_at > 15:
                raise LookupError(f'Account {expected_account} not found in {wallet.left_panel.accounts}')
