import time

import allure
import pytest
from allure import step
from . import marks

import configs
import constants
import driver
from constants import ColorCodes, aut_options
from constants.images_paths import PLUG_IN_KEYCARD_IMAGE_PATH, INSERT_KEYCARD_IMAGE_PATH, KEYCARD_SUCCESS_IMAGE_PATH
from constants.keycard import Keycard
from gui.main_window import MainWindow
from gui.mocked_keycard_controller import MockedKeycardController

pytestmark = marks

@allure.testcase('https://ethstatus.testrail.net/index.php?/cases/view/703625',
                 'Import or restore a Keycard via a seed phrase')
@pytest.mark.case(703625)
@pytest.mark.parametrize('user_account', [constants.user.user_account_one])
@pytest.mark.skip(reason="https://github.com/status-im/desktop-qa-automation/issues/274")
def test_import_restore_keycard_via_seed_phrase(main_screen: MainWindow, user_account):
    with step('Choose option Import or restore account via seed phrase in settings'):
        main_screen.prepare()
        keycard_settings = main_screen.left_panel.open_settings().left_panel.open_keycard_settings()
        keycard_popup = keycard_settings.click_import_restore_via_seed_phrase()

    with (step('Verify displayed keycard popup instructions are correct')):
        with step('Verify header is correct'):
            assert keycard_popup.keycard_header == Keycard.KEYCARD_POPUP_HEADER_IMPORT_SEED.value, "The header is incorrect"
        with step('Verify instructions are correct'):
            assert Keycard.KEYCARD_INSTRUCTIONS_PLUG_IN.value in keycard_popup.keycard_instructions, \
                "There is no correct keycard instruction"
        with step('Keycard welcome image source path is correct'):
            assert PLUG_IN_KEYCARD_IMAGE_PATH == keycard_popup.keycard_image_source_path

    with step('Plug in reader'):
        main_screen.hide()
        keycard_controller = MockedKeycardController().wait_until_appears()
        keycard_controller.plugin_reader()
        main_screen.show()

    with step('Verify displayed keycard popup instructions are correct'):
        assert driver.waitFor(
            lambda: Keycard.KEYCARD_INSTRUCTIONS_INSERT_KEYCARD.value in keycard_popup.keycard_instructions,
            configs.timeouts.UI_LOAD_TIMEOUT_MSEC), "There is no correct keycard instruction"

    with step('Keycard image source path is correct'):
        time.sleep(2)
        assert INSERT_KEYCARD_IMAGE_PATH == keycard_popup.keycard_image_source_path

    with step('Register and insert keycard'):
        main_screen.hide()
        keycard_controller.register_keycard()
        keycard_controller.insert_keycard_1()
        main_screen.show()

    with step('Verify displayed keycard popup instructions are correct'):
        with step('Verify keycard is recognized'):
            assert driver.waitFor(lambda: Keycard.KEYCARD_RECOGNIZED.value in keycard_popup.keycard_instructions,
                                  configs.timeouts.UI_LOAD_TIMEOUT_MSEC), "There is no correct keycard instruction"

    with step('Import keycard via seed phrase'):
        pin = Keycard.KEYCARD_PIN.value
        keycard_name = Keycard.KEYCARD_NAME.value
        account_name = Keycard.ACCOUNT_NAME.value
        keycard_popup.import_keycard_via_seed_phrase(user_account.seed_phrase, pin, keycard_name, account_name)

    with step('Verify that preview shows correct keycard and account name and color and instructions are correct'):
        assert driver.waitFor(lambda: Keycard.KEYCARD_READY.value in keycard_popup.keycard_instructions), \
            "There is no correct keycard instruction"

        assert keycard_popup.keypair_name == keycard_name, "Keycard name in preview is incorrect"
        assert keycard_popup.keypair_account_name == account_name, "Account name in preview is incorrect"
        assert keycard_popup.keypair_account_color == ColorCodes.BLUE.value, "Color in preview is incorrect"

    with step('Keycard image source path is correct'):
        time.sleep(2)
        assert KEYCARD_SUCCESS_IMAGE_PATH == keycard_popup.keycard_image_source_path

    keycard_popup.click_next()
