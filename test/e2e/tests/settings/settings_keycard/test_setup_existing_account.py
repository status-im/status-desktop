import time
from pathlib import Path

import allure
import pytest
from allure import step
from . import marks

import configs
import constants
import driver
from constants import ColorCodes
from constants.images_paths import PLUG_IN_KEYCARD_IMAGE_PATH, CHOOSE_KEYCARD_PIN_IMAGE_PATH, \
    KEYCARD_SUCCESS_IMAGE_PATH
from constants.keycard import Keycard
from gui.components.authenticate_popup import AuthenticatePopup
from gui.main_window import MainWindow
from gui.mocked_keycard_controller import MockedKeycardController

pytestmark = marks

@allure.testcase('https://ethstatus.testrail.net/index.php?/cases/view/703623',
                 'Setup a keycard with an existing account')
@pytest.mark.case(703623)
@pytest.mark.parametrize('user_account', [constants.user.user_account_one])
@pytest.mark.parametrize('account_name', [pytest.param('Status account')])
@pytest.mark.skip(reason="https://github.com/status-im/desktop-qa-automation/issues/274")
def test_setup_keycard_with_existing_account(main_screen: MainWindow, user_account, account_name):
    main_screen.prepare()

    with step('Choose option Setup keycard with existing account in settings'):
        keycard_settings = main_screen.left_panel.open_settings().left_panel.open_keycard_settings()
        keycard_popup = keycard_settings.click_setup_keycard_with_existing_account()

    with step('Verify displayed keycard popup instructions are correct'):
        with step('Verify header is correct'):
            assert keycard_popup.keycard_header == Keycard.KEYCARD_POPUP_HEADER_SET_UP_EXISTING.value, "The header is incorrect"
        with step('Verify instructions are correct'):
            assert Keycard.KEYCARD_SELECT_KEYPAIR.value in keycard_popup.keycard_instructions, \
                "There is no correct keycard instruction"
            assert Keycard.KEYCARD_SELECT_WHICH_PAIR.value in keycard_popup.keycard_instructions, \
                "There is no correct keycard instruction"

    with step(
            'Verify that profile keypair include correct keycard and account name, account color and info title are correct'):
        assert keycard_popup.keypair_name == user_account.name, "Keycard name in keypair is incorrect"
        assert keycard_popup.keypair_account_name == account_name, "Account name in keypair is incorrect"
        assert keycard_popup.keypair_account_color == ColorCodes.BLUE.value, "Account color in keypair is incorrect"
        assert keycard_popup.keypair_info_title == Keycard.KEYCARD_KEYPAIR_INFO.value, "Info in keypair is incorrect"

    with step('Verify selection box is present and not checked by default'):
        assert not keycard_popup.is_keypair_selection_box_checked

    with step('Click selection box on keypair and click continue'):
        keycard_popup.click_selection_box_on_keypair().click_next()

    with step(
            'Verify that profile keypair include correct keycard and account name, account color and info title are correct'):
        assert keycard_popup.keypair_name == user_account.name, "Keycard name in keypair is incorrect"
        assert keycard_popup.keypair_account_name == account_name, "Account name in keypair is incorrect"
        assert keycard_popup.keypair_account_color == ColorCodes.BLUE.value, "Account color in keypair is incorrect"
        assert keycard_popup.keypair_info_title == Keycard.KEYCARD_KEYPAIR_INFO.value, "Info in keypair is incorrect"

    with step('Verify displayed keycard popup instructions are correct'):
        assert Keycard.KEYCARD_INSTRUCTIONS_PLUG_IN.value in keycard_popup.keycard_instructions, \
            "There is no correct keycard instruction"

    with step('Keycard welcome image source path is correct'):
        assert PLUG_IN_KEYCARD_IMAGE_PATH == keycard_popup.keycard_image_source_path

    with step('Verify input seed phrase button is disabled'):
        assert not keycard_popup.is_next_button_enabled

    with step('Plug in reader'):
        main_screen.hide()
        keycard_controller = MockedKeycardController().wait_until_appears()
        keycard_controller.plugin_reader()
        main_screen.show()

    with step('Verify displayed keycard popup instructions are correct'):
        assert driver.waitFor(
            lambda: Keycard.KEYCARD_INSTRUCTIONS_INSERT_KEYCARD.value in keycard_popup.keycard_instructions,
            configs.timeouts.UI_LOAD_TIMEOUT_MSEC), "There is no correct keycard instruction"

    with step('Register and insert custom emtpy keycard with custom details'):
        main_screen.hide()
        first_details = '{}'
        second_details_path = configs.testpath.TEST_FILES / 'Keycard1_details.txt'
        second_details = Path(second_details_path).read_text()
        keycard_controller.choose_custom_keycard()
        keycard_controller.input_custom_keycard_details(first_details, 0)
        keycard_controller.input_custom_keycard_details(second_details, 1)
        keycard_controller.register_keycard()
        keycard_controller.insert_keycard_1()
        main_screen.show()

    with step('Verify displayed keycard popup instructions are correct'):
        with step('Verify keycard is recognized'):
            assert driver.waitFor(lambda: Keycard.KEYCARD_RECOGNIZED.value in keycard_popup.keycard_instructions,
                                  configs.timeouts.UI_LOAD_TIMEOUT_MSEC), "There is no correct keycard instruction"
        with step('Verify that asked to choose PIN'):
            assert driver.waitFor(lambda: Keycard.KEYCARD_CHOOSE_PIN.value in keycard_popup.keycard_instructions,
                                  configs.timeouts.UI_LOAD_TIMEOUT_MSEC), "There is no correct keycard instruction"
            assert Keycard.KEYCARD_PIN_NOTE.value in keycard_popup.keycard_instructions
            assert CHOOSE_KEYCARD_PIN_IMAGE_PATH == keycard_popup.keycard_image_source_path

    with step('Insert PIN and repeat PIN and verify keycard popup instructions are correct'):
        pin = Keycard.KEYCARD_PIN.value
        keycard_popup.input_pin_or_puk(pin)
        assert driver.waitFor(lambda: Keycard.KEYCARD_REPEAT_PIN.value in keycard_popup.keycard_instructions), \
            "There is no correct keycard instruction"
        keycard_popup.input_pin_or_puk(pin)
        assert driver.waitFor(lambda: Keycard.KEYCARD_PIN_SET.value in keycard_popup.keycard_instructions), \
            "There is no correct keycard instruction"

    with step('Create keycard account using new seed phrase'):
        keycard_popup.confirm_seed_phrase()
        authenticate_popup = AuthenticatePopup().wait_until_appears()
        authenticate_popup.authenticate(user_account.password)

    with step('Verify displayed keycard popup instructions are correct'):
        assert driver.waitFor(
            lambda: Keycard.KEYCARD_MIGRATING.value in keycard_popup.keycard_instructions,
            configs.timeouts.UI_LOAD_TIMEOUT_MSEC), "There is no correct keycard instruction"

    with step('Click on done and verify instructions are correct'):
        assert driver.waitFor(
            lambda: Keycard.KEYCARD_KEYPAIR_MIGRATED.value in keycard_popup.keycard_instructions,
            configs.timeouts.APP_LOAD_TIMEOUT_MSEC), "There is no correct keycard instruction"
        assert driver.waitFor(
            lambda: Keycard.KEYCARD_COMPLETE_MIGRATION.value in keycard_popup.keycard_instructions,
            configs.timeouts.UI_LOAD_TIMEOUT_MSEC), "There is no correct keycard instruction"
        with step('Keycard image source path is correct'):
            time.sleep(2)
            assert KEYCARD_SUCCESS_IMAGE_PATH == keycard_popup.keycard_image_source_path

        keycard_popup.click_next()
