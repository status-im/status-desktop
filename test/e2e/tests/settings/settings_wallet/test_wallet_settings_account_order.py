import allure
import pytest
from allure_commons._allure import step

from helpers.wallet_helper import authenticate_with_password

import configs
import driver
from gui.main_window import MainWindow



def _verify_account_order(account_order, main_screen, default_name, order):
    with step('Verify the account order'):
        with step('Account order is correct in wallet settings'):
            assert driver.waitFor(lambda: account_order.accounts[0].name == order[0],
                                  configs.timeouts.UI_LOAD_TIMEOUT_MSEC)
            assert driver.waitFor(lambda: account_order.accounts[1].name == order[1],
                                  configs.timeouts.UI_LOAD_TIMEOUT_MSEC)
            assert driver.waitFor(lambda: account_order.accounts[2].name == order[2],
                                  configs.timeouts.UI_LOAD_TIMEOUT_MSEC)

        with step('Account order is correct in wallet'):
            wallet = main_screen.left_panel.open_wallet()
            wallet.left_panel.select_account(default_name)
            assert driver.waitFor(lambda: wallet.left_panel.accounts[0].name == order[0],
                                  configs.timeouts.UI_LOAD_TIMEOUT_MSEC)
            assert driver.waitFor(lambda: wallet.left_panel.accounts[1].name == order[1],
                                  configs.timeouts.UI_LOAD_TIMEOUT_MSEC)
            assert driver.waitFor(lambda: wallet.left_panel.accounts[2].name == order[2],
                                  configs.timeouts.UI_LOAD_TIMEOUT_MSEC)


@allure.testcase('https://ethstatus.testrail.net/index.php?/cases/view/703415',
                 'Account order: account order could be changed with drag&drop')
@pytest.mark.case(703415)
@pytest.mark.skip("To check if we need that test at all in e2e")
def test_change_account_order_by_drag_and_drop(main_screen: MainWindow, user_account):
    default_name = 'Account 1'
    name_1, emoji_1, acc_emoji_1 = 'Generated 1', 'sunglasses', '😎 '
    name_2, emoji_2, acc_emoji_2 = 'Generated 2', 'thumbsup', '👍 '

    wallet = main_screen.left_panel.open_wallet()

    colors = []

    for account in (
            (name_1, emoji_1, acc_emoji_1),
            (name_2, emoji_2, acc_emoji_2)
    ):
        with step('Create generated wallet account'):
            account_popup = wallet.left_panel.open_add_account_popup()
            account_popup.set_name(account[0]).set_emoji(account[1])
            colors.append(account_popup.set_random_color())
            account_popup.save_changes()
            authenticate_with_password(user_account)
            account_popup.wait_until_hidden()

    with step('Verify accounts in wallet settings'):
        account_order = main_screen.left_panel.open_settings().left_panel.open_wallet_settings().open_account_order()
        with step('Account order is correct'):
            assert account_order.accounts[0].name == default_name
            assert account_order.accounts[1].name == name_1
            assert account_order.accounts[2].name == name_2
        with step('Icons on accounts are correct'):
            assert account_order.accounts[1].icon_color == colors[0]
            assert account_order.accounts[1].icon_emoji == acc_emoji_1
            assert account_order.accounts[2].icon_color == colors[1]
            assert account_order.accounts[2].icon_emoji == acc_emoji_2

    with step('Drag first account to the end of the list'):
        account_order.drag_account(default_name, 2)

        _verify_account_order(
            account_order, main_screen, default_name, (name_1, name_2, default_name)
        )

    with step('Drag second account to the top of the list'):
        account_order = main_screen.left_panel.open_settings().left_panel.open_wallet_settings().open_account_order()
        account_order.drag_account(name_2, 0)

        _verify_account_order(
            account_order, main_screen, default_name, (name_2, name_1, default_name)
        )


@allure.testcase('https://ethstatus.testrail.net/index.php?/cases/edit/703416',
                 'Account order: reordering is not possible having a single account')
@pytest.mark.case(703416)
@pytest.mark.parametrize('default_name, text_on_top', [
    pytest.param('Account 1', 'This account looks a little lonely. Add another account'
                              ' to enable re-ordering.')
])
def test_change_account_order_not_possible(main_screen: MainWindow, default_name: str, text_on_top: str):
    with step('Open edit account order view'):
        account_order = main_screen.left_panel.open_settings().left_panel.open_wallet_settings().open_account_order()

    with step('Verify that only default account displayed'):
        assert len(account_order.accounts) == 1
        assert account_order.accounts[0].name == default_name

    with step('Back button is present and text on top is correct'):
        assert account_order.account_recommendations[0] == text_on_top
        assert account_order.is_back_button_present() is True
