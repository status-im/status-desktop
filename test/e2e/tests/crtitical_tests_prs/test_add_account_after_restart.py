import time

import allure
import pytest
from allure import step

from constants import RandomUser
from helpers.WalletHelper import authenticate_with_password
from . import marks

import constants
from driver.aut import AUT
from gui.components.signing_phrase_popup import SigningPhrasePopup
from gui.main_window import MainWindow

pytestmark = marks


@allure.testcase('https://ethstatus.testrail.net/index.php?/cases/view/704459',
                 'User can add  one more account after restarting the app')
@pytest.mark.case(704459)
@pytest.mark.parametrize('name, color, emoji, emoji_unicode,',
                         [
                             pytest.param('GenAcc1', '#2a4af5', 'sunglasses', '1f60e')
                         ])
@pytest.mark.parametrize('name2, color2, emoji2, emoji_unicode2,',
                         [
                             pytest.param('GenAcc2', '#2a4af5', 'sunglasses', '1f60e')
                         ])
@pytest.mark.critical
def test_add_generated_account_restart_add_again(
        aut: AUT, main_screen: MainWindow, user_account,
        color: str, emoji: str, emoji_unicode: str, name: str,
        color2: str, emoji2: str, emoji_unicode2: str, name2: str,
):
    with step('Add the first generated wallet account'):
        wallet = main_screen.left_panel.open_wallet()
        account_popup = wallet.left_panel.open_add_account_popup()
        account_popup.set_name(name).save_changes()
        authenticate_with_password(user_account)
        account_popup.wait_until_hidden()

    with step('Verify toast message notification when adding account'):
        assert len(main_screen.wait_for_notification()) == 1, \
            f"Multiple toast messages appeared"
        message = main_screen.wait_for_notification()[0]
        assert message == f'"{name}" successfully added'

    with step('Verify that the account is correctly displayed in accounts list'):
        expected_account = constants.user.account_list_item(name, None, None)
        started_at = time.monotonic()
        while expected_account not in wallet.left_panel.accounts:
            time.sleep(1)
            if time.monotonic() - started_at > 15:
                raise LookupError(f'Account {expected_account} not found in {wallet.left_panel.accounts}')

    with step('Restart application'):
        aut.restart()
        main_screen.authorize_user(user_account)

    with step('Add second generated wallet account'):
        wallet = main_screen.left_panel.open_wallet()
        assert not SigningPhrasePopup().ok_got_it_button.is_visible, \
            f"Signing phrase should not be present because it has been hidden in the first step"
        account_popup = wallet.left_panel.open_add_account_popup()
        account_popup.set_name(name2).save_changes()
        authenticate_with_password(user_account)
        account_popup.wait_until_hidden()

    with step('Verify toast message notification when adding account'):
        assert len(main_screen.wait_for_notification()) == 1, \
            f"Multiple toast messages appeared"
        message = main_screen.wait_for_notification()[0]
        assert message == f'"{name2}" successfully added'

    with step('Verify that the account is correctly displayed in accounts list'):
        expected_account = constants.user.account_list_item_2(name2, None, None)
        started_at = time.monotonic()
        while expected_account not in wallet.left_panel.accounts:
            time.sleep(1)
            if time.monotonic() - started_at > 15:
                raise LookupError(f'Account {expected_account} not found in {wallet.left_panel.accounts}')
