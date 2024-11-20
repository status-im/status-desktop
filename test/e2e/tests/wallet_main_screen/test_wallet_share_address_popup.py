import allure
import pyperclip
import pytest
from allure_commons._allure import step

from constants.wallet import WalletNetworkSettings
from tests.settings.settings_keycard import marks

from gui.components.signing_phrase_popup import SigningPhrasePopup
from gui.main_window import MainWindow

pytestmark = marks


@allure.testcase('https://ethstatus.testrail.net/index.php?/cases/view/738783','Share your address')
@pytest.mark.case(738783)
def test_share_wallet_address(main_screen: MainWindow):
    with step('Open wallet and choose default account'):
        default_name = WalletNetworkSettings.STATUS_ACCOUNT_DEFAULT_NAME.value
        wallet = main_screen.left_panel.open_wallet()
        wallet_account = wallet.left_panel.select_account(default_name)
        wallet.left_panel.copy_account_address_in_context_menu(default_name)
        wallet_address = pyperclip.paste()

    with step('Check QR code and address in Receive modal from footer'):
        receive_popup = wallet_account.open_receive_popup()
        assert receive_popup.qr_code.is_visible, f'QR code is not present in Receive modal'
        assert wallet_address == receive_popup.copy_address(), f'Addresses do not match'
