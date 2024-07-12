import time

import allure
import pytest
from allure import step
from . import marks

import configs
import constants
import driver
from constants import aut_options
from constants.images_paths import PLUG_IN_KEYCARD_IMAGE_PATH, INSERT_KEYCARD_IMAGE_PATH, EMPTY_KEYCARD_IMAGE_PATH, \
    KEYCARD_SUCCESS_IMAGE_PATH, KEYCARD_INSERTED_IMAGE_PATH
from constants.keycard import Keycard
from gui.main_window import MainWindow
from gui.mocked_keycard_controller import MockedKeycardController

pytestmark = marks

@allure.testcase('https://ethstatus.testrail.net/index.php?/cases/view/703627', 'Check whats on a Keycard')
@pytest.mark.case(703627)
@pytest.mark.parametrize('user_account', [constants.user.user_account_one])
# @pytest.mark.skip(reason="https://github.com/status-im/desktop-qa-automation/issues/274")
def test_check_whats_on_keycard(main_screen: MainWindow, user_account):
    main_screen.prepare()

    with step('Choose option Check whats on keycard in settings'):
        keycard_settings = main_screen.left_panel.open_settings().left_panel.open_keycard_settings()
        keycard_popup = keycard_settings.click_check_whats_on_keycard()

    with step('Verify displayed keycard popup instructions are correct'):
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

    with step('Register and insert not status keycard'):
        main_screen.hide()
        keycard_controller.choose_not_status_keycard()
        keycard_controller.register_keycard()
        keycard_controller.insert_keycard_1()
        main_screen.show()

    with step('Verify keycard is not recognized'):
        assert driver.waitFor(lambda: Keycard.KEYCARD_NOT.value in keycard_popup.keycard_instructions,
                              configs.timeouts.UI_LOAD_TIMEOUT_MSEC), "There is no correct keycard instruction"
        assert driver.waitFor(lambda: Keycard.KEYCARD_NOT_RECOGNIZED_NOTE.value in keycard_popup.keycard_instructions,
                              configs.timeouts.UI_LOAD_TIMEOUT_MSEC), f"There is no correct keycard instruction {keycard_popup.keycard_instructions}"

    with step('Close keycard popup'):
        keycard_popup.cancel()

    with step('Insert empty keycard'):
        main_screen.hide()
        keycard_controller.choose_empty_keycard()
        keycard_controller.register_keycard()
        keycard_controller.insert_keycard_1()
        main_screen.show()

    with step('Check what is on keycard'):
        keycard_popup = keycard_settings.click_check_whats_on_keycard()

    with step('Verify keycard is empty'):
        assert driver.waitFor(lambda: Keycard.KEYCARD_EMPTY.value in keycard_popup.keycard_instructions,
                              configs.timeouts.UI_LOAD_TIMEOUT_MSEC), "There is no correct keycard instruction"
        assert driver.waitFor(lambda: Keycard.KEYCARD_NO_KEYPAIR.value in keycard_popup.keycard_instructions,
                              configs.timeouts.UI_LOAD_TIMEOUT_MSEC), "There is no correct keycard instruction"

    with step('Keycard image source path is correct'):
        assert EMPTY_KEYCARD_IMAGE_PATH == keycard_popup.keycard_image_source_path

    with step('Close keycard popup'):
        keycard_popup.click_next()

    with step('Insert locked keycard'):
        main_screen.hide()
        keycard_controller.choose_max_slots_reached_keycard()
        keycard_controller.register_keycard()
        keycard_controller.insert_keycard_1()
        main_screen.show()

    with step('Check what is on keycard'):
        keycard_popup = keycard_settings.click_check_whats_on_keycard()

    with step('Verify keycard is locked'):
        assert driver.waitFor(lambda: Keycard.KEYCARD_LOCKED.value in keycard_popup.keycard_instructions,
                              configs.timeouts.UI_LOAD_TIMEOUT_MSEC), "There is no correct keycard instruction"
        assert driver.waitFor(lambda: Keycard.KEYCARD_LOCKED_NOTE.value in keycard_popup.keycard_instructions,
                              configs.timeouts.UI_LOAD_TIMEOUT_MSEC), "There is no correct keycard instruction"

    with step('Close keycard popup'):
        keycard_popup.cancel()

    with step('Remove keycard and insert keycard with accounts on it'):
        main_screen.hide()
        keycard_controller.remove_keycard()
        keycard_controller.choose_mnemonic_metadata_keycard()
        keycard_controller.register_keycard()
        keycard_controller.insert_keycard_1()
        main_screen.show()

    with step('Check what is on keycard'):
        keycard_popup = keycard_settings.click_check_whats_on_keycard()

    with step('Insert PIN and repeat PIN and verify keycard popup instructions are correct'):
        with step('Verify that asked to choose PIN'):
            assert driver.waitFor(lambda: Keycard.KEYCARD_ENTER_PIN.value in keycard_popup.keycard_instructions,
                                  configs.timeouts.UI_LOAD_TIMEOUT_MSEC), "There is no correct keycard instruction"
        pin = Keycard.KEYCARD_PIN.value
        keycard_name = 'Card-1 Name'
        keycard_popup.input_pin_or_puk(pin)
        assert driver.waitFor(lambda: Keycard.KEYCARD_PIN_VERIFIED.value in keycard_popup.keycard_instructions), \
            "There is no correct keycard instruction"

    with step('Keycard image source path is correct'):
        time.sleep(2)
        assert KEYCARD_SUCCESS_IMAGE_PATH == keycard_popup.keycard_image_source_path

    with step('Close keycard popup'):
        keycard_popup.click_next()

    with step('Keycard image source path is correct'):
        assert KEYCARD_INSERTED_IMAGE_PATH == keycard_popup.keycard_image_source_path

    with step('Verify that preview shows correct keycard and instructions are correct'):
        assert driver.waitFor(lambda: Keycard.KEYCARD_ACCOUNTS.value in keycard_popup.keycard_instructions), \
            "There is no correct keycard instruction"

        assert keycard_popup.keypair_on_keycard_name == keycard_name, "Keycard name in preview is incorrect"

    with step('Close keycard popup'):
        keycard_popup.click_next()
