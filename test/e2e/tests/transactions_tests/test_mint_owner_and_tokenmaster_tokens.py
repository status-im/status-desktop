import random
import time

import allure
import pytest
from allure_commons._allure import step

import configs
import constants
import driver
from configs import WALLET_SEED
from constants import ReturningUser
from tests.communities import marks
from constants.community_settings import MintOwnerTokensElements
from gui.components.onboarding.before_started_popup import BeforeStartedPopUp
from gui.components.onboarding.beta_consent_popup import BetaConsentPopup
from gui.components.splash_screen import SplashScreen
from gui.screens.community_settings_tokens import MintedTokensView
from gui.screens.onboarding import KeysView, WelcomeToStatusView, BiometricsView, YourEmojihashAndIdenticonRingView

pytestmark = marks


@pytest.fixture
def keys_screen(main_window) -> KeysView:
    with step('Open Generate new keys view'):
        BeforeStartedPopUp().get_started()
        wellcome_screen = WelcomeToStatusView().wait_until_appears()
        return wellcome_screen.get_keys()


@allure.testcase('https://ethstatus.testrail.net/index.php?/cases/view/727245', 'Mint owner token')
@pytest.mark.case(727245)
@pytest.mark.transaction
def test_mint_owner_and_tokenmaster_tokens(keys_screen, main_window, user_account):
    user_account = ReturningUser(
        seed_phrase=WALLET_SEED.split(),
        status_address='0x44ddd47a0c7681a5b0fa080a56cbb7701db4bb43')

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

    with step('Enable creation of community option'):
        settings = main_window.left_panel.open_settings()
        settings.left_panel.open_advanced_settings().enable_creation_of_communities()

    with step('Set testnet mode'):
        settings = main_window.left_panel.open_settings()
        wallet_settings = settings.left_panel.open_wallet_settings()
        wallet_settings.open_networks().switch_testnet_mode_toggle().turn_on_testnet_mode_in_testnet_modal()

    with step('Switch manage community on testnet option'):
        settings = main_window.left_panel.open_settings()
        settings.left_panel.open_advanced_settings().switch_manage_on_community()

    with step('Create simple community'):
        community_params = constants.community_params
        main_window.create_community(community_params['name'], community_params['description'],
                                     community_params['intro'], community_params['outro'],
                                     community_params['logo']['fp'], community_params['banner']['fp'])
        community_screen = main_window.left_panel.select_community(community_params['name'])

    with step('Open mint owner token view'):
        community_setting = community_screen.left_panel.open_community_settings()
        tokens_screen = community_setting.left_panel.open_tokens().click_mint_owner_button()

    with step('Click next'):
        edit_owner_token_view = tokens_screen.click_next()

    with step('Select network'):
        network_name = random.choice(['Arbitrum', 'Optimism'])  # no mainnet because of prices
        edit_owner_token_view.select_network(network_name)

    with step('Verify fees title and gas fees exist'):
        assert driver.waitFor(lambda: edit_owner_token_view.get_fee_title == 'Mint ' + community_params[
            'name'] + MintOwnerTokensElements.SIGN_TRANSACTION_MINT_TITLE.value + network_name,
                              configs.timeouts.UI_LOAD_TIMEOUT_MSEC)
        assert driver.waitFor(lambda: edit_owner_token_view.get_fee_total_value != '',
                              configs.timeouts.UI_LOAD_TIMEOUT_MSEC)

    with step('Start minting'):
        start_minting = edit_owner_token_view.click_mint()

    with step('Verify fee text and sign transaction'):
        assert start_minting.get_fee_title == 'Mint ' + community_params[
            'name'] + MintOwnerTokensElements.SIGN_TRANSACTION_MINT_TITLE.value + network_name
        assert start_minting.get_fee_total_value != ''
        start_minting.sign_transaction(user_account.password)
        time.sleep(1)
        minted_tokens_view = MintedTokensView()

    with step('Verify toast messages about started minting process appears'):
        toast_messages = main_window.wait_for_notification()
        assert driver.waitFor(lambda: (MintOwnerTokensElements.TOAST_AIRDROPPING_TOKEN_1.value + community_params[
            'name'] + MintOwnerTokensElements.TOAST_AIRDROPPING_TOKEN_2.value) in toast_messages,
                              configs.timeouts.UI_LOAD_TIMEOUT_MSEC)
        assert driver.waitFor(lambda: (community_params[
                                           'name'] + MintOwnerTokensElements.TOAST_TOKENS_BEING_MINTED.value) in toast_messages,
                              configs.timeouts.UI_LOAD_TIMEOUT_MSEC)

    with step('Verify that status of both tokens'):
        assert driver.waitFor(lambda: (minted_tokens_view.get_owner_token_status == '1 of 1 (you hodl)'), 15000)
        assert driver.waitFor(lambda: (minted_tokens_view.get_master_token_status == '∞'), 15000)
