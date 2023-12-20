import time

import allure
import pytest
from allure import step
from . import marks

import constants
import driver
from gui.components.signing_phrase_popup import SigningPhrasePopup
from gui.components.wallet.authenticate_popup import AuthenticatePopup
from gui.components.toast_message import ToastMessage
from gui.main_window import MainWindow

pytestmark = marks
@allure.testcase('https://ethstatus.testrail.net/index.php?/cases/view/703036',
                 'Manage an account created from the generated seed phrase')
@pytest.mark.case(703036)
@pytest.mark.parametrize('user_account', [constants.user.user_account_one])
@pytest.mark.parametrize('name, color, emoji, emoji_unicode, '
                         'new_name, new_color, new_emoji, new_emoji_unicode, keypair_name', [
                             pytest.param('SPAcc', '#2a4af5', 'sunglasses', '1f60e',
                                          'SPAccedited', '#216266', 'thumbsup', '1f44d', 'SPKeyPair')])
@pytest.mark.xfail(reason="https://github.com/status-im/status-desktop/issues/12914")
def test_plus_button_manage_account_added_for_imported_seed_phrase(main_screen: MainWindow, user_account,
                                                                   name: str, color: str, emoji: str, emoji_unicode: str,
                                                                   new_name: str, new_color: str, new_emoji: str, new_emoji_unicode: str,
                                                                   keypair_name: str):
    with step('Create generated seed phrase wallet account'):
        wallet = main_screen.left_panel.open_wallet()
        SigningPhrasePopup().wait_until_appears().confirm_phrase()
        account_popup = wallet.left_panel.open_add_account_popup()
        account_popup.set_name(name).set_emoji(emoji).set_color(color).set_origin_new_seed_phrase(keypair_name).save()
        AuthenticatePopup().wait_until_appears().authenticate(user_account.password)
        account_popup.wait_until_hidden()

    with step('Verify toast message notification when adding account'):
        assert len(ToastMessage().get_toast_messages) == 1, \
            f"Multiple toast messages appeared"
        message = ToastMessage().get_toast_messages[0]
        assert message == f'"{name}" successfully added'

    with step('Verify that the account is correctly displayed in accounts list'):
        expected_account = constants.user.account_list_item(name, color.lower(), emoji_unicode)
        started_at = time.monotonic()
        while expected_account not in wallet.left_panel.accounts:
            time.sleep(1)
            if time.monotonic() - started_at > 15:
                raise LookupError(f'Account {expected_account} not found in {wallet.left_panel.accounts}')

    with step('Edit wallet account'):
        account_popup = wallet.left_panel.open_edit_account_popup_from_context_menu(name)
        account_popup.set_name(new_name).set_emoji(new_emoji).set_color(new_color).save()

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
        messages = ToastMessage().get_toast_messages
        assert f'"{new_name}" successfully removed' in messages, \
            f"Toast message about account removal is not correct or not present. Current list of messages: {messages}"

    with step('Verify that the account is not displayed in accounts list'):
        assert driver.waitFor(lambda: new_name not in [account.name for account in wallet.left_panel.accounts], 10000), \
            f'Account with {new_name} is still displayed even it should not be'
