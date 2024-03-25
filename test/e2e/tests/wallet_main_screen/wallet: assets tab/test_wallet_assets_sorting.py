import allure
import pytest
from allure_commons._allure import step

import driver
from gui.screens.wallet import WalletAccountView
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
@pytest.mark.parametrize('address, name, dai, weenus, stt, eth', [
    pytest.param('0xFf58d746A67C2E42bCC07d6B3F58406E8837E883', 'AssetsCollectibles', 'Dai Stablecoin', 'WEENUS Token',
                 'Status Test Token', 'Ether')
])
def test_wallet_sort_assets(main_screen: MainWindow, address, name, dai, weenus, stt, eth):
    with step('Turn on Testnet mode'):
        networks = main_screen.left_panel.open_settings().left_panel.open_wallet_settings().open_networks()
        networks.switch_testnet_mode_toggle().turn_on_testnet_mode_in_testnet_modal()

    with step('Add watched address with plus action button'):
        wallet = main_screen.left_panel.open_wallet()
        SigningPhrasePopup().wait_until_appears().confirm_phrase()
        account_popup = wallet.left_panel.open_add_account_popup()
        account_popup.set_name(name).set_origin_watched_address(address).save()
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
        assert driver.waitFor(lambda: assets_order[1].title == weenus, 6000)
        assert driver.waitFor(lambda: assets_order[2].title == stt, 6000)
        assert driver.waitFor(lambda: assets_order[3].title == eth, 6000)

        wallet_account_view.click_arrow_button('arrow-down-icon', 1)
        assert wallet_account_view.get_combobox_value() == 'Asset balance value ↓'
        assets_order = wallet_account_view.get_list_of_assets()
        assert driver.waitFor(lambda: assets_order[0].title == eth, 6000)
        assert driver.waitFor(lambda: assets_order[1].title == dai, 6000)
        assert driver.waitFor(lambda: assets_order[2].title == weenus, 6000)
        assert driver.waitFor(lambda: assets_order[3].title == stt, 6000)

    with step('Sort assets by asset balance and verify the value in combobox is correct and the order is correct'):
        sorting.choose_sort_by_value('Asset balance')
        wallet_account_view.click_arrow_button('arrow-up-icon', 2)
        assert wallet_account_view.get_combobox_value() == 'Asset balance ↑'
        assets_order = wallet_account_view.get_list_of_assets()
        assert driver.waitFor(lambda: assets_order[0].title == dai, 6000)
        assert driver.waitFor(lambda: assets_order[1].title == stt, 6000)
        assert driver.waitFor(lambda: assets_order[2].title == weenus, 6000)
        assert driver.waitFor(lambda: assets_order[3].title == eth, 6000)

        wallet_account_view.click_arrow_button('arrow-down-icon', 2)
        assert wallet_account_view.get_combobox_value() == 'Asset balance ↓'
        assets_order = wallet_account_view.get_list_of_assets()
        assert driver.waitFor(lambda: assets_order[0].title == eth, 6000)
        assert driver.waitFor(lambda: assets_order[1].title == weenus, 6000)
        assert driver.waitFor(lambda: assets_order[2].title == dai, 6000)
        assert driver.waitFor(lambda: assets_order[3].title == stt, 6000)

    with step('Sort assets by asset value and verify the value in combobox is correct and the order is correct'):
        sorting.choose_sort_by_value('Asset value')
        wallet_account_view.click_arrow_button('arrow-up-icon', 3)
        assert wallet_account_view.get_combobox_value() == 'Asset value ↑'
        assets_order = wallet_account_view.get_list_of_assets()
        assert driver.waitFor(lambda: assets_order[0].title == weenus, 6000)
        assert driver.waitFor(lambda: assets_order[1].title == stt, 6000)
        assert driver.waitFor(lambda: assets_order[2].title == dai, 6000)
        assert driver.waitFor(lambda: assets_order[3].title == eth, 6000)

        wallet_account_view.click_arrow_button('arrow-down-icon', 3)
        assert wallet_account_view.get_combobox_value() == 'Asset value ↓'
        assets_order = wallet_account_view.get_list_of_assets()
        assert driver.waitFor(lambda: assets_order[0].title == eth, 6000)
        assert driver.waitFor(lambda: assets_order[1].title == dai, 6000)
        assert driver.waitFor(lambda: assets_order[2].title == stt, 6000)
        assert driver.waitFor(lambda: assets_order[3].title == weenus, 6000)

    with step(
            'Sort assets by 1d change: balance value and verify the value in combobox is correct and the order is correct'):
        sorting.choose_sort_by_value('1d change: balance value')
        wallet_account_view.click_arrow_button('arrow-up-icon', 4)
        assert wallet_account_view.get_combobox_value() == '1d change: balance value ↑'
        assets_order = wallet_account_view.get_list_of_assets()
        assert driver.waitFor(lambda: assets_order[0].title == dai, 6000)
        assert driver.waitFor(lambda: assets_order[1].title == weenus, 6000)
        assert driver.waitFor(lambda: assets_order[2].title == stt, 6000)
        assert driver.waitFor(lambda: assets_order[3].title == eth, 6000)

        wallet_account_view.click_arrow_button('arrow-down-icon', 4)
        assert wallet_account_view.get_combobox_value() == '1d change: balance value ↓'
        assets_order = wallet_account_view.get_list_of_assets()
        assert driver.waitFor(lambda: assets_order[0].title == eth, 6000)
        assert driver.waitFor(lambda: assets_order[1].title == dai, 6000)
        assert driver.waitFor(lambda: assets_order[2].title == weenus, 6000)
        assert driver.waitFor(lambda: assets_order[3].title == stt, 6000)

    with step('Sort assets by asset name and verify the value in combobox is correct and the order is correct'):
        sorting.choose_sort_by_value('Asset name')
        wallet_account_view.click_arrow_button('arrow-up-icon', 5)
        assert wallet_account_view.get_combobox_value() == 'Asset name ↑'
        assets_order = wallet_account_view.get_list_of_assets()
        assert driver.waitFor(lambda: assets_order[0].title == dai, 6000)
        assert driver.waitFor(lambda: assets_order[1].title == eth, 6000)
        assert driver.waitFor(lambda: assets_order[2].title == stt, 6000)
        assert driver.waitFor(lambda: assets_order[3].title == weenus, 6000)

        wallet_account_view.click_arrow_button('arrow-down-icon', 5)
        assert wallet_account_view.get_combobox_value() == 'Asset name ↓'
        assets_order = wallet_account_view.get_list_of_assets()
        assert driver.waitFor(lambda: assets_order[0].title == weenus, 6000)
        assert driver.waitFor(lambda: assets_order[1].title == stt, 6000)
        assert driver.waitFor(lambda: assets_order[2].title == eth, 6000)
        assert driver.waitFor(lambda: assets_order[3].title == dai, 6000)
