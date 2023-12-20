import time

import allure
import pytest
from allure_commons._allure import step
from . import marks

import constants
import driver
from gui.components.signing_phrase_popup import SigningPhrasePopup
from gui.components.toast_message import ToastMessage
from gui.main_window import MainWindow

pytestmark = marks
@allure.testcase('https://ethstatus.testrail.net/index.php?/cases/view/703028', 'Manage a custom generated account')
@pytest.mark.case(703028)
@pytest.mark.parametrize('user_account', [constants.user.user_account_one])
@pytest.mark.parametrize('derivation_path, generated_address_index, name, color, emoji, emoji_unicode', [
    pytest.param('Ethereum', '5', 'Ethereum', '#216266', 'sunglasses', '1f60e'),
    pytest.param('Ethereum Testnet (Ropsten)', '10', 'Ethereum Testnet ', '#7140fd', 'sunglasses', '1f60e'),
    pytest.param('Ethereum (Ledger)', '15', 'Ethereum Ledger', '#2a799b', 'sunglasses', '1f60e'),
    pytest.param('Ethereum (Ledger Live/KeepKey)', '20', 'Ethereum Ledger Live', '#7140fd', 'sunglasses', '1f60e'),
    pytest.param('N/A', '95', 'Custom path', '#216266', 'sunglasses', '1f60e')
])
@pytest.mark.skip(reason='https://github.com/status-im/desktop-qa-automation/issues/220')
@pytest.mark.xfail(reason="https://github.com/status-im/status-desktop/issues/12914")
def test_plus_button_manage_generated_account_custom_derivation_path(main_screen: MainWindow, user_account,
                                                                     derivation_path: str, generated_address_index: int,
                                                                     name: str, color: str, emoji: str, emoji_unicode: str):
    with step('Create generated wallet account'):
        wallet = main_screen.left_panel.open_wallet()
        SigningPhrasePopup().wait_until_appears().confirm_phrase()
        account_popup = wallet.left_panel.open_add_account_popup()
        account_popup.set_name(name).set_emoji(emoji).set_color(color).set_derivation_path(derivation_path,
                                                                                           generated_address_index,
                                                                                           user_account.password).save()

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

    with step('Delete wallet account with agreement'):
        wallet.left_panel.delete_account_from_context_menu(name).agree_and_confirm()

    with step('Verify toast message notification when removing account'):
        messages = ToastMessage().get_toast_messages
        assert f'"{name}" successfully removed' in messages, \
            f"Toast message about account removal is not correct or not present. Current list of messages: {messages}"

    with step('Verify that the account is not displayed in accounts list'):
        assert driver.waitFor(lambda: name not in [account.name for account in wallet.left_panel.accounts], 10000), \
            f'Account with {name} is still displayed even it should not be'
