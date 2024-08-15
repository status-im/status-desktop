import allure
import pytest
from allure_commons._allure import step
from tests.settings.settings_keycard import marks

from gui.components.signing_phrase_popup import SigningPhrasePopup
from gui.main_window import MainWindow

pytestmark = marks


@allure.testcase('https://ethstatus.testrail.net/index.php?/cases/view/738783','Share your address')
@pytest.mark.case(738783)
def test_share_wallet_address(main_screen: MainWindow):
    with step('Open wallet and choose default account'):
        default_name = 'Account 1'
        wallet = main_screen.left_panel.open_wallet()
        SigningPhrasePopup().wait_until_appears().confirm_phrase()
        wallet_account = wallet.left_panel.select_account(default_name)

    with step('Open receive popup from footer and verify all network icons and qr code are visible'):
        receive_popup = wallet_account.open_receive_popup().wait_until_appears()
        assert receive_popup.eth_icon.exists
        assert receive_popup.oeth_icon.exists
        assert receive_popup.arb_icon.exists
        assert receive_popup.qr_code.is_visible

    with step('Copy address and verify it has correct format'):
        assert receive_popup.copy_address().startswith('eth:oeth:arb1:')

    with step('Uncheck Mainnet network and verify it has correct format'):
        receive_popup.edit_networks().mainnet_network_checkbox.set(False)
        receive_popup.qr_code.click()
        assert receive_popup.copy_address().startswith('oeth:arb1:')

    with step('Uncheck Optimism network and verify it has correct format'):
        receive_popup.edit_networks().optimism_network_checkbox.set(False)
        receive_popup.qr_code.click()
        assert receive_popup.copy_address().startswith('arb1:')

    with step('Open Legacy tab, copy address and verify it has correct format and qr code is visible'):
        receive_popup.legacy_tab_button.click()
        assert receive_popup.copy_address().startswith('0x')
        assert receive_popup.qr_code.is_visible
