import logging
import random
import string

import allure
import psutil
import pytest
from allure import step
from . import marks

import configs.timeouts
from gui.components.onboarding.before_started_popup import BeforeStartedPopUp
from gui.components.onboarding.beta_consent_popup import BetaConsentPopup
from gui.components.picture_edit_popup import shift_image, PictureEditPopup
from gui.components.splash_screen import SplashScreen
from gui.screens.onboarding import AllowNotificationsView, WelcomeToStatusView, BiometricsView, KeysView

pytestmark = marks


@pytest.fixture
def keys_screen(main_window) -> KeysView:
    with step('Open Generate new keys view'):
        if configs.system.IS_MAC:
            AllowNotificationsView().wait_until_appears().allow()
        BeforeStartedPopUp().get_started()
        welcome_screen = WelcomeToStatusView().wait_until_appears()
        return welcome_screen.get_keys()


@allure.testcase('https://ethstatus.testrail.net/index.php?/cases/view/703421', 'Generate new keys')
@allure.testcase('https://ethstatus.testrail.net/index.php?/cases/view/703010', 'Settings - Sign out & Quit')
@pytest.mark.case(703421, 703010)
@pytest.mark.critical
# reason='https://github.com/status-im/status-desktop/issues/13013'
@pytest.mark.parametrize('user_name, password, user_image, zoom, shift', [
    pytest.param(
        ''.join((random.choice(
            string.ascii_letters + string.digits + random.choice('_- '))
                for i in range(5, 25))
        ).strip(' '),
        ''.join((random.choice(
            string.ascii_letters + string.digits + string.punctuation)
                for _ in range(10, 28))
        ),
        random.choice(['sample_JPEG_1920×1280.jpeg', 'file_example_PNG_3MB.png', 'file_example_JPG_2500kB.jpg']),
        5,
        shift_image(0, 1000, 1000, 0))
])
def test_generate_new_keys_sign_out_from_settings(aut, main_window, keys_screen, user_name: str, password, user_image: str, zoom: int, shift):

    with step('Click generate new keys and open profile view'):
        profile_view = keys_screen.generate_new_keys()
        assert profile_view.is_next_button_enabled is False, \
            f'Next button is enabled on profile screen when it should not'

    with step('Type in the display name on the profile view'):
        profile_view.set_display_name(user_name)
        assert profile_view.get_display_name() == user_name, \
            f'Display name is empty or was not filled in'
        assert not profile_view.get_error_message, \
            f'Error message {profile_view.get_error_message} is present when it should not'

    with step('Click plus button and add user picture'):
        profile_view.set_profile_picture(configs.testpath.TEST_IMAGES / user_image)
        PictureEditPopup().set_zoom_shift_for_picture(zoom=zoom, shift=shift)
        # TODO: find a way to verify the picture is there (changed to the custom one)
        assert profile_view.get_profile_image is not None, f'Profile picture was not set / applied'
        assert profile_view.is_identicon_ring_visible, f'Identicon ring is not present when it should'
        assert profile_view.is_next_button_enabled is True, \
            f'Next button is not enabled on profile screen'

    with step('Open emojihash and identicon ring profile screen and capture the details'):
        details_view = profile_view.next()
        chat_key = details_view.get_chat_key
        emoji_hash_public_key = details_view.get_emoji_hash
        assert details_view.is_identicon_ring_visible, f'Identicon ring is not present when it should'

    with step('Open password set up view, fill in the form and click back'):
        create_password_view = details_view.next()
        assert not create_password_view.is_create_password_button_enabled, \
            f'Create password button is enabled when it should not'
        confirm_password_view = create_password_view.create_password(password)
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
        confirm_password_view.confirm_password(password)
        if configs.system.IS_MAC:
            assert BiometricsView().is_touch_id_button_visible(), f"TouchID button is not found"
            BiometricsView().wait_until_appears().prefer_password()
        SplashScreen().wait_until_appears().wait_until_hidden()
        if not configs.system.TEST_MODE:
            BetaConsentPopup().confirm()

    with step('Open online identifier and check the data'):
        online_identifier = main_window.left_panel.open_online_identifier()
        assert online_identifier.get_user_name == user_name, \
            f'Display name in online identifier is wrong, current: {online_identifier.get_user_name}, expected: {user_name}'
        assert online_identifier.is_identicon_ring_visible, \
            f'Identicon ring is not present when it should'
        assert str(online_identifier.object.pubkey) is not None, \
            f'Public key is not present'
        assert str(online_identifier.object.pubkey) == emoji_hash_public_key, f'Public keys should match when they dont'

    with step('Open user profile from online identifier and check the data'):
        profile_popup = online_identifier.open_profile_popup_from_online_identifier()
        profile_popup_user_name = profile_popup.user_name
        profile_popup_chat_key = profile_popup.copy_chat_key
        assert profile_popup_user_name == user_name, \
            f'Display name in user profile is wrong, current: {profile_popup_user_name}, expected: {user_name}'
        assert profile_popup_chat_key == chat_key, \
            f'Chat key in user profile is wrong, current: {profile_popup_chat_key}, expected: {chat_key}'
        assert profile_popup.get_emoji_hash == emoji_hash_public_key, \
            f'Public keys should match when they dont'

    with step('Click left panel and open settings'):
        main_window.left_panel.click()
        settings = main_window.left_panel.open_settings()

    with step('Click sign out and quit in settings'):
        sign_out_screen = settings.left_panel.open_sign_out_and_quit()
        sign_out_screen.sign_out_and_quit()

    with step('Check the application process is not running'):
        psutil.Process(aut.pid).wait(timeout=30)