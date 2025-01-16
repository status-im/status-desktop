import time

import allure
import pytest
from allure_commons._allure import step

from scripts.utils.generators import random_emoji_with_unicode, random_wallet_acc_keypair_name, \
    random_wallet_account_color
from tests.wallet_main_screen import marks

import constants
from gui.components.authenticate_popup import AuthenticatePopup
from gui.main_window import MainWindow

pytestmark = marks


@allure.testcase('https://ethstatus.testrail.net/index.php?/cases/view/703026', 'Manage a watch-only account')
@pytest.mark.case(703026, 738788, 738815)
@pytest.mark.smoke
# TODO: to add a step of account removal
@pytest.mark.parametrize('address', [
    pytest.param('0xea123F7beFF45E3C9fdF54B324c29DBdA14a639A')
])
def test_plus_button_add_watched_address(main_screen: MainWindow, address: str):

    emoji_data = random_emoji_with_unicode()
    name = random_wallet_acc_keypair_name()
    color = random_wallet_account_color()

    with step('Add watched address with plus action button'):
        wallet = main_screen.left_panel.open_wallet()
        account_popup = wallet.left_panel.open_add_account_popup()
        account_popup.set_name(name).set_emoji(
            emoji_data[0]).set_color(color).set_origin_watched_address(address).save_changes()
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
        expected_account = constants.user.account_list_item(name, color.lower(), emoji_data[1].split('-')[0])
        started_at = time.monotonic()
        while expected_account not in wallet.left_panel.accounts:
            time.sleep(1)
            if time.monotonic() - started_at > 15:
                raise LookupError(f'Account {expected_account} not found in {wallet.left_panel.accounts}')
