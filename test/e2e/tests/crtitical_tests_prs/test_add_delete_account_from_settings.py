import random
import string

import allure
import pytest
from allure_commons._allure import step

from helpers.wallet_helper import authenticate_with_password

import driver
from constants.wallet import WalletAccountSettings, DerivationPathValue
from gui.main_window import MainWindow
from gui.screens.settings_wallet import WalletSettingsView


@pytest.mark.critical
@allure.testcase('https://ethstatus.testrail.net/index.php?/cases/view/704454',
                 'Account view interactions: Delete generated account')
@pytest.mark.case(704454)
@pytest.mark.parametrize('account_name, color, emoji, emoji_unicode',
                         [
                             pytest.param(''.join(random.choices(string.ascii_letters +
                                                                 string.digits, k=15)), '#2a4af5', 'sunglasses',
                                          '1f60e')
                         ])
def test_delete_generated_account_from_wallet_settings(
        main_screen: MainWindow, user_account, account_name: str, color: str, emoji: str, emoji_unicode: str):
    
    with step('Open add account pop up from wallet settings'):
        add_account_popup = \
            main_screen.left_panel.open_settings().left_panel.open_wallet_settings().open_add_account_pop_up()

    with step('Add a new generated account from wallet settings screen'):
        add_account_popup.set_name(account_name).save_changes()

        with step('Authenticate with password'):
            authenticate_with_password(user_account)
            add_account_popup.wait_until_hidden()

    with step('Open account details view for the generated account'):
        account_index = 1
        acc_view = WalletSettingsView().open_account_in_settings(account_name, account_index)

    with step('Verify details view for the generated account'):
        assert acc_view.get_account_name_value() == account_name, \
            f"Generated account name is incorrect, current name is {acc_view.get_account_name_value()}, expected {account_name}"

        account_address = acc_view.get_account_address_value()
        assert account_address is not None, \
            f"Generated account address is not present"

        assert acc_view.get_account_origin_value() == WalletAccountSettings.STATUS_ACCOUNT_ORIGIN.value, \
            f"Status account origin label is incorrect"

        assert acc_view.get_account_derivation_path_value() == DerivationPathValue.GENERATED_ACCOUNT_DERIVATION_PATH_1.value, \
            f"Status account derivation path must be {DerivationPathValue.GENERATED_ACCOUNT_DERIVATION_PATH_1.value}"

        assert acc_view.get_account_storage_value() == WalletAccountSettings.STORED_ON_DEVICE.value, \
            f"Status account storage should be {WalletAccountSettings.STORED_ON_DEVICE.value}"

    with step('Verify new account appears in Shell grid'):
        shell_screen = main_screen.left_panel.open_shell()
        shell_screen.wait_for_shell_ui_loaded()
        
        # Verify account appears in grid
        assert shell_screen.wait_for_grid_item_by_title(account_name), \
            f"Account '{account_name}' should be visible in Shell grid"

    with step('Navigate to wallet and reopen account details for deletion'):
        # Navigate to wallet screen first, then to settings to get fresh acc_view
        main_screen.shell.open_from_dock("Wallet")
        acc_view = main_screen.left_panel.open_settings().left_panel.open_wallet_settings().open_account_in_settings(account_name, account_index)

    with step('Delete generated account'):
        delete_confirmation_popup = acc_view.click_remove_account_button()
        delete_confirmation_popup.remove_account_with_confirmation()

    with step('Verify toast message notification when removing account'):
        messages = main_screen.wait_for_notification()
        assert f'"{account_name}" successfully removed' in messages, \
            f"Toast message about account removal is not correct or not present. Current list of messages: {messages}"

    with step('Verify the removed account is not displayed in accounts list on main wallet screen'):
        wallet = main_screen.left_panel.open_wallet()
        assert driver.waitFor(
            lambda: account_name not in [account.name for account in wallet.left_panel.accounts], 10000), \
            f'Account with {account_name} is still displayed even it should not be'

    with step('Verify removed account no longer appears in Shell grid'):
        shell_screen = main_screen.left_panel.open_shell()
        shell_screen.wait_for_shell_ui_loaded()
        
        assert shell_screen.wait_for_grid_item_removed_by_title(account_name), \
            f"Account '{account_name}' should no longer be visible in Shell grid"
