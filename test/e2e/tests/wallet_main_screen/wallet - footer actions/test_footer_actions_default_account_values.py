import allure
import pytest
from allure_commons._allure import step

from configs import testpath
from gui.components.signing_phrase_popup import SigningPhrasePopup


@allure.testcase('https://ethstatus.testrail.net/index.php?/cases/edit/739265',
                 'Default account values in send, receive, bridge popups')
@pytest.mark.case(739265)
@pytest.mark.parametrize('default_name, address, name, color, emoji', [
    pytest.param('Account 1', '0xea123F7beFF45E3C9fdF54B324c29DBdA14a639A', 'AccWatch1', '#2a4af5', 'sunglasses')
])
@pytest.mark.skip(reason="https://github.com/status-im/status-desktop/issues/15995")
def test_wallet_modals_default_account_values(main_screen, default_name, address, name, color, emoji):
    with step('Add watched address with plus action button'):
        wallet = main_screen.left_panel.open_wallet()
        account_popup = wallet.left_panel.open_add_account_popup()
        account_popup.set_name(name).set_emoji(emoji).set_color(color).set_origin_watched_address(address).save_changes()
        account_popup.wait_until_hidden()

    with step('Change account order to have watched account first'):
        account_order = main_screen.left_panel.open_settings().left_panel.open_wallet_settings().open_account_order()
        account_order.drag_account(name, 0)

    with step('Open wallet and choose default account'):
        wallet = main_screen.left_panel.open_wallet()
        wallet_account = wallet.left_panel.select_account(default_name)

    with step('Verify that default account is chosen in send, receive and bridge popups opened from footer'):
        send_popup = wallet_account.open_send_popup().wait_until_appears()
        assert send_popup.get_text_from_account_selector() == default_name
        main_screen.left_panel.click()

        bridge_popup = wallet_account.open_bridge_popup().wait_until_appears()
        assert bridge_popup.get_text_from_account_selector() == default_name
        main_screen.left_panel.click()

        receive_popup = wallet_account.open_receive_popup().wait_until_appears()
        assert receive_popup.get_text_from_account_selector() == default_name
        main_screen.left_panel.click()

    with step('Verify that default account is chosen in send, receive and bridge popups opened from asset context menu'):
        wallet_account.open_asset_context_menu(0).click_send_item()
        assert send_popup.get_text_from_account_selector() == default_name
        main_screen.left_panel.click()

        wallet_account.open_asset_context_menu(0).click_receive_item()
        assert receive_popup.get_text_from_account_selector() == default_name
        main_screen.left_panel.click()

    with step('Choose watched account'):
        wallet_account = wallet.left_panel.select_account(name)

    with step('Verify that watched account is chosen in receive popup'):
        receive_popup = wallet_account.open_receive_popup().wait_until_appears()
        assert receive_popup.get_text_from_account_selector() == name
        main_screen.left_panel.click()

    with step('Verify that watched account is chosen in receive popup opened from asset context menu'):
        wallet_account.open_asset_context_menu(0).click_receive_item()
        assert receive_popup.get_text_from_account_selector() == name
        main_screen.left_panel.click()
