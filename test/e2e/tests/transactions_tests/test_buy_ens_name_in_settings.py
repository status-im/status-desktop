import allure
import pytest
from allure_commons._allure import step

import configs
import driver
from configs import WALLET_SEED
from configs.timeouts import UI_LOAD_TIMEOUT_SEC
from constants import ReturningUser
from helpers.OnboardingHelper import open_generate_new_keys_view, open_import_seed_view_and_do_import, \
    finalize_onboarding_and_login
from helpers.SettingsHelper import enable_testnet_mode
from helpers.WalletHelper import authenticate_with_password
from scripts.utils.generators import random_ens_string
from constants.wallet import WalletTransactions
from tests.settings import marks
from gui.components.wallet.send_popup import SendPopup
from gui.screens.settings_ens_usernames import ENSRegisteredView

pytestmark = marks


@allure.testcase('https://ethstatus.testrail.net/index.php?/cases/view/704597',
                 'Settings -> ENS usernames: buy ENS name on testnet')
@pytest.mark.case(704597)
@pytest.mark.transaction
@pytest.mark.parametrize('ens_name', [pytest.param(random_ens_string())])
def test_ens_name_purchase(main_window, user_account, ens_name):

    user_account = ReturningUser(
        seed_phrase=WALLET_SEED,
        status_address='0x44ddd47a0c7681a5b0fa080a56cbb7701db4bb43')

    keys_screen = open_generate_new_keys_view()
    profile_view = open_import_seed_view_and_do_import(keys_screen, user_account.seed_phrase, user_account)
    finalize_onboarding_and_login(profile_view, user_account)
    enable_testnet_mode(main_window)

    with step('Open ENS usernames settings and enter user name'):
        settings = main_window.left_panel.open_settings()
        ens_settings = settings.left_panel.open_ens_usernames_settings().start()
        ens_settings.enter_user_name(ens_name)
        if driver.waitFor(lambda: 'Username already taken :(' in ens_settings.ens_text_notes(), UI_LOAD_TIMEOUT_SEC):
            ens_settings.enter_user_name(ens_name)

    with step('Verify that user name is available'):
        assert driver.waitFor(lambda: '✓ Username available!' in ens_settings.ens_text_notes(), UI_LOAD_TIMEOUT_SEC)

    with step('Register ens username'):
        register_ens = ens_settings.click_next_button().register_ens_name()

    with step('Confirm sending amount for purchasing ens username in send popup'):
        register_ens._send_button.click()
        assert driver.waitFor(lambda: SendPopup()._mainnet_network.is_visible, configs.timeouts.UI_LOAD_TIMEOUT_SEC)

    authenticate_with_password(user_account)

    with step('Verify toast message with Transaction pending appears'):
        assert WalletTransactions.TRANSACTION_SENDING_TOAST_MESSAGE.value in ' '.join(
            main_window.wait_for_notification())

    with step('Verify username registered view appears'):
        ENSRegisteredView().wait_until_appears()
