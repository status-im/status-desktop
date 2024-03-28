import time

import allure
import pytest
from allure import step
from . import marks

import configs
import constants
import driver
from constants.keycard import Keycard
from gui.main_window import MainWindow
from gui.mocked_keycard_controller import MockedKeycardController

pytestmark = marks

@allure.testcase('https://ethstatus.testrail.net/index.php?/cases/view/704607', 'Unlock Keycard')
@pytest.mark.case(704607)
@pytest.mark.parametrize('user_account', [constants.user.user_with_random_attributes_1])
@pytest.mark.skip(reason="https://github.com/status-im/desktop-qa-automation/issues/274")
def test_unlock_keycard_using_correct_puk(main_screen: MainWindow, user_account):
    main_screen.prepare()

    with step('Plug in reader'):
        main_screen.hide()
        keycard_controller = MockedKeycardController().wait_until_appears()
        keycard_controller.plugin_reader()
        keycard_controller.choose_mnemonic_metadata_keycard()
        keycard_controller.register_keycard()
        keycard_controller.insert_keycard_1()
        main_screen.show()

    with step('Choose option Check whats on keycard in settings'):
        keycard_settings = main_screen.left_panel.open_settings().left_panel.open_keycard_settings()
        keycard_popup = keycard_settings.click_check_whats_on_keycard()

    with step('Enter incorrect PIN 3 times and verify keycard popup instructions are correct'):
        assert driver.waitFor(lambda: Keycard.KEYCARD_ENTER_PIN.value in keycard_popup.keycard_instructions,
                              configs.timeouts.UI_LOAD_TIMEOUT_MSEC), "There is no correct keycard instruction"
        incorrect_pin = Keycard.KEYCARD_INCORRECT_PIN.value
        keycard_popup.input_pin_or_puk(incorrect_pin)
        time.sleep(1)
        keycard_popup.input_pin_or_puk(incorrect_pin)
        time.sleep(1)
        keycard_popup.input_pin_or_puk(incorrect_pin)
        time.sleep(1)

        assert driver.waitFor(
            lambda: Keycard.KEYCARD_LOCKED.value in keycard_popup.keycard_instructions), \
            f"There is no correct keycard instruction {keycard_popup.keycard_instructions}"
        assert driver.waitFor(
            lambda: Keycard.KEYCARD_LOCKED_INCORRECT_PIN.value in keycard_popup.keycard_instructions), \
            "There is no correct keycard instruction"

    with step('Click Unlock keycard button'):
        keycard_popup.click_next()

    with step('Verify keycard popup instructions are correct'):
        assert driver.waitFor(
            lambda: Keycard.KEYCARD_UNLOCK.value in keycard_popup.keycard_instructions), \
            f"There is no correct keycard instruction {keycard_popup.keycard_instructions}"

    with step('Click Unlock using PUK and enter incorrect PUK'):
        keycard_popup.click_unlock_puk()
        correct_puk = Keycard.KEYCARD_CORRECT_PUK.value
        keycard_popup.input_pin_or_puk(correct_puk)
        time.sleep(1)
        keycard_popup.click_next()

    with step('Verify that asked to choose PIN'):
        assert driver.waitFor(lambda: Keycard.KEYCARD_CHOOSE_PIN.value in keycard_popup.keycard_instructions,
                              configs.timeouts.UI_LOAD_TIMEOUT_MSEC), "There is no correct keycard instruction"
        assert Keycard.KEYCARD_PIN_NOTE.value in keycard_popup.keycard_instructions

    with step('Enter PIN and repeat PIN and verify keycard popup instructions are correct'):
        pin = Keycard.KEYCARD_PIN.value
        keycard_popup.input_pin_or_puk(pin)
        assert driver.waitFor(lambda: Keycard.KEYCARD_REPEAT_PIN.value in keycard_popup.keycard_instructions), \
            "There is no correct keycard instruction"
        keycard_popup.input_pin_or_puk(pin)
        assert driver.waitFor(lambda: Keycard.KEYCARD_PIN_SET.value in keycard_popup.keycard_instructions), \
            "There is no correct keycard instruction"
        keycard_popup.click_next()

    with step('Verify keycard popup instructions are correct'):
        assert driver.waitFor(
            lambda: Keycard.KEYCARD_UNLOCK_SUCCESSFUL.value in keycard_popup.keycard_instructions), \
            f"There is no correct keycard instruction {keycard_popup.keycard_instructions}"


@allure.testcase('https://ethstatus.testrail.net/index.php?/cases/view/704608', 'Unlock Keycard: incorrect PUK')
@pytest.mark.case(704608)
@pytest.mark.parametrize('user_account', [constants.user.user_with_random_attributes_1])
@pytest.mark.skip(reason="https://github.com/status-im/desktop-qa-automation/issues/274")
def test_unlock_keycard_using_incorrect_puk(main_screen: MainWindow, user_account):
    main_screen.prepare()

    with step('Plug in reader'):
        main_screen.hide()
        keycard_controller = MockedKeycardController().wait_until_appears()
        keycard_controller.plugin_reader()
        keycard_controller.choose_mnemonic_metadata_keycard()
        keycard_controller.register_keycard()
        keycard_controller.insert_keycard_1()
        main_screen.show()

    with step('Choose option Check whats on keycard in settings'):
        keycard_settings = main_screen.left_panel.open_settings().left_panel.open_keycard_settings()
        keycard_popup = keycard_settings.click_check_whats_on_keycard()

    with step('Enter incorrect PIN 3 times and verify keycard popup instructions are correct'):
        assert driver.waitFor(lambda: Keycard.KEYCARD_ENTER_PIN.value in keycard_popup.keycard_instructions,
                              configs.timeouts.UI_LOAD_TIMEOUT_MSEC), "There is no correct keycard instruction"
        incorrect_pin = Keycard.KEYCARD_INCORRECT_PIN.value
        keycard_popup.input_pin_or_puk(incorrect_pin)
        time.sleep(1)
        keycard_popup.input_pin_or_puk(incorrect_pin)
        time.sleep(1)
        keycard_popup.input_pin_or_puk(incorrect_pin)
        time.sleep(1)

        assert driver.waitFor(
            lambda: Keycard.KEYCARD_LOCKED.value in keycard_popup.keycard_instructions), \
            f"There is no correct keycard instruction {keycard_popup.keycard_instructions}"
        assert driver.waitFor(
            lambda: Keycard.KEYCARD_LOCKED_INCORRECT_PIN.value in keycard_popup.keycard_instructions), \
            "There is no correct keycard instruction"

    with step('Click Unlock keycard button'):
        keycard_popup.click_next()

    with step('Verify keycard popup instructions are correct'):
        assert driver.waitFor(
            lambda: Keycard.KEYCARD_UNLOCK.value in keycard_popup.keycard_instructions), \
            f"There is no correct keycard instruction {keycard_popup.keycard_instructions}"

    with step('Click Unlock using PUK and enter incorrect PUK'):
        keycard_popup.click_unlock_puk()
        incorrect_puk = Keycard.KEYCARD_INCORRECT_PUK.value
        keycard_popup.input_pin_or_puk(incorrect_puk)
        time.sleep(1)
        keycard_popup.click_next()

    with step('Verify that asked to choose PIN'):
        assert driver.waitFor(lambda: Keycard.KEYCARD_CHOOSE_PIN.value in keycard_popup.keycard_instructions,
                              configs.timeouts.UI_LOAD_TIMEOUT_MSEC), "There is no correct keycard instruction"
        assert Keycard.KEYCARD_PIN_NOTE.value in keycard_popup.keycard_instructions

    with step('Enter PIN and repeat PIN and verify keycard popup instructions are correct'):
        pin = Keycard.KEYCARD_PIN.value
        keycard_popup.input_pin_or_puk(pin)
        assert driver.waitFor(lambda: Keycard.KEYCARD_REPEAT_PIN.value in keycard_popup.keycard_instructions), \
            "There is no correct keycard instruction"
        keycard_popup.input_pin_or_puk(pin)
        assert driver.waitFor(lambda: Keycard.KEYCARD_PIN_SET.value in keycard_popup.keycard_instructions), \
            "There is no correct keycard instruction"
        keycard_popup.click_next()

    with step('Verify keycard popup instructions are correct'):
        assert driver.waitFor(
            lambda: Keycard.KEYCARD_PUK_IS_INCORRECT.value in keycard_popup.keycard_instructions), \
            f"There is no correct keycard instruction {keycard_popup.keycard_instructions}"
        assert driver.waitFor(
            lambda: Keycard.KEYCARD_4_ATTEMPTS_REMAINING.value in keycard_popup.keycard_instructions), \
            f"There is no correct keycard instruction {keycard_popup.keycard_instructions}"

    with step('Enter incorrect PUK again'):
        incorrect_puk = Keycard.KEYCARD_INCORRECT_PUK.value
        keycard_popup.input_pin_or_puk(incorrect_puk)
        time.sleep(1)
        keycard_popup.click_next()

    with step('Verify keycard popup instructions are correct'):
        assert driver.waitFor(
            lambda: Keycard.KEYCARD_PUK_IS_INCORRECT.value in keycard_popup.keycard_instructions), \
            f"There is no correct keycard instruction {keycard_popup.keycard_instructions}"
        assert driver.waitFor(
            lambda: Keycard.KEYCARD_3_ATTEMPTS_REMAINING.value in keycard_popup.keycard_instructions), \
            f"There is no correct keycard instruction {keycard_popup.keycard_instructions}"

    with step('Enter incorrect PUK again'):
        incorrect_puk = Keycard.KEYCARD_INCORRECT_PUK.value
        keycard_popup.input_pin_or_puk(incorrect_puk)
        time.sleep(1)
        keycard_popup.click_next()

    with step('Verify keycard popup instructions are correct'):
        assert driver.waitFor(
            lambda: Keycard.KEYCARD_PUK_IS_INCORRECT.value in keycard_popup.keycard_instructions), \
            f"There is no correct keycard instruction {keycard_popup.keycard_instructions}"
        assert driver.waitFor(
            lambda: Keycard.KEYCARD_2_ATTEMPTS_REMAINING.value in keycard_popup.keycard_instructions), \
            f"There is no correct keycard instruction {keycard_popup.keycard_instructions}"

    with step('Enter incorrect PUK again'):
        incorrect_puk = Keycard.KEYCARD_INCORRECT_PUK.value
        keycard_popup.input_pin_or_puk(incorrect_puk)
        time.sleep(1)
        keycard_popup.click_next()

    with step('Verify keycard popup instructions are correct'):
        assert driver.waitFor(
            lambda: Keycard.KEYCARD_PUK_IS_INCORRECT.value in keycard_popup.keycard_instructions), \
            f"There is no correct keycard instruction {keycard_popup.keycard_instructions}"
        assert driver.waitFor(
            lambda: Keycard.KEYCARD_1_ATTEMPT_REMAINING.value in keycard_popup.keycard_instructions), \
            f"There is no correct keycard instruction {keycard_popup.keycard_instructions}"

    with step('Enter incorrect PUK again'):
        incorrect_puk = Keycard.KEYCARD_INCORRECT_PUK.value
        keycard_popup.input_pin_or_puk(incorrect_puk)
        time.sleep(1)
        keycard_popup.click_next()

    with step('Verify keycard is locked and it says that PUK entered incorrectly'):
        assert driver.waitFor(
            lambda: Keycard.KEYCARD_LOCKED.value in keycard_popup.keycard_instructions), \
            f"There is no correct keycard instruction {keycard_popup.keycard_instructions}"
        assert driver.waitFor(
            lambda: Keycard.KEYCARD_LOCKED_INCORRECT_PUK.value in keycard_popup.keycard_instructions), \
            "There is no correct keycard instruction"
