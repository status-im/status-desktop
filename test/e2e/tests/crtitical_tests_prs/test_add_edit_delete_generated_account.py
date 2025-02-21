import allure
import pytest
from allure_commons._allure import step

from helpers.WalletHelper import authenticate_with_password
from scripts.utils.generators import random_wallet_acc_keypair_name

import driver
from gui.main_window import MainWindow


@allure.testcase('https://ethstatus.testrail.net/index.php?/cases/view/703033', 'Manage a generated account')
@pytest.mark.case(703033)
@pytest.mark.critical
def test_add_edit_delete_generated_account(main_screen: MainWindow, user_account,):
    with step('Create generated wallet account'):
        name = random_wallet_acc_keypair_name()

        wallet = main_screen.left_panel.open_wallet()
        account_popup = wallet.left_panel.open_add_account_popup()
        account_popup.set_name(name).save_changes()
        authenticate_with_password(user_account)
        account_popup.wait_until_hidden()

    with step('Verify toast message notification when adding account'):
        assert len(main_screen.wait_for_notification()) == 1, \
            f"Multiple toast messages appeared"
        message = main_screen.wait_for_notification()[0]
        assert message == f'"{name}" successfully added'

    with step('Verify that the account is correctly displayed in accounts list'):
        assert driver.waitFor(lambda: name in [account.name for account in wallet.left_panel.accounts], 10000), \
            f'Account with {name} is not found in {wallet.left_panel.accounts}'

    with step('Edit wallet account'):
        new_name = random_wallet_acc_keypair_name()
        account_popup = wallet.left_panel.open_edit_account_popup_from_context_menu(name)
        account_popup.set_name(new_name).save_changes()

    with step('Verify that the account is correctly displayed in accounts list'):
        assert driver.waitFor(lambda: new_name in [account.name for account in wallet.left_panel.accounts], 10000), \
            f'Account with {new_name} is not found in {wallet.left_panel.accounts}'

    with step('Delete wallet account with agreement'):
        wallet.left_panel.delete_account_from_context_menu(new_name).agree_and_confirm()

    with step('Verify toast message notification when removing account'):
        messages = main_screen.wait_for_notification()
        assert f'"{new_name}" successfully removed' in messages, \
            f"Toast message about account removal is not correct or not present. Current list of messages: {messages}"

    with step('Verify that the account is not displayed in accounts list'):
        assert driver.waitFor(lambda: new_name not in [account.name for account in wallet.left_panel.accounts], 10000), \
            f'Account with {new_name} is found in {wallet.left_panel.accounts} after removal'
