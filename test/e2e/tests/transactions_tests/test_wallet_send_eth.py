import allure
import pytest

import configs
import driver
from configs import WALLET_SEED
from constants import ReturningUser
from constants.wallet import WalletTransactions, WalletAddress, WalletNetworkSettings
from helpers.OnboardingHelper import open_generate_new_keys_view, open_import_seed_view_and_do_import, \
    finalize_onboarding_and_login
from helpers.SettingsHelper import enable_testnet_mode
from helpers.WalletHelper import authenticate_with_password, open_send_modal_for_account


@allure.testcase('https://ethstatus.testrail.net/index.php?/cases/view/704527',
                 'Send: can send 0 ETH to address pasted into receiver field with Simple flow')
@pytest.mark.case(704527, 738784)
@pytest.mark.transaction
@pytest.mark.smoke
@pytest.mark.parametrize('receiver_account_address, amount, asset, collectible', [
    pytest.param(WalletAddress.RECEIVER_ADDRESS.value, 0, 'ETH', '')
])
@pytest.mark.timeout(timeout=120)
def test_wallet_send_0_eth(main_window, user_account, receiver_account_address, amount, asset, collectible):
    user_account = ReturningUser(
        seed_phrase=WALLET_SEED,
        status_address='0x44ddd47a0c7681a5b0fa080a56cbb7701db4bb43')

    keys_screen = open_generate_new_keys_view()
    profile_view = open_import_seed_view_and_do_import(keys_screen, user_account.seed_phrase, user_account)
    finalize_onboarding_and_login(profile_view, user_account)
    enable_testnet_mode(main_window)

    send_popup = open_send_modal_for_account(
        main_window, account_name=WalletNetworkSettings.STATUS_ACCOUNT_DEFAULT_NAME)

    send_popup.send(receiver_account_address, amount, asset)
    assert driver.waitFor(lambda: send_popup._mainnet_network.is_visible, configs.timeouts.UI_LOAD_TIMEOUT_SEC)

    authenticate_with_password(user_account)

    assert WalletTransactions.TRANSACTION_SENDING_TOAST_MESSAGE.value + ' ' + str(amount) + ' ' + asset in ' '.join(
        main_window.wait_for_notification())
