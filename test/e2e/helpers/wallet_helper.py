from allure_commons._allure import step

import configs
import driver

from gui.components.authenticate_popup import AuthenticatePopup


def authenticate_with_password(user_account):
    AuthenticatePopup().wait_until_appears().authenticate(user_account.password)
    AuthenticatePopup().wait_until_hidden()


def open_send_modal_for_account(main_window, account_name):
    wallet = main_window.left_panel.open_wallet()
    assert wallet.left_panel.all_accounts_balance.wait_until_appears().is_visible, \
        f"Total balance is not visible"
    wallet_account = wallet.left_panel.select_account(account_name)
    send_popup = wallet_account.open_send_popup()
    return send_popup
