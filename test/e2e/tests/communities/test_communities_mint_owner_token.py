import time

import allure
import pytest
from allure_commons._allure import step

import configs
import constants
import driver
from . import marks
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
@pytest.mark.parametrize('user_account', [constants.user.user_with_funds])
@pytest.mark.transaction
def test_mint_owner_token(keys_screen, main_window, user_account):
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

    with step('Enable creation of community option'):
        settings = main_window.left_panel.open_settings()
        settings.left_panel.open_advanced_settings().enable_creation_of_communities()

    with step('Set testnet mode'):
        settings = main_window.left_panel.open_settings()
        wallet_settings = settings.left_panel.open_wallet_settings()
        wallet_settings.open_networks().switch_testnet_mode_toggle().turn_on_testnet_mode_in_testnet_modal()

    with step('Switch manage community on testnet option'):
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

    with step('Verify all elements of owner token panel'):
        tokens_screen.verify_text_on_owner_token_panel()

    with step('Verify all elements of master token panel'):
        tokens_screen.verify_text_on_master_token_panel()

    with step('Click next'):
        edit_owner_token_view = tokens_screen.click_next()

    with (step('Verify all elements of owner token section')):
        with step('Verify name'):
            assert MintOwnerTokensElements.OWNER_TOKEN_NAME.value + \
                   community_params['name'] in edit_owner_token_view.get_all_text_labels()
        with step('Verify symbol'):
            assert edit_owner_token_view.get_symbol_box_content(0) == (
                    MintOwnerTokensElements.OWNER_TOKEN_SYMBOL.value + community_params['name'][:3]).upper()
        with step('Verify crown'):
            assert edit_owner_token_view.get_crown_symbol
        with step('Verify total and remaining fields'):
            assert edit_owner_token_view.get_total_box_content(0) == '1'
            assert edit_owner_token_view.get_remaining_box_content(0) == '1'
        with step('Verify transferable and destructible'):
            assert edit_owner_token_view.get_transferable_box_content(0) == 'Yes'
            assert edit_owner_token_view.get_destructible_box_content(0) == 'No'

    with step('Verify all elements of master token section'):
        with step('Verify name'):
            assert MintOwnerTokensElements.MASTER_TOKEN_NAME.value + \
                   community_params['name'] in edit_owner_token_view.get_all_text_labels()
        with step('Verify symbol'):
            assert edit_owner_token_view.get_symbol_box_content(1) == (
                    MintOwnerTokensElements.MASTER_TOKEN_SYMBOL.value + community_params[
                                                                            'name'][:3]).upper()
        with step('Verify coin'):
            assert edit_owner_token_view.get_coin_symbol
        with step('Verify total and remaining fields'):
            assert edit_owner_token_view.get_total_box_content(1) == '∞'
            assert edit_owner_token_view.get_remaining_box_content(1) == '∞'
        with step('Verify transferable and destructible'):
            assert edit_owner_token_view.get_transferable_box_content(1) == 'No'
            assert edit_owner_token_view.get_destructible_box_content(1) == 'Yes'

    with step('Select Mainnet network'):
        select_network = edit_owner_token_view.select_mainnet_network()

    with step('Verify fees title and gas fees exist'):
        assert driver.waitFor(lambda: edit_owner_token_view.get_fee_title == 'Mint ' + community_params[
            'name'] + MintOwnerTokensElements.SIGN_TRANSACTION_MINT_TITLE.value, configs.timeouts.UI_LOAD_TIMEOUT_MSEC)
        assert driver.waitFor(lambda: edit_owner_token_view.get_fee_total_value != '',
                              configs.timeouts.UI_LOAD_TIMEOUT_MSEC)

    with step('Start minting'):
        start_minting = edit_owner_token_view.click_mint()

    with step('Verify fee text and sign transaction'):
        assert start_minting.get_fee_title == 'Mint ' + community_params[
            'name'] + MintOwnerTokensElements.SIGN_TRANSACTION_MINT_TITLE.value
        assert start_minting.get_fee_total_value != ''
        start_minting.sign_transaction(user_account.password)
        time.sleep(1)
        minted_tokens_view = MintedTokensView()

    with step('Verify that status of both tokens is Minting'):
        assert minted_tokens_view.get_owner_token_status == 'Minting...'
        assert minted_tokens_view.get_master_token_status == 'Minting...'

    with step('Verify toast messages about started minting process appears'):
        toast_messages = main_window.wait_for_notification()
        assert driver.waitFor(lambda: (MintOwnerTokensElements.TOAST_AIRDROPPING_TOKEN_1.value + community_params[
            'name'] + MintOwnerTokensElements.TOAST_AIRDROPPING_TOKEN_2.value) in toast_messages,
                              configs.timeouts.UI_LOAD_TIMEOUT_MSEC)
        assert driver.waitFor(lambda: (community_params[
                                           'name'] + MintOwnerTokensElements.TOAST_TOKENS_BEING_MINTED.value) in toast_messages,
                              configs.timeouts.UI_LOAD_TIMEOUT_MSEC)
