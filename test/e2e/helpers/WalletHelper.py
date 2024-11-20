from allure_commons._allure import step

import configs
import driver

from gui.components.authenticate_popup import AuthenticatePopup
from gui.components.signing_phrase_popup import SigningPhrasePopup

with step('Authenticate user action with password'):
    def authenticate_with_password(user_account):
        AuthenticatePopup().wait_until_appears().authenticate(user_account.password)
        AuthenticatePopup().wait_until_hidden()

with step('Open wallet send popup'):
    def open_send_modal_for_account(main_window, account_name):
        wallet = main_window.left_panel.open_wallet()
        assert \
            driver.waitFor(lambda: wallet.left_panel.is_total_balance_visible, configs.timeouts.UI_LOAD_TIMEOUT_SEC), \
            f"Total balance is not visible"
        wallet_account = wallet.left_panel.select_account(account_name)
        send_popup = wallet_account.open_send_popup()
        return send_popup
