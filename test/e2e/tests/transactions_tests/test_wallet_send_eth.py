import allure
import pytest
from allure_commons._allure import step

import configs
import driver
from constants import ReturningUser, ReturningUsersData
from constants.wallet import WalletTransactions
from gui.components.onboarding.before_started_popup import BeforeStartedPopUp
from gui.components.onboarding.beta_consent_popup import BetaConsentPopup
from gui.components.signing_phrase_popup import SigningPhrasePopup
from gui.components.splash_screen import SplashScreen
from gui.components.authenticate_popup import AuthenticatePopup
from gui.screens.onboarding import KeysView, WelcomeToStatusView, BiometricsView, YourEmojihashAndIdenticonRingView


@pytest.fixture
def keys_screen(main_window) -> KeysView:
    with step('Open Generate new keys view'):
        BeforeStartedPopUp().get_started()
        welcome_screen = WelcomeToStatusView().wait_until_appears()
        return welcome_screen.get_keys()


@allure.testcase('https://ethstatus.testrail.net/index.php?/cases/view/704527',
                 'Send: can send 0 ETH to address pasted into receiver field with Simple flow')
@pytest.mark.case(704527)
@pytest.mark.transaction
@pytest.mark.parametrize('user_account', [ReturningUser(
    seed_phrase=ReturningUsersData.WALLET_USER.value[0],
    status_address=ReturningUsersData.WALLET_USER.value[1]
)])
@pytest.mark.parametrize('receiver_account_address, amount, asset, tab', [
    pytest.param(ReturningUsersData.RETURNING_USER_ONE.value[1], 0, 'Ether', 'Assets')
])
@pytest.mark.timeout(timeout=120)
@pytest.mark.skip(reason="https://github.com/status-im/status-desktop/issues/14862")
@pytest.mark.skip(reason="https://github.com/status-im/status-desktop/issues/14509")
def test_wallet_send_0_eth(keys_screen, main_window, user_account, receiver_account_address, amount, asset, tab):
    with step('Open import seed phrase view and enter seed phrase'):
        input_view = keys_screen.open_import_seed_phrase_view().open_seed_phrase_input_view()
        input_view.input_seed_phrase(user_account.seed_phrase, True)
        profile_view = input_view.import_seed_phrase()
        profile_view.set_display_name(user_account.name)

    with step('Finalize onboarding and open main screen'):
        create_password_view = profile_view.next()
        confirm_password_view = create_password_view.create_password(user_account.password)
        confirm_password_view.confirm_password(user_account.password)
        if configs.system.get_platform() == "Darwin":
            BiometricsView().wait_until_appears().prefer_password()
        SplashScreen().wait_until_appears().wait_until_hidden()
        next_view = YourEmojihashAndIdenticonRingView().verify_emojihash_view_present().next()
        if configs.system.get_platform() == "Darwin":
            next_view.start_using_status()
        SplashScreen().wait_until_appears().wait_until_hidden()
        if not configs.system.TEST_MODE and not configs._local.DEV_BUILD:
            BetaConsentPopup().confirm()

    with step('Verify that restored account reveals correct status wallet address'):
        wallet_settings = main_window.left_panel.open_settings().left_panel.open_wallet_settings()
        status_acc_view = wallet_settings.open_account_in_settings('Account 1', '0')
        address = status_acc_view.get_account_address_value()
        assert address == user_account.status_address, \
            f"Recovered account should have address {user_account.status_address}, but has {address}"
        status_acc_view.click_back_button()

    with step('Set testnet mode'):
        wallet_settings.open_networks().switch_testnet_mode_toggle().turn_on_testnet_mode_in_testnet_modal()

    with step('Open send popup'):
        wallet = main_window.left_panel.open_wallet()
        SigningPhrasePopup().wait_until_appears().confirm_phrase()
        assert driver.waitFor(lambda: wallet.left_panel.is_total_balance_visible, configs.timeouts.UI_LOAD_TIMEOUT_SEC)
        f"Total balance is not visible"
        wallet_account = wallet.left_panel.select_account('Account 1')
        send_popup = wallet_account.open_send_popup()

    with step('Enter asset, amount and address and click send and verify Mainnet network is shown'):
        send_popup.send(receiver_account_address, amount, asset, tab)
        assert driver.waitFor(lambda: send_popup.is_mainnet_network_identified, configs.timeouts.UI_LOAD_TIMEOUT_SEC)

    with step('Enter password in authenticate popup'):
        AuthenticatePopup().wait_until_appears().authenticate(user_account.password)

    with step('Verify toast message with Transaction pending appears'):
        assert WalletTransactions.TRANSACTION_PENDING_TOAST_MESSAGE.value in ' '.join(
            main_window.wait_for_notification())
