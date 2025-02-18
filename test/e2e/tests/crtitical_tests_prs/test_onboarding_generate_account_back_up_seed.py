import random

import allure
import pytest
from allure import step

import constants
import driver
from gui.components.back_up_your_seed_phrase_banner import BackUpSeedPhraseBanner
from gui.components.signing_phrase_popup import SigningPhrasePopup

import configs.timeouts
from gui.components.onboarding.before_started_popup import BeforeStartedPopUp
from gui.components.picture_edit_popup import shift_image, PictureEditPopup
from gui.components.splash_screen import SplashScreen
from gui.screens.onboarding import WelcomeToStatusView, BiometricsView, \
    YourEmojihashAndIdenticonRingView


@allure.testcase('https://ethstatus.testrail.net/index.php?/cases/view/703421', 'Generate new keys')
@allure.testcase('https://ethstatus.testrail.net/index.php?/cases/view/703010', 'Settings - Sign out & Quit')
@pytest.mark.case(703421, 703010, 738725, 738758, 738771)
@pytest.mark.critical  # TODO 'https://github.com/status-im/status-desktop/issues/13013'
@pytest.mark.smoke
@pytest.mark.parametrize('user_image, zoom, shift', [
    pytest.param(
        random.choice(['sample_JPEG_1920×1280.jpeg', 'file_example_PNG_3MB.png', 'file_example_JPG_2500kB.jpg']
                      ),
        random.choice(range(1, 10)),
        shift_image(0, 1000, 1000, 0))
])
def test_generate_account_back_up_seed_sign_out(aut, main_window, user_account,
                                                user_image: str, zoom: int, shift):
    with step('Click generate new keys and open profile view'):
        BeforeStartedPopUp().get_started()
        keys_screen = WelcomeToStatusView().wait_until_appears().get_keys()

        profile_view = keys_screen.generate_new_keys()
        assert profile_view.is_next_button_enabled is False, \
            f'Next button is enabled on profile screen when it should not'

    with step('Type in the display name on the profile view'):
        profile_view.set_display_name(user_account.name)
        assert profile_view.get_display_name() == user_account.name, \
            f'Display name is empty or was not filled in'
        assert not profile_view.get_error_message, \
            f'Error message {profile_view.get_error_message} is present when it should not'

    with step('Click plus button and add user picture'):
        profile_view.set_profile_picture(configs.testpath.TEST_IMAGES / user_image)
        PictureEditPopup().set_zoom_shift_for_picture(zoom=zoom, shift=shift)
        assert profile_view.get_profile_image is not None, f'Profile picture was not set / applied'
        assert profile_view.is_next_button_enabled is True, \
            f'Next button is not enabled on profile screen'

    with step('Open password set up view, fill in the form and click back'):
        create_password_view = profile_view.next()
        assert not create_password_view.is_create_password_button_enabled, \
            f'Create password button is enabled when it should not'
        confirm_password_view = create_password_view.create_password(user_account.password)
        confirm_password_view.back()
        assert create_password_view.get_password_from_first_field is not None, \
            f'Password field lost its value when clicking back button'
        assert create_password_view.get_password_from_confirmation_field is not None, \
            f'Password confirmation field lost its value when clicking back button'

    with step('Click create password and open password confirmation screen'):
        confirm_password_view = create_password_view.click_create_password()
        assert not confirm_password_view.is_confirm_password_button_enabled, \
            f'Finalise Status password creation button is enabled when it should not'

    with step('Confirm password and login'):
        confirm_password_view.confirm_password(user_account.password)
        if configs.system.get_platform() == "Darwin":
            assert BiometricsView().is_touch_id_button_visible(), f"TouchID button is not found"
            BiometricsView().wait_until_appears().prefer_password()
        SplashScreen().wait_until_appears().wait_until_hidden(timeout_msec=90000)

    with step('Verify emojihash and identicon ring profile screen appeared and capture the details'):
        emoji_hash_identicon_view = YourEmojihashAndIdenticonRingView().verify_emojihash_view_present()
        chat_key = emoji_hash_identicon_view.get_chat_key
        assert len(chat_key) == 49
        assert emoji_hash_identicon_view._identicon_ring.is_visible, f'Identicon ring is not present when it should'

    with step('Click Start using Status'):
        next_view = emoji_hash_identicon_view.next()
        if configs.system.get_platform() == "Darwin":
            next_view.start_using_status()
        SplashScreen().wait_until_appears().wait_until_hidden(timeout_msec=90000)
        assert SigningPhrasePopup().ok_got_it_button.is_visible
        SigningPhrasePopup().confirm_phrase()

    with step('Verify that user avatar background color'):
        avatar_color = str(main_window.left_panel.profile_button.object.identicon.asset.color.name).upper()
        assert avatar_color in constants.UserPictureColors.profile_colors(), \
            f'Avatar color should be one of the allowed colors but is {avatar_color}'

    with step('Open online identifier and check the data'):
        online_identifier = main_window.left_panel.open_online_identifier()
        assert online_identifier.get_user_name == user_account.name, \
            f'Display name in online identifier is wrong, current: {online_identifier.get_user_name}, expected: {user_account.name}'
        assert online_identifier._identicon_ring.is_visible, \
            f'Identicon ring is not present when it should'
        assert str(online_identifier.object.compressedPubKey) is not None, \
            f'Public key is not present'
        assert chat_key in online_identifier.copy_link_to_profile(), f'Public keys should match when they dont'

    with step('Open user profile from online identifier and check the data'):
        online_identifier = main_window.left_panel.open_online_identifier()
        profile_popup = online_identifier.open_profile_popup_from_online_identifier()
        profile_popup_user_name = profile_popup.user_name
        profile_popup_chat_key = profile_popup.copy_chat_key
        assert profile_popup_user_name == user_account.name, \
            f'Display name in user profile is wrong, current: {profile_popup_user_name}, expected: {user_account.name}'
        assert profile_popup_chat_key == chat_key, \
            f'Chat key in user profile is wrong, current: {profile_popup_chat_key}, expected: {chat_key}'

    with step('Open share profile popup and check the data'):
        share_profile_popup = profile_popup.share_profile()
        profile_link = share_profile_popup.get_profile_link()
        assert share_profile_popup.is_profile_qr_code_visibile, f'QR code is not displayed'
        assert chat_key in profile_link, f'Profile link is wrong {profile_link}, it does not contain correct chat key'
        share_profile_popup.close()

    with step('Click left panel and open settings'):
        main_window.left_panel.click()
        settings = main_window.left_panel.open_settings()
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
