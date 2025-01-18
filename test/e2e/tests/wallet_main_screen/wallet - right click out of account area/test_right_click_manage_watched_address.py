import allure
import pytest
from allure_commons._allure import step

import driver
from constants import RandomWalletAccount
from scripts.utils.generators import random_wallet_acc_keypair_name
from tests.wallet_main_screen import marks
from gui.main_window import MainWindow

pytestmark = marks


@allure.testcase('https://ethstatus.testrail.net/index.php?/cases/view/703100',
                 'Manage a watch-only account from context menu option')
@pytest.mark.case(703100)
@pytest.mark.parametrize('address', [
                             pytest.param('0xea123F7beFF45E3C9fdF54B324c29DBdA14a639A')
                         ])
def test_right_click_manage_watch_only_account_context_menu(main_screen: MainWindow, address: str):

    wallet_account = RandomWalletAccount()
    new_name = random_wallet_acc_keypair_name()

    with step('Open wallet main screen'):
        wallet = main_screen.left_panel.open_wallet()

    with step('Create watched address from context menu'):
        account_popup = wallet.left_panel.select_add_watched_address_from_context_menu()
        account_popup.set_name(wallet_account.name).set_eth_address(address).save_changes()
        account_popup.wait_until_hidden()

    with step('Verify toast message notification when adding account'):
        assert len(main_screen.wait_for_notification()) == 1, \
            f"Multiple toast messages appeared"
        message = main_screen.wait_for_notification()[0]
        assert message == f'"{wallet_account.name}" successfully added'

    with step('Right click recently watched address and select edit option'):
        account_popup = wallet.left_panel.open_edit_account_popup_from_context_menu(wallet_account.name)

    with step('Set new name, emoji and color for account and save'):
        account_popup.set_name(new_name).save_changes()

    with step('Verify that the account is correctly displayed in accounts list'):
        assert driver.waitFor(lambda: new_name in [account.name for account in wallet.left_panel.accounts],
                              10000), \
            f'Account with {new_name} is not displayed even it should be'

    with step('Delete watched account with agreement'):
        wallet.left_panel.delete_account_from_context_menu(new_name).confirm()

    with step('Verify toast message notification when removing account'):
        messages = main_screen.wait_for_notification()
        assert f'"{new_name}" successfully removed' in messages, \
            f"Toast message about account removal is not correct or not present. Current list of messages: {messages}"

    with step('Verify that the account is not displayed in accounts list'):
        assert driver.waitFor(lambda: new_name not in [account.name for account in wallet.left_panel.accounts], 10000), \
            f'Account with {new_name} is still displayed even it should not be'
