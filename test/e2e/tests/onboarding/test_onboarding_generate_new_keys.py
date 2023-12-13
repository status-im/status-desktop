import logging
import os

import allure
import pytest
from allure import step
from . import marks

import configs.timeouts
from gui.components.onboarding.before_started_popup import BeforeStartedPopUp
from gui.components.onboarding.beta_consent_popup import BetaConsentPopup
from gui.components.picture_edit_popup import shift_image
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
@pytest.mark.case(703421)
@pytest.mark.parametrize('user_name, password, user_image, zoom, shift', [
    pytest.param('Test-User _1', '*P@ssw0rd*', None, None, None, marks=pytest.mark.critical),
    pytest.param('Test-User', '*P@ssw0rd*', 'tv_signal.png', 5, shift_image(0, 0, 0, 0)),
    pytest.param('_1Test-User', '*P@ssw0rd*', 'tv_signal.jpeg', 5, shift_image(0, 1000, 1000, 0))
])
def test_generate_new_keys(main_window, keys_screen, user_name: str, password, user_image: str, zoom: int, shift):
    with step(f'Setup profile with name: {user_name} and image: {user_image}'):

        keys_screen.generate_new_keys().back()
        profile_view = keys_screen.generate_new_keys()
        assert profile_view.is_next_button_enabled is False
        profile_view.set_display_name(user_name)
        if user_image is not None:
            profile_picture_popup = profile_view.set_user_image(configs.testpath.TEST_FILES / user_image)
            profile_picture_popup.make_picture(zoom=zoom, shift=shift)
        assert not profile_view.error_message

    with step('Open Profile details view and verify user info'):

        details_view = profile_view.next()
        chat_key = details_view.chat_key
        emoji_hash = details_view.emoji_hash
        assert details_view.is_identicon_ring_visible
        details_view.back().next()

    with step('Finalize onboarding and open main screen'):

        create_password_view = details_view.next()
        create_password_view.back().next()
        assert not create_password_view.is_create_password_button_enabled
        confirm_password_view = create_password_view.create_password(password)
        confirm_password_view.back().click_create_password()
        confirm_password_view.confirm_password(password)
        if configs.system.IS_MAC:
            assert BiometricsView().is_touch_id_button_visible(), f"TouchID button is not found"
            BiometricsView().wait_until_appears().prefer_password()
        SplashScreen().wait_until_appears().wait_until_hidden()
        if not configs.system.TEST_MODE:
            BetaConsentPopup().confirm()

    with step('Open User Canvas and verify user info'):

        user_canvas = main_window.left_panel.open_online_identifier()
        assert user_canvas.user_name == user_name

    with step('Open Profile popup and verify user info'):

        profile_popup = user_canvas.open_profile_popup_from_online_identifier()
        assert profile_popup.user_name == user_name
        assert profile_popup.chat_key == chat_key
