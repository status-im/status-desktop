import allure
import pytest
from allure_commons._allure import step

import configs
import constants
import driver
from configs.timeouts import UI_LOAD_TIMEOUT_SEC
from constants.wallet import WalletTransactions
from . import marks
from gui.components.onboarding.before_started_popup import BeforeStartedPopUp
from gui.components.onboarding.beta_consent_popup import BetaConsentPopup
from gui.components.splash_screen import SplashScreen
from gui.components.wallet.authenticate_popup import AuthenticatePopup
from gui.components.wallet.send_popup import SendPopup
from gui.screens.onboarding import KeysView, AllowNotificationsView, WelcomeToStatusView, BiometricsView, \
    YourEmojihashAndIdenticonRingView
from gui.screens.settings_ens_usernames import ENSRegisteredView

pytestmark = marks
@pytest.fixture
def keys_screen(main_window) -> KeysView:
    with step('Open Generate new keys view'):
        BeforeStartedPopUp().get_started()
        wellcome_screen = WelcomeToStatusView().wait_until_appears()
        return wellcome_screen.get_keys()


@allure.testcase('https://ethstatus.testrail.net/index.php?/cases/view/704597',
                 'Settings -> ENS usernames: buy ENS name on testnet')
@pytest.mark.case(704597)
@pytest.mark.transaction
@pytest.mark.parametrize('user_account', [constants.user.user_with_funds])
@pytest.mark.parametrize('ens_name', [pytest.param(constants.user.ens_user_name)])
def test_ens_name_purchase(keys_screen, main_window, user_account, ens_name):
    with step('Open import seed phrase view and enter seed phrase'):
        input_view = keys_screen.open_import_seed_phrase_view().open_seed_phrase_input_view()
        input_view.input_seed_phrase(user_account.seed_phrase, True)
        profile_view = input_view.import_seed_phrase()
        profile_view.set_display_name(user_account.name)

    with step('Finalize onboarding and open main screen'):
        create_password_view = profile_view.next()
        confirm_password_view = create_password_view.create_password(user_account.password)
        confirm_password_view.confirm_password(user_account.password)
        if configs.system.IS_MAC:
            BiometricsView().wait_until_appears().prefer_password()
        SplashScreen().wait_until_appears().wait_until_hidden()
        next_view = YourEmojihashAndIdenticonRingView().verify_emojihash_view_present().next()
        if configs.system.IS_MAC:
            next_view.start_using_status()
        SplashScreen().wait_until_appears().wait_until_hidden()
        if not configs.system.TEST_MODE:
            BetaConsentPopup().confirm()

    with step('Set testnet mode'):
        settings = main_window.left_panel.open_settings()
        wallet_settings = settings.left_panel.open_wallet_settings()
        wallet_settings.open_networks().switch_testnet_mode_toggle().turn_on_testnet_mode_in_testnet_modal()

    with step('Open ENS usernames settings and enter user name'):
        ens_settings = settings.left_panel.open_ens_usernames_settings().start()
        ens_settings.enter_user_name(ens_name)
        if driver.waitFor(lambda: 'Username already taken :(' in ens_settings.ens_text_notes(), UI_LOAD_TIMEOUT_SEC):
            ens_settings.enter_user_name(ens_name)

    with step('Verify that user name is available'):
        assert driver.waitFor(lambda: '✓ Username available!' in ens_settings.ens_text_notes(), UI_LOAD_TIMEOUT_SEC)

    with step('Register ens username'):
        register_ens = ens_settings.click_next_button().register_ens_name()

    with step('Confirm sending amount for purchasing ens username in send popup'):
        register_ens.click_send()
        assert driver.waitFor(lambda: SendPopup().is_mainnet_network_identified, configs.timeouts.UI_LOAD_TIMEOUT_SEC)

    with step('Enter password in authenticate popup'):
        AuthenticatePopup().wait_until_appears().authenticate(user_account.password)

    with step('Verify toast message with Transaction pending appears'):
        assert WalletTransactions.TRANSACTION_PENDING_TOAST_MESSAGE.value in ' '.join(
            main_window.wait_for_notification())

    with step('Verify username registered view appears'):
        ENSRegisteredView().wait_until_appears()
