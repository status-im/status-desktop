import time

import allure
import pytest
from allure import step
from tests.wallet_main_screen import marks

import constants
from driver.aut import AUT
from gui.components.signing_phrase_popup import SigningPhrasePopup
from gui.components.wallet.authenticate_popup import AuthenticatePopup
from gui.components.toast_message import ToastMessage
from gui.main_window import MainWindow

pytestmark = marks
@allure.testcase('https://ethstatus.testrail.net/index.php?/cases/view/704459',
                 'User can add  one more account after restarting the app')
@pytest.mark.case(704459)
@pytest.mark.parametrize('user_account', [constants.user.user_account_one])
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
        SigningPhrasePopup().wait_until_appears().confirm_phrase()
        account_popup = wallet.left_panel.open_add_account_popup()
        account_popup.set_name(name).set_emoji(emoji).set_color(color).save()
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

    with step('Restart application'):
        aut.restart()
        main_screen.authorize_user(user_account)

    with step('Add second generated wallet account'):
        wallet = main_screen.left_panel.open_wallet()
        assert not SigningPhrasePopup().is_ok_got_it_button_visible(), \
            f"Signing phrase should not be present because it has been hidden in the first step"
        account_popup = wallet.left_panel.open_add_account_popup()
        account_popup.set_name(name2).set_emoji(emoji2).set_color(color2).save()
        AuthenticatePopup().wait_until_appears().authenticate(user_account.password)
        account_popup.wait_until_hidden()

    with step('Verify toast message notification when adding account'):
        assert len(ToastMessage().get_toast_messages) == 1, \
            f"Multiple toast messages appeared"
        message = ToastMessage().get_toast_messages[0]
        assert message == f'"{name2}" successfully added'

    with step('Verify that the account is correctly displayed in accounts list'):
        expected_account = constants.user.account_list_item_2(name2, color2.lower(), emoji_unicode2)
        started_at = time.monotonic()
        while expected_account not in wallet.left_panel.accounts:
            time.sleep(1)
            if time.monotonic() - started_at > 15:
                raise LookupError(f'Account {expected_account} not found in {wallet.left_panel.accounts}')
            
