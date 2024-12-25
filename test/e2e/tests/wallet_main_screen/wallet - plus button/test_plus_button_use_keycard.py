import allure
import pytest
from allure_commons._allure import step

from gui.main_window import MainWindow
from gui.screens.settings_keycard import KeycardSettingsView


@allure.testcase('https://ethstatus.testrail.net/index.php?/cases/view/703514',
                 'Choosing Use Keycard when adding account')
@pytest.mark.case(703514)
def test_use_keycard_when_adding_account(main_screen: MainWindow):
    with step('Choose continue in keycard settings'):
        wallet = main_screen.left_panel.open_wallet()
        account_popup = wallet.left_panel.open_add_account_popup()
        account_popup.continue_in_keycard_settings()

    with (step('Verify that keycard settings view opened and all keycard settings available')):
        keycard_view = KeycardSettingsView()
        keycard_view.check_keycard_screen_loaded()
        keycard_view.all_keycard_options_available()
