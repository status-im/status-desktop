import time

import allure
import pytest
from allure_commons._allure import step

import configs.system
import driver
from gui.components.changes_detected_popup import CustomSortOrderChangesDetectedToastMessage
from gui.screens.wallet import WalletAccountView
from gui.screens.settings_wallet import ManageTokensSettingsView
from tests.wallet_main_screen import marks

from gui.components.signing_phrase_popup import SigningPhrasePopup
from gui.main_window import MainWindow

pytestmark = marks


@allure.testcase('https://ethstatus.testrail.net/index.php?/cases/view/727223',
                 'Sort by Asset balance value')
@allure.testcase('https://ethstatus.testrail.net/index.php?/cases/view/727224',
                 'Sort by Asset balance')
@allure.testcase('https://ethstatus.testrail.net/index.php?/cases/view/727225',
                 'Sort by Asset value')
@allure.testcase('https://ethstatus.testrail.net/index.php?/cases/view/727226',
                 'Sort by 1d change: balance value')
@allure.testcase('https://ethstatus.testrail.net/index.php?/cases/view/727227',
                 'Sort by Asset name')
@pytest.mark.case(727223, 727224, 727225, 727226, 727227)
@pytest.mark.parametrize('address, name, dai, wrappedeth, stt, eth', [
    pytest.param('0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2', 'AssetsCollectibles', 'Dai Stablecoin', 'Wrapped Ether',
                 'Status Test Token', 'Ether')
])
@pytest.mark.skip(reason="https://github.com/status-im/status-desktop/issues/14509")
def test_wallet_sort_assets(main_screen: MainWindow, address, name, dai, wrappedeth, stt, eth):
    with step('Turn on Testnet mode'):
        networks = main_screen.left_panel.open_settings().left_panel.open_wallet_settings().open_networks()
        networks.switch_testnet_mode_toggle().turn_on_button.click()

    with step('Add watched address with plus action button'):
        wallet = main_screen.left_panel.open_wallet()
        SigningPhrasePopup().wait_until_appears().confirm_phrase()
        account_popup = wallet.left_panel.open_add_account_popup()
        account_popup.set_name(name).set_origin_watched_address(address).save_changes()
        account_popup.wait_until_hidden()

    with step(
            'Sort assets by asset balance value and verify the value in combobox is correct and the order is correct'):
        wallet_account_view = WalletAccountView()
        sorting = wallet_account_view.open_assets_tab().click_filter_button()
        sorting.choose_sort_by_value('Asset balance value')
        wallet_account_view.click_arrow_button('arrow-up-icon', 1)
        assert wallet_account_view.get_combobox_value() == 'Asset balance value ↑'
        assets_order = wallet_account_view.get_list_of_assets()
        assert driver.waitFor(lambda: assets_order[0].title == dai, 6000)
        assert driver.waitFor(lambda: assets_order[1].title == stt, 6000)
        assert driver.waitFor(lambda: assets_order[2].title == wrappedeth, 6000)
        assert driver.waitFor(lambda: assets_order[3].title == eth, 6000)

        wallet_account_view.click_arrow_button('arrow-down-icon', 1)
        assert wallet_account_view.get_combobox_value() == 'Asset balance value ↓'
        assets_order = wallet_account_view.get_list_of_assets()
        assert driver.waitFor(lambda: assets_order[0].title == eth, 6000)
        assert driver.waitFor(lambda: assets_order[1].title == wrappedeth, 6000)
        assert driver.waitFor(lambda: assets_order[2].title == dai, 6000)
        assert driver.waitFor(lambda: assets_order[3].title == stt, 6000)

    with step('Sort assets by asset balance and verify the value in combobox is correct and the order is correct'):
        sorting.choose_sort_by_value('Asset balance')
        wallet_account_view.click_arrow_button('arrow-up-icon', 2)
        assert wallet_account_view.get_combobox_value() == 'Asset balance ↑'
        assets_order = wallet_account_view.get_list_of_assets()
        assert driver.waitFor(lambda: assets_order[0].title == dai, 6000)
        assert driver.waitFor(lambda: assets_order[1].title == stt, 6000)
        assert driver.waitFor(lambda: assets_order[2].title == wrappedeth, 6000)
        assert driver.waitFor(lambda: assets_order[3].title == eth, 6000)

        wallet_account_view.click_arrow_button('arrow-down-icon', 2)
        assert wallet_account_view.get_combobox_value() == 'Asset balance ↓'
        assets_order = wallet_account_view.get_list_of_assets()
        assert driver.waitFor(lambda: assets_order[0].title == eth, 6000)
        assert driver.waitFor(lambda: assets_order[1].title == wrappedeth, 6000)
        assert driver.waitFor(lambda: assets_order[2].title == dai, 6000)
        assert driver.waitFor(lambda: assets_order[3].title == stt, 6000)

    with step('Sort assets by asset value and verify the value in combobox is correct and the order is correct'):
        sorting.choose_sort_by_value('Asset value')
        wallet_account_view.click_arrow_button('arrow-up-icon', 3)
        assert wallet_account_view.get_combobox_value() == 'Asset value ↑'
        assets_order = wallet_account_view.get_list_of_assets()
        assert driver.waitFor(lambda: assets_order[0].title == stt, 6000)
        assert driver.waitFor(lambda: assets_order[1].title == dai, 6000)
        assert driver.waitFor(lambda: assets_order[2].title == wrappedeth, 6000)
        assert driver.waitFor(lambda: assets_order[3].title == eth, 6000)

        wallet_account_view.click_arrow_button('arrow-down-icon', 3)
        assert wallet_account_view.get_combobox_value() == 'Asset value ↓'
        assets_order = wallet_account_view.get_list_of_assets()
        assert driver.waitFor(lambda: assets_order[0].title == eth, 6000)
        assert driver.waitFor(lambda: assets_order[1].title == wrappedeth, 6000)
        assert driver.waitFor(lambda: assets_order[2].title == dai, 6000)
        assert driver.waitFor(lambda: assets_order[3].title == stt, 6000)

    with step(
            'Sort assets by 1d change: balance value and verify the value in combobox is correct and the order is correct'):
        sorting.choose_sort_by_value('1d change: balance value')
        wallet_account_view.click_arrow_button('arrow-up-icon', 4)
        assert wallet_account_view.get_combobox_value() == '1d change: balance value ↑'
        assets_order = wallet_account_view.get_list_of_assets()
        assert driver.waitFor(lambda: assets_order[0].title == dai, 6000)
        assert driver.waitFor(lambda: assets_order[1].title == stt, 6000)
        assert driver.waitFor(lambda: assets_order[2].title == wrappedeth, 6000)
        assert driver.waitFor(lambda: assets_order[3].title == eth, 6000)

        wallet_account_view.click_arrow_button('arrow-down-icon', 4)
        assert wallet_account_view.get_combobox_value() == '1d change: balance value ↓'
        assets_order = wallet_account_view.get_list_of_assets()
        assert driver.waitFor(lambda: assets_order[0].title == eth, 6000)
        assert driver.waitFor(lambda: assets_order[1].title == wrappedeth, 6000)
        assert driver.waitFor(lambda: assets_order[2].title == dai, 6000)
        assert driver.waitFor(lambda: assets_order[3].title == stt, 6000)

    with step('Sort assets by asset name and verify the value in combobox is correct and the order is correct'):
        sorting.choose_sort_by_value('Asset name')
        wallet_account_view.click_arrow_button('arrow-up-icon', 5)
        assert wallet_account_view.get_combobox_value() == 'Asset name ↑'
        assets_order = wallet_account_view.get_list_of_assets()
        assert driver.waitFor(lambda: assets_order[0].title == dai, 6000)
        assert driver.waitFor(lambda: assets_order[1].title == eth, 6000)
        assert driver.waitFor(lambda: assets_order[2].title == stt, 6000)
        assert driver.waitFor(lambda: assets_order[3].title == wrappedeth, 6000)

        wallet_account_view.click_arrow_button('arrow-down-icon', 5)
        assert wallet_account_view.get_combobox_value() == 'Asset name ↓'
        assets_order = wallet_account_view.get_list_of_assets()
        assert driver.waitFor(lambda: assets_order[0].title == wrappedeth, 6000)
        assert driver.waitFor(lambda: assets_order[1].title == stt, 6000)
        assert driver.waitFor(lambda: assets_order[2].title == eth, 6000)
        assert driver.waitFor(lambda: assets_order[3].title == dai, 6000)


@allure.testcase('https://ethstatus.testrail.net/index.php?/cases/view/704709',
                 'Create custom order')
@allure.testcase('https://ethstatus.testrail.net/index.php?/cases/view/704731',
                 'Select custom order')
@allure.testcase('https://ethstatus.testrail.net/index.php?/cases/view/704732',
                 'Edit custom order')
@pytest.mark.case(704709, 704731, 704732)
@pytest.mark.parametrize('address, name, dai, wrappedeth, stt, eth', [
    pytest.param('0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2', 'AssetsCollectibles', 'Dai Stablecoin', 'Wrapped Ether',
                 'Status Test Token', 'Ether')
])
@pytest.mark.skip(reason="https://github.com/status-im/status-desktop/issues/15655")
def test_custom_ordering(main_screen: MainWindow, address, name, dai, wrappedeth, stt, eth):
    with step('Turn on Testnet mode'):
        networks = main_screen.left_panel.open_settings().left_panel.open_wallet_settings().open_networks()
        networks.switch_testnet_mode_toggle().turn_on_button.click()

    with step('Add watched address with plus action button'):
        wallet = main_screen.left_panel.open_wallet()
        SigningPhrasePopup().wait_until_appears().confirm_phrase()
        account_popup = wallet.left_panel.open_add_account_popup()
        account_popup.set_name(name).set_origin_watched_address(address).save_changes()
        account_popup.wait_until_hidden()

    with (step(
            'Choose Create custom order in sorting dropdown and verify Manage tokens view appears')):
        wallet_account_view = WalletAccountView()
        sorting = wallet_account_view.open_assets_tab().click_filter_button()
        sorting.choose_sort_by_value('Create custom order →')
        manage_tokens = ManageTokensSettingsView()
        ManageTokensSettingsView().wait_until_appears(), 'Manage tokens view was not opened'

    with step('Drag first token to the end of the list and save changes'):
        manage_tokens.drag_token(dai, 3)
        CustomSortOrderChangesDetectedToastMessage().wait_until_appears().save_changes()

    with step('Verify the order is correct in Manage Tokens View'):
        tokens_order = manage_tokens.tokens
        assert driver.waitFor(lambda: tokens_order[0].title == eth, 6000)
        assert driver.waitFor(lambda: tokens_order[1].title == wrappedeth, 6000)
        assert driver.waitFor(lambda: tokens_order[2].title == stt, 6000)
        assert driver.waitFor(lambda: tokens_order[3].title == dai, 6000)

    with step('Go to Wallet view and choose Custom order from dropdown'):
        main_screen.left_panel.open_wallet().left_panel.select_account(name)
        sorting = wallet_account_view.open_assets_tab().click_filter_button()
        sorting.choose_sort_by_value('Custom order')
        assets_order = wallet_account_view.get_list_of_assets()
        assert driver.waitFor(lambda: assets_order[0].title == eth, 6000)
        assert driver.waitFor(lambda: assets_order[1].title == wrappedeth, 6000)
        assert driver.waitFor(lambda: assets_order[2].title == stt, 6000)
        assert driver.waitFor(lambda: assets_order[3].title == dai, 6000)

    with step('Choose Edit custom order in sorting dropdown and verify Manage tokens view appears'):
        sorting.choose_sort_by_value('Edit custom order →')
        manage_tokens = ManageTokensSettingsView()
        assert manage_tokens.exists

    with step('Drag first token to the end of the list and apply changes'):
        manage_tokens.drag_token(eth, 3)
        CustomSortOrderChangesDetectedToastMessage().wait_until_appears().save_and_apply_changes()

    # TODO return these steps back after fix of https://github.com/status-im/status-desktop/issues/15368

    # with step('Verify the order is correct in Manage Tokens View'):
    #     tokens_order = manage_tokens.tokens
    #     assert driver.waitFor(lambda: tokens_order[0].title == wrappedeth, 6000)
    #     assert driver.waitFor(lambda: tokens_order[1].title == stt, 6000)
    #     assert driver.waitFor(lambda: tokens_order[2].title == dai, 6000)
    #     assert driver.waitFor(lambda: tokens_order[3].title == eth, 6000)
    #
    # with step('Verify the order is correct in Wallet view'):
    #     main_screen.left_panel.open_wallet().left_panel.select_account(name)
    #     assets_order = wallet_account_view.get_list_of_assets()
    #     assert driver.waitFor(lambda: assets_order[0].title == wrappedeth, 6000)
    #     assert driver.waitFor(lambda: assets_order[1].title == stt, 6000)
    #     assert driver.waitFor(lambda: assets_order[2].title == dai, 6000)
    #     assert driver.waitFor(lambda: assets_order[3].title == eth, 6000)
