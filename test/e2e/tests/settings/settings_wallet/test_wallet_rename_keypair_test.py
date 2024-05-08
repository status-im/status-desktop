import allure
import pytest
from allure_commons._allure import step

from constants.wallet import WalletRenameKeypair
from gui.components.wallet.authenticate_popup import AuthenticatePopup
from tests.wallet_main_screen import marks

import constants
from gui.components.signing_phrase_popup import SigningPhrasePopup
from gui.main_window import MainWindow

pytestmark = marks


@allure.testcase('https://ethstatus.testrail.net/index.php?/cases/view/703420',
                 'Wallet -> Settings -> Keypair interactions: Rename keypair')
@pytest.mark.case(703420)
@pytest.mark.parametrize('user_account', [constants.user.user_with_random_attributes_1])
@pytest.mark.parametrize(
    'name, color, emoji, acc_emoji, second_name, third_name, new_name, new_name_1, seed_phrase',
    [pytest.param('Acc01', '#2a4af5', 'sunglasses', '😎 ',
                  'SPAcc24', 'PrivAcc', 'New name', 'New name 1',
                  'elite dinosaur flavor canoe garbage palace antique dolphin virtual mixed sand '
                  'impact solution inmate hair pipe affair cage vote estate gloom lamp robust like')])
@pytest.mark.parametrize('address_pair', [constants.user.private_key_address_pair_1])
def test_rename_keypair_test(main_screen: MainWindow, user_account, name: str, color: str, emoji: str, acc_emoji: str,
                             second_name: str, third_name: str, new_name, new_name_1, seed_phrase, address_pair):
    with step('Get display name'):
        profile_display_name = main_screen.left_panel.open_settings().left_panel.open_profile_settings().get_display_name

    with step('Create generated wallet account'):
        wallet = main_screen.left_panel.open_wallet()
        SigningPhrasePopup().wait_until_appears().confirm_phrase()
        account_popup = wallet.left_panel.open_add_account_popup()
        account_popup.set_name(name).set_emoji(emoji).set_color(color).save()
        AuthenticatePopup().wait_until_appears().authenticate(user_account.password)
        account_popup.wait_until_hidden()

    with step('Create imported seed phrase wallet account'):
        account_popup = wallet.left_panel.open_add_account_popup()
        account_popup.set_name(second_name).set_emoji(emoji).set_color(color).set_origin_seed_phrase(
            seed_phrase.split()).save()
        AuthenticatePopup().wait_until_appears().authenticate(user_account.password)
        account_popup.wait_until_hidden()

    with step('Import an account within private key'):
        account_popup = wallet.left_panel.open_add_account_popup()
        account_popup.set_name(third_name).set_emoji(emoji).set_color(color).set_origin_private_key(
            address_pair.private_key).save()
        AuthenticatePopup().wait_until_appears().authenticate(user_account.password)
        account_popup.wait_until_hidden()

    with step('Open wallet settings and verify Status keypair title'):
        settings = main_screen.left_panel.open_settings().left_panel.open_wallet_settings()
        status_keypair_title = settings.get_keypairs_names()[0]
        assert profile_display_name == status_keypair_title, \
            f"Status keypair name should be equal to display name but currently it is {status_keypair_title}, \
                when display name is {profile_display_name}"

    with step('Click 3 dots menu on Status keypair and check that there is no option to rename keypair'):
        settings.click_open_menu_button(profile_display_name)
        assert not settings.is_rename_keypair_menu_item_visible()

    with step('Click 3 dots menu on imported seed phrase account, open rename keypair popup and verify it was renamed'):
        settings.click_open_menu_button('2daa3')
        settings.click_rename_keypair().rename_keypair(new_name)
        assert settings.get_keypairs_names()[1] == new_name

    with step('Verify toast message with successful renaming appears'):
        messages = main_screen.wait_for_notification()
        assert WalletRenameKeypair.WALLET_SUCCESSFUL_RENAMING.value + 'from "2daa3" ' + 'to "' + new_name + '"' in messages, \
            f"Toast message have not appeared"

    with step('Click 3 dots menu on private key account, open rename keypair popup and verify it was renamed'):
        settings.click_open_menu_button('edfcgpadvm')
        settings.click_rename_keypair().rename_keypair(new_name_1)
        assert settings.get_keypairs_names()[2] == new_name_1

    with (step('Verify toast message with successful renaming appears')):
        messages = main_screen.wait_for_notification()
        assert WalletRenameKeypair.WALLET_SUCCESSFUL_RENAMING.value + 'from "edfcgpadvm" ' + 'to "' + new_name_1 + '"' in messages, \
            f"Toast message have not appeared"
