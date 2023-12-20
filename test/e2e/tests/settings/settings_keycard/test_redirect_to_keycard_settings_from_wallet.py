import allure
import pytest
from allure_commons._allure import step
from . import marks

from gui.components.signing_phrase_popup import SigningPhrasePopup
from gui.main_window import MainWindow
from gui.screens.settings_keycard import KeycardSettingsView

pytestmark = marks

@allure.testcase('https://ethstatus.testrail.net/index.php?/cases/view/703514',
                 'Choosing Use Keycard when adding account')
@pytest.mark.case(703514)
@pytest.mark.xfail(reason="https://github.com/status-im/status-desktop/issues/12914")
def test_use_keycard_when_adding_account(main_screen: MainWindow):
    with step('Choose continue in keycard settings'):
        wallet = main_screen.left_panel.open_wallet()
        SigningPhrasePopup().wait_until_appears().confirm_phrase()
        account_popup = wallet.left_panel.open_add_account_popup()
        account_popup.continue_in_keycard_settings()
        account_popup.wait_until_hidden()

    with (step('Verify that keycard settings view opened and all keycard settings available')):
        keycard_view = KeycardSettingsView()
        keycard_view.check_keycard_screen_loaded()
        keycard_view.all_keycard_options_available()
