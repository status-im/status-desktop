import allure
import pytest
from allure_commons._allure import step

from constants.onboarding import KeysExistText
from constants.wallet import WalletNetworkSettings
from driver.aut import AUT
from helpers.OnboardingHelper import open_generate_new_keys_view, open_import_seed_view_and_do_import, \
    finalize_onboarding_and_login
from scripts.utils.generators import random_mnemonic, get_wallet_address_from_mnemonic

from gui.main_window import LeftPanel
from gui.screens.onboarding import LoginView



@allure.testcase('https://ethstatus.testrail.net/index.php?/cases/view/703040', 'Import: 12 word seed phrase')
@allure.testcase('https://ethstatus.testrail.net/index.php?/cases/view/736372', 'Re-importing seed-phrase')
@pytest.mark.case(703040, 736372, 738726)
@pytest.mark.critical
@pytest.mark.smoke
def test_import_and_reimport_random_seed(main_window, aut: AUT, user_account):

    keys_screen = open_generate_new_keys_view()
    seed_phrase = random_mnemonic()
    profile_view = open_import_seed_view_and_do_import(keys_screen, seed_phrase, user_account)
    finalize_onboarding_and_login(profile_view, user_account)

    with (step('Verify that restored account reveals correct status wallet address')):
        status_account_index = 0
        status_acc_view = (
            LeftPanel().open_settings().left_panel.open_wallet_settings().open_account_in_settings(WalletNetworkSettings.STATUS_ACCOUNT_DEFAULT_NAME.value,
                                                                                                   status_account_index))
        address = status_acc_view.get_account_address_value()
        address_from_seed = get_wallet_address_from_mnemonic(seed_phrase)
        assert address == address_from_seed, \
            f"Recovered account should have address {address_from_seed}, but has {address}"

    with step('Verify that the user logged in via seed phrase correctly'):
        user_canvas = main_window.left_panel.open_online_identifier()
        profile_popup = user_canvas.open_profile_popup_from_online_identifier()
        assert profile_popup.user_name == user_account.name

    with step('Restart application and try re-importing seed phrase again'):
        aut.restart()
        enter_seed_view = LoginView().add_existing_status_user().open_keys_view().open_enter_seed_phrase_view()
        enter_seed_view.input_seed_phrase(seed_phrase.split(), autocomplete=False)
        confirm_import = enter_seed_view.click_import_seed_phrase_button()

    with step('Verify that keys already exist popup appears and text is correct'):
        assert confirm_import.get_key_exist_title() == KeysExistText.KEYS_EXIST_TITLE.value
        assert KeysExistText.KEYS_EXIST_TEXT.value in confirm_import.get_text_labels()
