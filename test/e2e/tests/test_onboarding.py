import logging

import allure
import pytest
from allure import step

import configs.timeouts
import constants
import driver
from driver.aut import AUT
from gui.components.onboarding.before_started_popup import BeforeStartedPopUp
from gui.components.onboarding.welcome_status_popup import WelcomeStatusPopup
from gui.components.picture_edit_popup import shift_image
from gui.components.splash_screen import SplashScreen
from gui.screens.onboarding import AllowNotificationsView, WelcomeView, TouchIDAuthView, KeysView
from scripts.tools import image

_logger = logging.getLogger(__name__)
pytestmark = allure.suite("Onboarding")


@pytest.fixture
def keys_screen(main_window) -> KeysView:
    with step('Open Generate new keys view'):
        if configs.system.IS_MAC:
            AllowNotificationsView().wait_until_appears().allow()
        BeforeStartedPopUp().get_started()
        wellcome_screen = WelcomeView().wait_until_appears()
        return wellcome_screen.get_keys()


@allure.testcase('https://ethstatus.testrail.net/index.php?/cases/view/703421', 'Generate new keys')
@pytest.mark.case(703421)
@pytest.mark.parametrize('user_name, password, user_image, zoom, shift', [
    pytest.param('Test-User _1', '*P@ssw0rd*', None, None, None),
    pytest.param('Test-User', '*P@ssw0rd*', 'tv_signal.png', 5, shift_image(0, 0, 0, 0)),
    pytest.param('_1Test-User', '*P@ssw0rd*', 'tv_signal.jpeg', 5, shift_image(0, 1000, 1000, 0),
                 marks=pytest.mark.smoke),
])
def test_generate_new_keys(main_window, keys_screen, user_name: str, password, user_image: str, zoom: int, shift):
    with step(f'Setup profile with name: {user_name} and image: {user_image}'):

        profile_view = keys_screen.generate_new_keys()
        profile_view.set_display_name(user_name)
        if user_image is not None:
            profile_picture_popup = profile_view.set_user_image(configs.testpath.TEST_FILES / user_image)
            profile_picture_popup.make_picture(zoom=zoom, shift=shift)
        assert not profile_view.error_message

    with step('Open Profile details view and verify user info'):

        details_view = profile_view.next()
        if user_image is None:
            assert not details_view.is_user_image_background_white()
            assert driver.waitFor(
                lambda: details_view.is_user_image_contains(user_name[:2]),
                configs.timeouts.UI_LOAD_TIMEOUT_MSEC
            )
        else:
            image.compare(
                details_view.cropped_profile_image,
                f'{user_image.split(".")[1]}_onboarding.png',
                threshold=0.9
            )
        chat_key = details_view.chat_key
        emoji_hash = details_view.emoji_hash
        assert details_view.is_identicon_ring_visible

    with step('Finalize onboarding and open main screen'):

        create_password_view = details_view.next()
        assert not create_password_view.is_create_password_button_enabled
        confirm_password_view = create_password_view.create_password(password)
        confirm_password_view.confirm_password(password)
        if configs.system.IS_MAC:
            TouchIDAuthView().wait_until_appears().prefer_password()
        SplashScreen().wait_until_appears().wait_until_hidden()
        if not configs.DEV_BUILD:
            WelcomeStatusPopup().confirm()

    with step('Open User Canvas and verify user info'):

        user_canvas = main_window.left_panel.open_user_canvas()
        assert user_canvas.user_name == user_name
        if user_image is None:
            assert driver.waitFor(
                lambda: user_canvas.is_user_image_contains(user_name[:2]),
                configs.timeouts.UI_LOAD_TIMEOUT_MSEC
            )

    with step('Open Profile popup and verify user info'):

        profile_popup = user_canvas.open_profile_popup()
        assert profile_popup.user_name == user_name
        assert profile_popup.chat_key == chat_key
        assert profile_popup.emoji_hash.compare(emoji_hash.view, threshold=0.9)
        if user_image is None:
            assert driver.waitFor(
                lambda: profile_popup.is_user_image_contains(user_name[:2]),
                configs.timeouts.UI_LOAD_TIMEOUT_MSEC
            )
        else:
            image.compare(
                profile_popup.cropped_profile_image,
                f'{user_image.split(".")[1]}_profile.png',
                threshold=0.9
            )


@allure.testcase('https://ethstatus.testrail.net/index.php?/cases/view/703039', 'Import: 12 word seed phrase')
@pytest.mark.case(703039)
@pytest.mark.parametrize('user_account', [constants.user.user_account_two])
def test_import_seed_phrase(aut: AUT, keys_screen, main_window, user_account):
    with step('Open import seed phrase view and enter seed phrase'):
        input_view = keys_screen.open_import_seed_phrase_view().open_seed_phrase_input_view()
        profile_view = input_view.input_seed_phrase(user_account.seed_phrase)
        profile_view.set_display_name(user_account.name)

    with step('Finalize onboarding and open main screen'):
        details_view = profile_view.next()
        create_password_view = details_view.next()
        confirm_password_view = create_password_view.create_password(user_account.password)
        confirm_password_view.confirm_password(user_account.password)
        if configs.system.IS_MAC:
            TouchIDAuthView().wait_until_appears().prefer_password()
        SplashScreen().wait_until_appears().wait_until_hidden()
        if not configs.DEV_BUILD:
            WelcomeStatusPopup().confirm()

    with step('Verify that the user logged in via seed phrase correctly'):
        user_canvas = main_window.left_panel.open_user_canvas()
        profile_popup = user_canvas.open_profile_popup()
        assert profile_popup.user_name == user_account.name

    aut.restart()
    main_window.authorize_user(user_account)
