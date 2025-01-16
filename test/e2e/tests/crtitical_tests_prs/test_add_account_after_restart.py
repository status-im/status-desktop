import time

import allure
import pyperclip
import pytest
from allure import step

from constants.wallet import WalletNetworkSettings
from helpers.WalletHelper import authenticate_with_password

import constants
from driver.aut import AUT
from gui.components.signing_phrase_popup import SigningPhrasePopup
from gui.main_window import MainWindow
from scripts.utils.generators import random_emoji_with_unicode, random_wallet_account_color, \
    random_wallet_acc_keypair_name


@allure.testcase('https://ethstatus.testrail.net/index.php?/cases/view/704459',
                 'User can add  one more account after restarting the app')
@pytest.mark.case(704459, 738724, 738782, 738786)
@pytest.mark.critical
@pytest.mark.smoke
def test_add_generated_account_restart_add_again(
        aut: AUT, main_screen: MainWindow, user_account):

    emoji_data1 = random_emoji_with_unicode()
    name1 = random_wallet_acc_keypair_name()
    color1 = random_wallet_account_color()

    emoji_data2 = random_emoji_with_unicode()
    name2 = random_wallet_acc_keypair_name()
    color2 = random_wallet_account_color()

    with step('Open wallet and choose default account'):
        default_name = WalletNetworkSettings.STATUS_ACCOUNT_DEFAULT_NAME.value
        wallet = main_screen.left_panel.open_wallet()
        wallet_account = wallet.left_panel.select_account(default_name)
        wallet.left_panel.copy_account_address_in_context_menu(default_name)
        wallet_address = pyperclip.paste()

    with step('Check QR code and address in Receive modal from footer'):
        receive_popup = wallet_account.open_receive_popup()
        assert receive_popup.qr_code.is_visible, f'QR code is not present in Receive modal'
        assert wallet_address == receive_popup.copy_address(), f'Addresses do not match'

    with step('Add the first generated wallet account'):
        wallet = main_screen.left_panel.open_wallet()
        account_popup = wallet.left_panel.open_add_account_popup()
        account_popup.set_name(name1).set_emoji(emoji_data1[0]).set_color(color1).save_changes()
        authenticate_with_password(user_account)
        account_popup.wait_until_hidden()

    with step('Verify toast message notification when adding account'):
        assert len(main_screen.wait_for_notification()) == 1, \
            f"Multiple toast messages appeared"
        message = main_screen.wait_for_notification()[0]
        assert message == f'"{name1}" successfully added'

    with step('Verify that the account is correctly displayed in accounts list'):
        expected_account = constants.user.account_list_item(name1, color1.lower(), emoji_data1[1].split('-')[0])
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
        account_popup.set_name(name2).set_emoji(emoji_data2[0]).set_color(color2).save_changes()
        authenticate_with_password(user_account)
        account_popup.wait_until_hidden()

    with step('Verify toast message notification when adding account'):
        assert len(main_screen.wait_for_notification()) == 1, \
            f"Multiple toast messages appeared"
        message = main_screen.wait_for_notification()[0]
        assert message == f'"{name2}" successfully added'

    with step('Verify that the account is correctly displayed in accounts list'):
        expected_account = constants.user.account_list_item_2(name2, color2.lower(), emoji_data2[1].split('-')[0])
        started_at = time.monotonic()
        while expected_account not in wallet.left_panel.accounts:
            time.sleep(1)
            if time.monotonic() - started_at > 15:
                raise LookupError(f'Account {expected_account} not found in {wallet.left_panel.accounts}')
