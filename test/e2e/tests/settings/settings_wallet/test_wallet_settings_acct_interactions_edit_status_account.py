import random
import string

import allure
import pytest

from constants.wallet import WalletNetworkSettings, DerivationPath, WalletAccountSettings
from gui.main_window import MainWindow


@allure.testcase('https://ethstatus.testrail.net/index.php?/cases/view/704433',
                 'Account view interactions: Edit Status default account')
@pytest.mark.case(704433)
@pytest.mark.parametrize('new_name', [
    pytest.param(''.join(random.choices(string.ascii_letters +
                                        string.digits, k=40)))
])
def test_settings_edit_status_account(main_screen: MainWindow, new_name):
    status_acc_view = (
        main_screen.left_panel.open_settings().left_panel.open_wallet_settings().open_status_account_in_settings())

    assert status_acc_view.get_account_name_value() == WalletNetworkSettings.STATUS_ACCOUNT_DEFAULT_NAME.value, \
        f"Status main account name must be {WalletNetworkSettings.STATUS_ACCOUNT_DEFAULT_NAME.value}"
    assert status_acc_view.get_account_color_value() == WalletNetworkSettings.STATUS_ACCOUNT_DEFAULT_COLOR.value, \
        f"Status main account color must be {WalletNetworkSettings.STATUS_ACCOUNT_DEFAULT_COLOR.value}"

    assert status_acc_view.get_account_origin_value() == WalletAccountSettings.STATUS_ACCOUNT_ORIGIN.value, \
        f"Status account origin label is incorrect"

    assert status_acc_view.get_account_derivation_path_value() == DerivationPath.STATUS_ACCOUNT_DERIVATION_PATH.value, \
        f"Status account derivation path must be {DerivationPath.STATUS_ACCOUNT_DERIVATION_PATH.value}"

    assert status_acc_view.get_account_storage_value() == WalletAccountSettings.STORED_ON_DEVICE.value, \
        f"Status account storage should be {WalletAccountSettings.STORED_ON_DEVICE.value}"

    account_emoji_id_before = status_acc_view.get_account_emoji_id()

    edit_acc_pop_up = status_acc_view.click_edit_account_button()
    edit_acc_pop_up.type_in_account_name(new_name)
    edit_acc_pop_up.select_random_color_for_account()
    edit_acc_pop_up.select_random_emoji_for_account()
    edit_acc_pop_up.click_change_name_button()
    edit_acc_pop_up.wait_until_hidden()
    current_color = status_acc_view.get_account_color_value()
    account_emoji_id_after = status_acc_view.get_account_emoji_id()

    assert not status_acc_view.is_remove_account_button_visible(), \
        f"Delete button should not be present for Status account"
    assert status_acc_view.get_account_name_value() == new_name, f"Account name has not been changed"
    assert account_emoji_id_before != account_emoji_id_after, f"Account emoji has not been changed"
    assert WalletNetworkSettings.STATUS_ACCOUNT_DEFAULT_COLOR.value != current_color, \
        (f"Account color has not been changed: color before was {WalletNetworkSettings.STATUS_ACCOUNT_DEFAULT_COLOR.value},"
         f" color after is {current_color}")

