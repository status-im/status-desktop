import time

import pytest
from allure_commons._allure import step

import configs
import constants
from constants import RandomCommunity
from constants.wallet import WalletHistoryTitles, WalletNetworkNaming
from gui.screens.community_settings import CommunitySettingsScreen
from gui.screens.community_settings_tokens import MintedTokensView, TokensView
from helpers.community_tokens_helper import (
    add_generated_account_address,
    mint_community_token,
    mint_owner_and_tokenmaster,
)
from helpers.onboarding_helper import skip_post_login_popups_if_visible
from helpers.settings_helper import enable_managing_communities_toggle
from helpers.wallet_helper import open_wallet_account

NFT_NAME = 'BaseNFT'
NFT_SYMBOL = 'BNFT'
ASSET_NAME = 'BaseAST'
ASSET_SYMBOL = 'BAST'
TOKEN_SUPPLY = '10'
AIRDROP_ACCOUNT_NAME = 'Airdrop dest'
HISTORY_TIMESTAMP_SKEW_SEC = 1


@pytest.mark.transaction
@pytest.mark.parametrize(
    'user_data, user_account',
    [pytest.param(
        configs.testpath.TEST_USER_DATA / 'funds',
        constants.user.funds,
    )],
    indirect=['user_data', 'user_account'],
)
@pytest.mark.parametrize('network_name', [
    pytest.param(WalletNetworkNaming.LAYER2_BASE_SEPOLIA.value, id='base-sepolia'),
])
def test_community_tokens_mint_airdrop_destruct_burn(main_screen, user_account, network_name):
    skip_post_login_popups_if_visible()

    with step('Add a second account in the same profile for airdrop'):
        recipient_address = add_generated_account_address(main_screen, AIRDROP_ACCOUNT_NAME)

    with step('Switch manage community on testnet option'):
        enable_managing_communities_toggle(main_screen)

    with step('Create community and select it'):
        community = RandomCommunity()
        main_screen.left_panel.create_community(community_data=community)
        community_screen = main_screen.left_panel.open_community(community.name)

    with step('Mint Owner and TokenMaster tokens'):
        community_setting = community_screen.left_panel.open_community_settings()
        mint_owner_and_tokenmaster(
            community_setting, user_account.password, network_name, community.name)

    with step('Mint remotely destructible collectible with finite supply'):
        tokens_view = TokensView()
        mint_community_token(
            tokens_view,
            user_account.password,
            name=NFT_NAME,
            description='Base Sepolia e2e collectible',
            symbol=NFT_SYMBOL,
            supply=TOKEN_SUPPLY,
            network_name=network_name,
            is_asset=False,
        )

    with step('Mint community asset with finite supply'):
        tokens_view = community_setting.left_panel.open_tokens()
        mint_community_token(
            tokens_view,
            user_account.password,
            name=ASSET_NAME,
            description='Base Sepolia e2e asset',
            symbol=ASSET_SYMBOL,
            supply=TOKEN_SUPPLY,
            network_name=network_name,
            is_asset=True,
        )

    with step('Airdrop collectible to the second account'):
        token_page = MintedTokensView().open_collectible(NFT_NAME)
        airdrop_view = token_page.open_airdrop()
        airdrop_view.add_eth_recipient(recipient_address)
        airdrop_sent_at = time.time()
        airdrop_view.create_and_sign(user_account.password)

    with step('Wait until the airdrop is confirmed in History'):
        wallet_account = open_wallet_account(main_screen)
        wallet_account.wait_for_new_history_transaction(
            titles=WalletHistoryTitles.AIRDROP,
            network_name=network_name,
            sent_at=airdrop_sent_at,
            timestamp_skew_sec=HISTORY_TIMESTAMP_SKEW_SEC,
        )

    with step('Remotely destruct airdropped collectible'):
        main_screen.left_panel._get_community(community.name)
        main_screen.left_panel.community_template_button.click()
        community_setting = CommunitySettingsScreen().wait_until_appears()
        community_setting.left_panel.open_overview()
        community_setting.left_panel.open_tokens()
        token_page = MintedTokensView().open_collectible(NFT_NAME)
        token_page.wait_for_remaining_tokens(int(TOKEN_SUPPLY) - 1)
        destruct_sent_at = time.time()
        token_page.open_remotely_destruct().destruct_first_holder_and_sign(user_account.password)

    with step('Wait until the destruct is confirmed in History'):
        wallet_account = open_wallet_account(main_screen)
        wallet_account.wait_for_new_history_transaction(
            titles=WalletHistoryTitles.DESTROY,
            network_name=network_name,
            sent_at=destruct_sent_at,
            timestamp_skew_sec=HISTORY_TIMESTAMP_SKEW_SEC,
        )

    with step('Burn remaining collectible supply'):
        main_screen.left_panel._get_community(community.name)
        main_screen.left_panel.community_template_button.click()
        community_setting = CommunitySettingsScreen().wait_until_appears()
        community_setting.left_panel.open_overview()
        community_setting.left_panel.open_tokens()
        token_page = MintedTokensView().open_collectible(NFT_NAME)
        burn_sent_at = time.time()
        token_page.open_burn().burn_all_remaining_and_sign(user_account.password)
        token_page.wait_for_remaining_tokens(0)

    with step('Verify the burn transaction appears in History'):
        wallet_account = open_wallet_account(main_screen)
        wallet_account.wait_for_new_history_transaction(
            titles=WalletHistoryTitles.BURN,
            network_name=network_name,
            sent_at=burn_sent_at,
            timestamp_skew_sec=HISTORY_TIMESTAMP_SKEW_SEC,
        )
