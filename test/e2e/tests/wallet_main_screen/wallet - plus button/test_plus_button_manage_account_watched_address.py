import time

import allure
import pytest
from allure_commons._allure import step

import driver
from tests.wallet_main_screen import marks

import constants
from gui.components.signing_phrase_popup import SigningPhrasePopup
from gui.components.authenticate_popup import AuthenticatePopup
from gui.main_window import MainWindow

pytestmark = marks


@allure.testcase('https://ethstatus.testrail.net/index.php?/cases/view/703026', 'Manage a watch-only account')
@pytest.mark.case(703026)
@pytest.mark.parametrize('address, name, color, emoji, emoji_unicode', [
    pytest.param('0xea123F7beFF45E3C9fdF54B324c29DBdA14a639A', 'AccWatch1', '#2a4af5',
                 'sunglasses', '1f60e')
])
def test_plus_button_add_watched_address(
        main_screen: MainWindow, address: str, color: str, emoji: str, emoji_unicode: str,
        name: str):
    with step('Add watched address with plus action button'):
        wallet = main_screen.left_panel.open_wallet()
        SigningPhrasePopup().wait_until_appears().confirm_phrase()
        account_popup = wallet.left_panel.open_add_account_popup()
        account_popup.set_name(name).set_emoji(emoji).set_color(color).set_origin_watched_address(address).save_changes()
        account_popup.wait_until_hidden()

    with step('Check authentication popup does not appear'):
        assert not AuthenticatePopup().is_authenticate_button_visible(), \
            f"Authentication should not appear for adding watched addresses"

    with step('Verify toast message notification when adding account'):
        assert len(main_screen.wait_for_notification()) == 1, \
            f"Multiple toast messages appeared"
        message = main_screen.wait_for_notification()[0]
        assert message == f'"{name}" successfully added'

    with step('Verify that the account is correctly displayed in accounts list'):
        expected_account = constants.user.account_list_item(name, color.lower(), emoji_unicode)
        started_at = time.monotonic()
        while expected_account not in wallet.left_panel.accounts:
            time.sleep(1)
            if time.monotonic() - started_at > 15:
                raise LookupError(f'Account {expected_account} not found in {wallet.left_panel.accounts}')

    with step('Delete watched account with agreement'):
        wallet.left_panel.delete_account_from_context_menu(name).confirm()

    with step('Verify toast message notification when removing account'):
        messages = main_screen.wait_for_notification()
        assert f'"{name}" successfully removed' in messages, \
            f"Toast message about account removal is not correct or not present. Current list of messages: {messages}"

    with step('Verify that the account is not displayed in accounts list'):
        assert driver.waitFor(lambda: name not in [account.name for account in wallet.left_panel.accounts], 10000), \
            f'Account with {name} is still displayed even it should not be'
