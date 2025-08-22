import allure
import pytest
from allure_commons._allure import step

from constants import UserAccount
from constants.dock_buttons import DockButtons
from constants.wallet import WalletNetworkSettings
from driver.aut import AUT
from helpers.onboarding_helper import open_create_profile_view, import_seed_and_log_in
from scripts.utils.generators import random_mnemonic, get_wallet_address_from_mnemonic

from gui.main_window import MainLeftPanel, MainWindow
from gui.screens.onboarding import ReturningLoginView


@allure.testcase('https://ethstatus.testrail.net/index.php?/cases/view/703040', 'Import: 12 word seed phrase')
@allure.testcase('https://ethstatus.testrail.net/index.php?/cases/view/736372', 'Re-importing seed-phrase')
@pytest.mark.case(703040, 736372, 738726)
@pytest.mark.critical
@pytest.mark.smoke
def test_import_and_reimport_random_seed(
        main_window: MainWindow,
        aut: AUT,
        user_account: UserAccount,
        seed_phrase=random_mnemonic()
):
    with step('Import seed and log in'):

        with step('Open Create your profile view'):
            create_your_profile_view = open_create_profile_view()
        with step('Import seed and log in'):
            import_seed_and_log_in(create_your_profile_view, seed_phrase, user_account)

    with step('Verify that restored account reveals correct status wallet address'):
        profile = main_window.left_panel.open_settings().left_panel.open_profile_settings()
        profile.set_name(user_account.name)
        profile.save_changes_button.click()

        status_account_index = 0
        status_acc_view = (
            MainLeftPanel().open_settings().left_panel.open_wallet_settings().open_account_in_settings(
                WalletNetworkSettings.STATUS_ACCOUNT_DEFAULT_NAME.value,
                status_account_index))
        address = status_acc_view.get_account_address_value()

        address_from_seed = get_wallet_address_from_mnemonic(seed_phrase)
        # assert Web3.is_checksum_address(address) todo: https://github.com/status-im/status-desktop/issues/17648
        assert address == address_from_seed, \
            f"Recovered account should have address {address_from_seed}, but has {address}"

    with step('Verify that the user logged in via seed phrase correctly'):
        user_canvas = main_window.left_panel.open_online_identifier()
        profile_popup = user_canvas.open_profile_popup_from_online_identifier()
        assert profile_popup.user_name == user_account.name

    with step('Restart application and try re-importing seed phrase again'):
        aut.restart()
        main_window.prepare()
        enter_seed_view = ReturningLoginView().add_existing_status_user().open_seed_phrase_view()
        enter_seed_view.fill_in_seed_phrase_grid(seed_phrase.split(), autocomplete=False)

    with step('Verify that keys already exist popup appears and text is correct'):
        assert enter_seed_view.invalid_seed_text.text == 'The entered recovery phrase is already added'
