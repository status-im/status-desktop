import os

import allure
import pytest
from allure_commons._allure import step

import configs.system
import constants
from constants.onboarding import very_weak_lower_elements, very_weak_upper_elements, \
    very_weak_numbers_elements, very_weak_symbols_elements, weak_elements, so_so_elements, good_elements, great_elements
from gui.components.onboarding.before_started_popup import BeforeStartedPopUp
from gui.components.onboarding.beta_consent_popup import BetaConsentPopup
from gui.components.splash_screen import SplashScreen
from gui.screens.onboarding import AllowNotificationsView, WelcomeToStatusView, KeysView, BiometricsView


@pytest.fixture
def keys_screen(main_window) -> KeysView:
    with step('Open Generate new keys view'):
        if configs.system.IS_MAC:
            AllowNotificationsView().wait_until_appears().allow()
        BeforeStartedPopUp().get_started()
        wellcome_screen = WelcomeToStatusView().wait_until_appears()
        return wellcome_screen.get_keys()


@allure.testcase('https://ethstatus.testrail.net/index.php?/cases/view/702989',
                 'Strength of the password')
@pytest.mark.case(702989)
@pytest.mark.parametrize('user_account', [constants.user.user_account_one])
@pytest.mark.parametrize('password, password_strength_elements', [
    pytest.param('abcdefghij', very_weak_lower_elements),
    pytest.param('ABCDEFGHIJ', very_weak_upper_elements),
    pytest.param('1234567890', very_weak_numbers_elements),
    pytest.param('+_!!!!!!!!', very_weak_symbols_elements),
    pytest.param('+1_3!48888', weak_elements),
    pytest.param('+1_3!48a11', so_so_elements),
    pytest.param('+1_3!48aT1', good_elements),
    pytest.param('+1_3!48aTq', great_elements)
])
def test_check_password_strength_and_login(keys_screen, main_window, user_account, password: str,
                                           password_strength_elements):
    with step('Input correct user name'):
        profile_view = keys_screen.generate_new_keys()
        profile_view.set_display_name(user_account.name)

    with step('Input password'):
        details_view = profile_view.next()
        create_password_view = details_view.next()
        create_password_view.set_password_in_first_field(password)

    with step('Click show icon to show password and check that shown password is correct'):
        create_password_view.click_show_icon(0)
        assert create_password_view.get_password_from_first_field(0) == password

    with step('Click show icon to hide password and check that there are dots instead'):
        create_password_view.click_hide_icon(0)
        assert create_password_view.get_password_from_first_field(2) == '●●●●●●●●●●'

    with step('Verify that correct strength indicator color, text and green messages appear'):
        assert create_password_view.strength_indicator_color == password_strength_elements[1]
        assert create_password_view.strength_indicator_text == password_strength_elements[0]
        assert sorted(create_password_view.green_indicator_messages) == sorted(password_strength_elements[2])

    with step('Enter password to confirmation field'):
        create_password_view.set_password_in_confirmation_field(password)

    with step('Click show icon to show password and check that shown password is correct'):
        create_password_view.click_show_icon(1)
        assert create_password_view.get_password_from_confirmation_field(0) == password

    with step('Click show icon to hide password and check that there are dots instead'):
        create_password_view.click_hide_icon(0)
        assert create_password_view.get_password_from_confirmation_field(2) == '●●●●●●●●●●'

    with step('Confirm creation of password and set password in confirmation again field'):
        confirm_password_view = create_password_view.click_create_password()
        confirm_password_view.set_password(password)

    with step('Click show icon to show password and check that shown password is correct'):
        create_password_view.click_show_icon(0)
        assert confirm_password_view.get_password_from_confirmation_again_field(0) == password

    with step('Click show icon to hide password and check that there are dots instead'):
        create_password_view.click_hide_icon(0)
        assert confirm_password_view.get_password_from_confirmation_again_field(2) == '●●●●●●●●●●'

    with step('Verify that the user can login afterwards'):
        confirm_password_view.click_confirm_password()
        if configs.system.IS_MAC:
            BiometricsView().wait_until_appears().prefer_password()
        SplashScreen().wait_until_appears().wait_until_hidden()
        if not configs.system.TEST_MODE:
            BetaConsentPopup().confirm()

    with step('Verify that the user logged in correctly'):
        user_canvas = main_window.left_panel.open_user_canvas()
        profile_popup = user_canvas.open_profile_popup()
        assert profile_popup.user_name == user_account.name
