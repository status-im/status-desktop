import time

import allure
import pytest
from allure_commons._allure import step
from . import marks

import constants
from gui.components.signing_phrase_popup import SigningPhrasePopup
from gui.components.toast_message import ToastMessage
from gui.main_window import MainWindow

pytestmark = marks
@pytest.mark.critical
@allure.testcase('https://ethstatus.testrail.net/index.php?/cases/view/703026',
                 'Manage a watch-only account from context menu option')
@pytest.mark.case(703026)
@pytest.mark.parametrize('address, name, color, emoji, emoji_unicode, new_name, new_color,'
                         'new_emoji, new_emoji_unicode', [
                             pytest.param('0xea123F7beFF45E3C9fdF54B324c29DBdA14a639A', 'AccWatch1', '#2a4af5',
                                          'sunglasses', '1f60e', 'AccWatch1edited', '#216266', 'thumbsup', '1f44d')
                         ])
def test_manage_watch_only_account_context_menu(main_screen: MainWindow, address: str, color: str, emoji: str,
                                                emoji_unicode: str,
                                                name: str, new_name: str, new_color: str, new_emoji: str,
                                                new_emoji_unicode: str):
    with step('Open wallet main screen and close signing phrase dialog'):
        wallet = main_screen.left_panel.open_wallet()
        SigningPhrasePopup().wait_until_appears().confirm_phrase()

    with step('Create watched address from context menu'):
        account_popup = wallet.left_panel.select_add_watched_address_from_context_menu()
        account_popup.set_name(name).set_emoji(emoji).set_color(color).set_eth_address(address).save()
        account_popup.wait_until_hidden()

    with step('Verify toast message notification when adding account'):
        assert len(ToastMessage().get_toast_messages) == 1, \
            f"Multiple toast messages appeared"
        message = ToastMessage().get_toast_messages[0]
        assert message == f'"{name}" successfully added'

    with step('Right click recently watched address and select edit option'):
        account_popup = wallet.left_panel.open_edit_account_popup_from_context_menu(name)

    with step('Set new name, emoji and color for account and save'):
        account_popup.set_name(new_name).set_emoji(new_emoji).set_color(new_color).save()

    with step('Verify that the account is correctly displayed in accounts list'):
        expected_account = constants.user.account_list_item(new_name, new_color.lower(), new_emoji_unicode)
        started_at = time.monotonic()
        while expected_account not in wallet.left_panel.accounts:
            time.sleep(1)
            if time.monotonic() - started_at > 15:
                raise LookupError(f'Account {expected_account} not found in {wallet.left_panel.accounts}')
