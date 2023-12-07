import time

import allure
import pytest
from allure import step
from . import marks

import configs
import driver
from constants import aut_options
from constants.images_paths import PLUG_IN_KEYCARD_IMAGE_PATH, INSERT_KEYCARD_IMAGE_PATH, CHOOSE_KEYCARD_PIN_IMAGE_PATH
from constants.keycard import Keycard
from gui.main_window import MainWindow
from gui.mocked_keycard_controller import MockedKeycardController

pytestmark = marks

@allure.testcase('https://ethstatus.testrail.net/index.php?/cases/view/703624',
                 'Create a new keycard account with a new seed phrase')
@pytest.mark.case(703624)
@pytest.mark.parametrize(
    'name, color, emoji_name, emoji, name1, color1, emoji1_name, emoji1, name2, color2, emoji2_name, emoji2',
    [
        pytest.param('Test Account', '#216266', 'sunglasses', '😎 ', 'Test Account2', '#2a4af5',
                     'thumbsup', '👍 ', 'Test Account3', '#ff7d46', 'cool', '🆒 ')
    ])
@pytest.mark.skip(reason="https://github.com/status-im/desktop-qa-automation/issues/274")
def test_create_keycard_account_with_new_seed_phrase(main_screen: MainWindow, name, color, emoji_name, emoji,
                                                     name1, color1, emoji1_name, emoji1, name2, color2, emoji2_name,
                                                     emoji2):
    with step('Choose option Create a new Keycard account with a new seed phrase in settings'):
        main_screen.prepare()
        keycard_settings = main_screen.left_panel.open_settings().left_panel.open_keycard_settings()
        keycard_popup = keycard_settings.click_create_new_account_with_new_seed_phrase()

    with step('Verify displayed keycard popup instructions are correct'):
        with step('Verify header is correct'):
            assert keycard_popup.keycard_header == Keycard.KEYCARD_POPUP_HEADER_CREATE_SEED.value, "The header is incorrect"
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

    with step('Verify displayed keycard popup instructions and image are correct'):
        with step('Verify keycard is recognized'):
            assert driver.waitFor(lambda: Keycard.KEYCARD_RECOGNIZED.value in keycard_popup.keycard_instructions,
                                  configs.timeouts.UI_LOAD_TIMEOUT_MSEC), "There is no correct keycard instruction"
        with step('Verify that asked to choose PIN'):
            assert driver.waitFor(lambda: Keycard.KEYCARD_CHOOSE_PIN.value in keycard_popup.keycard_instructions,
                                  configs.timeouts.UI_LOAD_TIMEOUT_MSEC), "There is no correct keycard instruction"
            assert Keycard.KEYCARD_PIN_NOTE.value in keycard_popup.keycard_instructions
        with step('Keycard image source path is correct'):
            assert CHOOSE_KEYCARD_PIN_IMAGE_PATH == keycard_popup.keycard_image_source_path

    with step('Enter and repeat PIN and verify keycard popup instructions are correct'):
        pin = Keycard.KEYCARD_PIN.value
        keycard_popup.input_pin_or_puk(pin)
        assert driver.waitFor(lambda: Keycard.KEYCARD_REPEAT_PIN.value in keycard_popup.keycard_instructions), \
            "There is no correct keycard instruction"
        keycard_popup.input_pin_or_puk(pin)
        assert driver.waitFor(lambda: Keycard.KEYCARD_PIN_SET.value in keycard_popup.keycard_instructions), \
            "There is no correct keycard instruction"

    with step('Create keycard and first keycard account using new seed phrase'):
        keycard_name = Keycard.KEYCARD_NAME.value
        keycard_popup.confirm_seed_phrase().name_keycard(keycard_name).name_account(name).set_color(color).set_emoji(
            emoji_name)

    with step('Verify keycard name and first account details on account tags are correct'):
        assert keycard_name == keycard_popup.keypair_name
        assert keycard_popup.account_tags[0].name == name
        assert keycard_popup.account_tags[0].icon_color == color
        assert keycard_popup.account_tags[0].icon_emoji == emoji

    with step('Add second keycard account'):
        keycard_popup.add_account().name_account(name1).set_emoji(emoji1_name).set_color(color1)

    with step('Verify second account details on account tags are correct'):
        assert keycard_popup.account_tags[1].name == name1
        assert keycard_popup.account_tags[1].icon_color == color1
        assert keycard_popup.account_tags[1].icon_emoji == emoji1

    with step('Add third keycard account'):
        keycard_popup.add_account().name_account(name2).set_emoji(emoji2_name).set_color(color2)

    with step('Verify third account details on account tags are correct'):
        assert keycard_popup.account_tags[2].name == name2
        assert keycard_popup.account_tags[2].icon_color == color2
        assert keycard_popup.account_tags[2].icon_emoji == emoji2

    with step('Finalise keycard'):
        keycard_popup.click_next()

    with step('Verify that keycard instructions are correct'):
        assert driver.waitFor(lambda: Keycard.KEYCARD_NEW_ACCOUNT_CREATED.value in keycard_popup.keycard_instructions), \
            "There is no correct keycard instruction"

    with step('Go to wallet settings and verify accounts and account details are correct'):
        account_order = main_screen.left_panel.open_settings().left_panel.open_wallet_settings().open_account_order()
        with step('First account details are correct'):
            assert account_order.accounts[1].name == name
            assert account_order.accounts[1].icon_color == color
            assert account_order.accounts[1].icon_emoji == emoji
        with step('Second account details are correct'):
            assert account_order.accounts[2].name == name1
            assert account_order.accounts[2].icon_color == color1
            assert account_order.accounts[2].icon_emoji == emoji1
        with step('Third account details are correct'):
            assert account_order.accounts[3].name == name2
            assert account_order.accounts[3].icon_color == color2
            assert account_order.accounts[3].icon_emoji == emoji2

