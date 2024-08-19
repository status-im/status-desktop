import time

import allure
import pytest
from allure_commons._allure import step

from constants import RandomUser
from tests.wallet_main_screen import marks

import constants
import driver
from gui.components.signing_phrase_popup import SigningPhrasePopup
from gui.main_window import MainWindow

pytestmark = marks


@allure.testcase('https://ethstatus.testrail.net/index.php?/cases/view/703028', 'Manage a custom generated account')
@pytest.mark.case(703028)
@pytest.mark.parametrize('user_account', [RandomUser()])
@pytest.mark.parametrize('derivation_path, generated_address_index, name, color, emoji, emoji_unicode, new_name, new_color, new_emoji, new_emoji_unicode',
                         [
                            pytest.param('Ethereum', '5', 'Ethereum', '#216266', 'sunglasses', '1f60e', 'EthEdited', '#216266', 'thumbsup', '1f44d'),
                            pytest.param('Ethereum Testnet (Ropsten)', '10', 'Ethereum Testnet ', '#7140fd', 'sunglasses', '1f60e', 'RopstenEdited', '#216266', 'thumbsup', '1f44d'),
                            pytest.param('Ethereum (Ledger)', '15', 'Ethereum Ledger', '#2a799b', 'sunglasses', '1f60e', 'LedgerEdited', '#216266', 'thumbsup', '1f44d'),
                            pytest.param('Ethereum (Ledger Live/KeepKey)', '20', 'Ethereum Ledger Live', '#7140fd', 'sunglasses', '1f60e', 'LiveEdited', '#216266', 'thumbsup', '1f44d'),
                            pytest.param('N/A', '95', 'Custom path', '#216266', 'sunglasses', '1f60e', 'CustomEdited', '#216266', 'thumbsup', '1f44d')
])
def test_plus_button_manage_generated_account_custom_derivation_path(main_screen: MainWindow, user_account,
                                                                     derivation_path: str, generated_address_index: int,
                                                                     name: str, color: str, emoji: str,
                                                                     emoji_unicode: str,
                                                                     new_name: str, new_color: str, new_emoji: str,
                                                                     new_emoji_unicode: str):
    with step('Create generated wallet account'):
        wallet = main_screen.left_panel.open_wallet()
        SigningPhrasePopup().wait_until_appears().confirm_phrase()
        account_popup = wallet.left_panel.open_add_account_popup()
        account_popup.set_name(name).set_emoji(emoji).set_color(color).set_derivation_path(derivation_path,
                                                                                           generated_address_index,
                                                                                           user_account.password).save_changes()


    with step('Verify that the account is correctly displayed in accounts list'):
        expected_account = constants.user.account_list_item(name, color.lower(), emoji_unicode)
        started_at = time.monotonic()
        while expected_account not in wallet.left_panel.accounts:
            time.sleep(1)
            if time.monotonic() - started_at > 15:
                raise LookupError(f'Account {expected_account} not found in {wallet.left_panel.accounts}')

    with step('Verify toast message notification when adding account'):
        assert len(main_screen.wait_for_notification()) == 1, \
            f"Multiple toast messages appeared"
        message = main_screen.wait_for_notification()[0]
        assert message == f'"{name}" successfully added'

    with step('Edit wallet account'):
        account_popup = wallet.left_panel.open_edit_account_popup_from_context_menu(name)
        account_popup.set_name(new_name).set_emoji(new_emoji).set_color(new_color).save_changes()

    with step('Verify that the account is correctly displayed in accounts list'):
        expected_account = constants.user.account_list_item(new_name, new_color.lower(), new_emoji_unicode)
        started_at = time.monotonic()
        while expected_account not in wallet.left_panel.accounts:
            time.sleep(1)
            if time.monotonic() - started_at > 15:
                raise LookupError(f'Account {expected_account} not found in {wallet.left_panel.accounts}')

    with step('Delete wallet account with agreement'):
        wallet.left_panel.delete_account_from_context_menu(new_name).agree_and_confirm()

    with step('Verify toast message notification when removing account'):
        messages = main_screen.wait_for_notification()
        assert f'"{new_name}" successfully removed' in messages, \
            f"Toast message about account removal is not correct or not present. Current list of messages: {messages}"

    with step('Verify that the account is not displayed in accounts list'):
        assert driver.waitFor(lambda: new_name not in [account.name for account in wallet.left_panel.accounts], 10000), \
            f'Account with {new_name} is still displayed even it should not be'
