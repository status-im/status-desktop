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
from helpers.OnboardingHelper import open_generate_new_keys_view, open_import_seed_view_and_do_import, \
    finalize_onboarding_and_login
from helpers.SettingsHelper import enable_testnet_mode
from tests.communities import marks
from constants.community_settings import MintOwnerTokensElements
from gui.screens.community_settings_tokens import MintedTokensView

pytestmark = marks


@allure.testcase('https://ethstatus.testrail.net/index.php?/cases/view/727245', 'Mint owner token')
@pytest.mark.case(727245)
@pytest.mark.transaction
def test_mint_owner_and_tokenmaster_tokens(main_window, user_account):
    user_account = ReturningUser(
        seed_phrase=WALLET_SEED,
        status_address='0x44ddd47a0c7681a5b0fa080a56cbb7701db4bb43')

    keys_screen = open_generate_new_keys_view()
    profile_view = open_import_seed_view_and_do_import(keys_screen, user_account.seed_phrase, user_account)
    finalize_onboarding_and_login(profile_view, user_account)

    with step('Enable creation of community option'):
        settings = main_window.left_panel.open_settings()
        settings.left_panel.open_advanced_settings().enable_creation_of_communities()

    enable_testnet_mode(main_window)

    with step('Switch manage community on testnet option'):
        settings = main_window.left_panel.open_settings()
        settings.left_panel.open_advanced_settings().switch_manage_on_community()

    with step('Create simple community'):
        community_params = constants.community_params
        main_window.create_community(community_params['name'], community_params['description'],
                                     community_params['intro'], community_params['outro'],
                                     community_params['logo']['fp'], community_params['banner']['fp'],
                                     ['Activism', 'Art'], constants.community_tags[:2])
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
        minted_tokens_view.check_community_collectibles_statuses()
