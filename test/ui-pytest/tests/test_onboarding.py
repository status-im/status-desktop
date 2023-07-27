import logging

import pytest

import configs.timeouts
import driver
from gui.components.before_started_popup import BeforeStartedPopUp
from gui.components.profile_picture_popup import shift_image
from gui.components.splash_screen import SplashScreen
from gui.components.welcome_status_popup import WelcomeStatusPopup
from gui.screens.onboarding import AllowNotificationsView, WelcomeScreen, TouchIDAuthView
from scripts.tools import image

_logger = logging.getLogger(__name__)


# Test Case: https://ethstatus.testrail.net/index.php?/cases/view/703020
@pytest.mark.case(703020)
@pytest.mark.parametrize('user_name, password, user_image', [
    pytest.param('Test-User _1', '*P@ssw0rd*', None),
    pytest.param('_1Test-User', '*P@ssw0rd*', 'tv_signal.jpeg', marks=pytest.mark.smoke),
    pytest.param('Test-User', '*P@ssw0rd*', 'tv_signal.png'),
])
def test_generate_new_keys(main_window, user_name, password, user_image: str):
    if configs.system.IS_MAC:
        AllowNotificationsView().wait_until_appears().allow()
    BeforeStartedPopUp().get_started()
    wellcome_screen = WelcomeScreen().wait_until_appears()
    keys_screen = wellcome_screen.get_keys()

    # Profile view verification
    profile_view = keys_screen.generate_new_keys()
    profile_view.set_display_name(user_name)
    if user_image is not None:
        profile_picture_popup = profile_view.set_user_image(configs.testpath.TEST_FILES / user_image)
        profile_picture_popup.make_profile_picture(zoom=5, shift=shift_image(0, 200, 200, 0))
    assert not profile_view.error_message

    details_view = profile_view.next()
    if user_image is None:
        # Verification: The first tho chars on profile picture
        assert not details_view.is_user_image_background_white()
        assert driver.waitFor(
            lambda: details_view.is_user_image_contains(user_name[:2]),
            configs.timeouts.UI_LOAD_TIMEOUT_MSEC
        )
    else:
        # Verification: The profile picture zoomed, shifted and applied
        image.compare(
            details_view.cropped_profile_image,
            configs.testpath.TEST_VP / f'user_image_onboarding.png',
        )

    chat_key = details_view.chat_key
    emoji_hash = details_view.emoji_hash
    assert details_view.is_identicon_ring_visible

    create_password_view = details_view.next()
    assert not create_password_view.is_create_password_button_enabled
    confirm_password_view = create_password_view.create_password(password)
    confirm_password_view.confirm_password(password)
    if configs.system.IS_MAC:
        TouchIDAuthView().wait_until_appears().prefer_password()
    SplashScreen().wait_until_appears().wait_until_hidden()
    WelcomeStatusPopup().confirm()

    # User canvas verification
    user_canvas = main_window.left_panel.open_user_canvas()
    assert user_canvas.user_name == user_name
    # Verification: The first tho chars on profile picture
    if user_image is None:
        assert driver.waitFor(
            lambda: user_canvas.is_user_image_contains(user_name[:2]),
            configs.timeouts.UI_LOAD_TIMEOUT_MSEC
        )

    # Profile popup verification
    profile_popup = user_canvas.open_profile_popup()
    assert profile_popup.user_name == user_name
    assert profile_popup.chat_key == chat_key
    assert profile_popup.emoji_hash.compare(emoji_hash.view)
    if user_image is None:
        # Verification: The first tho chars on profile picture
        assert driver.waitFor(
            lambda: profile_popup.is_user_image_contains(user_name[:2]),
            configs.timeouts.UI_LOAD_TIMEOUT_MSEC
        )
    else:
        # Verification: The Profile pictures from Wellcome screen and Profile popup are equal
        image.compare(
            profile_popup.cropped_profile_image,
            'user_image_profile.png',
        )
