import time

import allure
import pytest
from allure_commons._allure import step

from constants import UserAccount, RandomUser
from scripts.utils.generators import random_name_string, random_password_string
from constants.wallet import WalletSeedPhrase
from tests.wallet_main_screen import marks

import constants
import driver
from gui.components.signing_phrase_popup import SigningPhrasePopup
from gui.components.authenticate_popup import AuthenticatePopup
from gui.main_window import MainWindow

pytestmark = marks


@allure.testcase('https://ethstatus.testrail.net/index.php?/cases/view/703030', 'Manage a seed phrase imported account')
@pytest.mark.case(703030)
@pytest.mark.parametrize('user_account', [RandomUser()])
@pytest.mark.parametrize('name, color, emoji, emoji_unicode, '
                         'new_name, new_color, new_emoji, new_emoji_unicode, seed_phrase', [
                             pytest.param('SPAcc24', '#2a4af5', 'sunglasses', '1f60e',
                                          'SPAcc24edited', '#216266', 'thumbsup', '1f44d',
                                          'elite dinosaur flavor canoe garbage palace antique dolphin virtual mixed sand '
                                          'impact solution inmate hair pipe affair cage vote estate gloom lamp robust like'),
                             pytest.param('SPAcc18', '#2a4af5', 'sunglasses', '1f60e',
                                          'SPAcc18edited', '#216266', 'thumbsup', '1f44d',
                                          'kitten tiny cup admit cactus shrug shuffle accident century faith roof plastic '
                                          'beach police barely vacant sign blossom'),
                             pytest.param('SPAcc12', '#2a4af5', 'sunglasses', '1f60e',
                                          'SPAcc12edited', '#216266', 'thumbsup', '1f44d',
                                          'pelican chief sudden oval media rare swamp elephant lawsuit wheat knife initial')
                         ])
def test_plus_button_manage_account_from_seed_phrase(main_screen: MainWindow, user_account,
                                                     name: str, color: str, emoji: str, emoji_unicode: str,
                                                     new_name: str, new_color: str, new_emoji: str,
                                                     new_emoji_unicode: str,
                                                     seed_phrase: str):
    with step('Create imported seed phrase wallet account'):
        wallet = main_screen.left_panel.open_wallet()
        SigningPhrasePopup().wait_until_appears().confirm_phrase()
        account_popup = wallet.left_panel.open_add_account_popup()
        account_popup.set_name(name).set_emoji(emoji).set_color(
            color).open_add_new_account_popup().import_new_seed_phrase(seed_phrase.split())
        account_popup.save_changes()
        AuthenticatePopup().wait_until_appears().authenticate(user_account.password)
        account_popup.wait_until_hidden()

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


@allure.testcase('https://ethstatus.testrail.net/index.php?/cases/view/736371',
                 "Can't import the same seed phrase when adding account")
@pytest.mark.case(736371)
@pytest.mark.parametrize('user_account', [RandomUser()])
@pytest.mark.parametrize('name, color, emoji, emoji_unicode, '
                         'new_name, new_color, new_emoji, new_emoji_unicode, seed_phrase', [
                             pytest.param('SPAcc24', '#2a4af5', 'sunglasses', '1f60e',
                                          'SPAcc24edited', '#216266', 'thumbsup', '1f44d',
                                          'elite dinosaur flavor canoe garbage palace antique dolphin virtual mixed sand '
                                          'impact solution inmate hair pipe affair cage vote estate gloom lamp robust like'),
                         ])
def test_plus_button_re_importing_seed_phrase(main_screen: MainWindow, user_account,
                                              name: str, color: str, emoji: str, emoji_unicode: str,
                                              new_name: str, new_color: str, new_emoji: str,
                                              new_emoji_unicode: str,
                                              seed_phrase: str):
    with (step('Create imported seed phrase wallet account')):
        wallet = main_screen.left_panel.open_wallet()
        SigningPhrasePopup().wait_until_appears().confirm_phrase()
        account_popup = wallet.left_panel.open_add_account_popup()
        account_popup.set_name(name).set_emoji(emoji).set_color(
            color).open_add_new_account_popup().import_new_seed_phrase(seed_phrase.split())
        account_popup.save_changes()
        AuthenticatePopup().wait_until_appears().authenticate(user_account.password)
        account_popup.wait_until_hidden()

    with step('Try to re-import seed phrase and verify that correct error appears'):
        account_popup = wallet.left_panel.open_add_account_popup()
        add_new_account = account_popup.set_name(name).set_emoji(emoji).set_color(color).open_add_new_account_popup()
        add_new_account.enter_new_seed_phrase(seed_phrase.split())
        assert add_new_account.get_already_added_error() == WalletSeedPhrase.WALLET_SEED_PHRASE_ALREADY_ADDED.value
