import allure
import pytest
from allure import step

import constants
import driver
from driver.aut import AUT
from gui.components.back_up_your_seed_phrase_banner import BackUpSeedPhraseBanner

import configs.timeouts
from gui.main_window import MainWindow


@allure.testcase('https://ethstatus.testrail.net/index.php?/cases/view/703010', 'Settings - Sign out & Quit')
@pytest.mark.case(703421, 703010, 738725, 738758, 738771)
@pytest.mark.critical  # TODO 'https://github.com/status-im/status-desktop/issues/13013'
@pytest.mark.smoke
def test_back_up_recovery_phrase_sign_out(
        aut: AUT, main_screen: MainWindow, user_account):
    with step('Open online identifier and check the data'):
        online_identifier = main_screen.left_panel.open_online_identifier()
        assert online_identifier.get_user_name == user_account.name, \
            f'Display name in online identifier is wrong, current: {online_identifier.get_user_name}, expected: {user_account.name}'
        assert online_identifier.identicon_ring.is_visible, f'Identicon ring is not present when it should'

    with step('Verify that user avatar background color'):
        avatar_color = str(main_screen.left_panel.profile_button.object.identicon.asset.bgColor.name).upper()
        assert avatar_color in constants.UserPictureColors.profile_colors(), \
            f'Avatar color should be one of the allowed colors but is {avatar_color}'

    with step('Open user profile from online identifier and check the data'):
        online_identifier = main_screen.left_panel.open_online_identifier()
        profile_popup = online_identifier.open_profile_popup_from_online_identifier()
        profile_popup_user_name = profile_popup.user_name
        assert profile_popup_user_name == user_account.name, \
            f'Display name in user profile is wrong, current: {profile_popup_user_name}, expected: {user_account.name}'

    with step('Open share profile popup and check the data'):
        share_profile_popup = profile_popup.share_profile()
        assert share_profile_popup.is_profile_qr_code_visibile, f'QR code is not displayed'
        share_profile_popup.close()

    with step('Click left panel and open settings'):
        main_screen.left_panel.click()
        settings = main_screen.left_panel.open_settings()

        assert driver.waitFor(lambda: settings.left_panel.settings_section_back_up_seed_option.wait_until_appears,
                              configs.timeouts.UI_LOAD_TIMEOUT_MSEC), f"Back up seed option is not present"
        if not configs.system.TEST_MODE and not configs._local.DEV_BUILD:
            assert BackUpSeedPhraseBanner().does_back_up_seed_banner_exist(), "Back up seed banner is not present"
            assert BackUpSeedPhraseBanner().is_back_up_now_button_present(), 'Back up now button is not present'

    with step('Open back up seed phrase in settings'):
        back_up = settings.left_panel.open_back_up_seed_phrase()
        back_up.back_up_seed_phrase()

    with step('Verify back up seed phrase banner disappeared'):
        assert not settings.left_panel.settings_section_back_up_seed_option.exists, f"Back up seed option is present"
        if not configs.system.TEST_MODE and not configs._local.DEV_BUILD:
            BackUpSeedPhraseBanner().wait_to_hide_the_banner()
            assert not BackUpSeedPhraseBanner().does_back_up_seed_banner_exist(), "Back up seed banner is present"

    with step('Click sign out and quit in settings'):
        sign_out_screen = settings.left_panel.open_sign_out_and_quit()
        sign_out_screen.sign_out_and_quit()
