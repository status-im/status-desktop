import os
import random
import string
import time

import allure
import pytest
from allure_commons._allure import step
from . import marks

import configs.system
import constants
from constants import UserAccount
from constants.onboarding import OnboardingMessages
from driver.aut import AUT
from gui.components.onboarding.before_started_popup import BeforeStartedPopUp
from gui.components.onboarding.beta_consent_popup import BetaConsentPopup
from gui.components.splash_screen import SplashScreen
from gui.screens.onboarding import AllowNotificationsView, WelcomeToStatusView, KeysView, BiometricsView, LoginView

pytestmark = marks


@pytest.fixture
def keys_screen(main_window) -> KeysView:
    with step('Open Generate new keys view'):
        if configs.system.IS_MAC:
            AllowNotificationsView().wait_until_appears().allow()
        BeforeStartedPopUp().get_started()
        wellcome_screen = WelcomeToStatusView().wait_until_appears()
        return wellcome_screen.get_keys()


@allure.testcase('https://ethstatus.testrail.net/index.php?/cases/view/702991', 'Login with an invalid password')
@pytest.mark.case(702991)
@pytest.mark.parametrize('error', [OnboardingMessages.PASSWORD_INCORRECT.value
                                   ])
def test_login_with_wrong_password(aut: AUT, keys_screen, main_window, error: str):
    user_one: UserAccount = constants.user_account_one
    user_one_wrong_password: UserAccount = constants.user_account_one_changed_password

    with step('Open generate keys view and set user name'):
        profile_view = keys_screen.generate_new_keys()
        profile_view.set_display_name(user_one.name)

    with step('Finalize onboarding and open main screen'):
        details_view = profile_view.next()
        create_password_view = details_view.next()
        confirm_password_view = create_password_view.create_password(user_one.password)
        confirm_password_view.confirm_password(user_one.password)
        if configs.system.IS_MAC:
            BiometricsView().wait_until_appears().prefer_password()
        SplashScreen().wait_until_appears().wait_until_hidden()
        if not configs.system.TEST_MODE:
            BetaConsentPopup().confirm()

    with step('Verify that the user logged in correctly'):
        user_canvas = main_window.left_panel.open_online_identifier()
        profile_popup = user_canvas.open_profile_popup_from_online_identifier()
        assert profile_popup.user_name == user_one.name

    with step('Restart application and input wrong password'):
        aut.restart()
        login_view = LoginView()
        login_view.log_in(user_one_wrong_password)
        time.sleep(2)

    with step('Verify that user cannot log in and the error appears'):
        assert login_view.login_error_message == error


@allure.testcase('https://ethstatus.testrail.net/index.php?/cases/view/702992', 'Sign up with wrong username format')
@pytest.mark.case(702992)
@pytest.mark.parametrize('user_name, error', [
    pytest.param('Athl', OnboardingMessages.WRONG_LOGIN_LESS_LETTERS.value),
    pytest.param('Gra', OnboardingMessages.WRONG_LOGIN_LESS_LETTERS.value),
    pytest.param('tester3@', OnboardingMessages.WRONG_LOGIN_SYMBOLS_NOT_ALLOWED.value),
    pytest.param(''.join(random.choice(string.punctuation) for i in range(5, 25)),
                 OnboardingMessages.WRONG_LOGIN_SYMBOLS_NOT_ALLOWED.value)
])
def test_sign_up_with_wrong_name(keys_screen, user_name: str, error: str):
    with step(f'Input name {user_name}'):
        profile_view = keys_screen.generate_new_keys()
        profile_view.set_display_name(user_name)

    with step('Verify that button Next is disabled and correct error appears'):
        assert profile_view.is_next_button_enabled is False
        assert profile_view.get_error_message == error

    with step('Clear content of disply name field and verify it is empty'):
        profile_view.clear_field()
        assert profile_view.get_display_name() == ''


@allure.testcase('https://ethstatus.testrail.net/index.php?/cases/view/702993',
                 'Sign up with wrong password format in both new password and confirmation input')
@pytest.mark.case(702993)
@pytest.mark.parametrize('user_account', [constants.user.user_account_one])
@pytest.mark.parametrize('password, error', [
    pytest.param('badP', OnboardingMessages.WRONG_PASSWORD.value),
])
def test_sign_up_with_wrong_password_in_both_fields(keys_screen, user_account, password: str, error: str):
    with step('Input correct user name'):
        profile_view = keys_screen.generate_new_keys()
        profile_view.set_display_name(user_account.name)

    with step('Input wrong password in both first and confirmation fields'):
        details_view = profile_view.next()
        create_password_view = details_view.next()
        create_password_view.set_password_in_first_field(password)
        create_password_view.set_password_in_confirmation_field(password)

    with step('Verify that button Create password is disabled and correct error appears'):
        assert create_password_view.is_create_password_button_enabled is False
        assert create_password_view.password_error_message == error


@allure.testcase('https://ethstatus.testrail.net/index.php?/cases/view/702994',
                 'Sign up with right password format in new password input but incorrect in confirmation password input')
@pytest.mark.case(702994)
@pytest.mark.parametrize('user_account', [constants.user.user_account_one])
@pytest.mark.parametrize('first_password, confirmation_password', [
    pytest.param('TesTEr16843/!@01', 'bad2!s'),
])
def test_sign_up_with_wrong_password_in_confirmation_field(keys_screen, user_account, first_password: str,
                                                           confirmation_password: str):
    with step('Input correct user name'):
        profile_view = keys_screen.generate_new_keys()
        profile_view.set_display_name(user_account.name)

    with step('Input correct password in first field and wrong password in confirmation field'):
        details_view = profile_view.next()
        create_password_view = details_view.next()
        create_password_view.set_password_in_first_field(first_password)
        create_password_view.set_password_in_confirmation_field(confirmation_password)

    with step('Verify that button Create password is disabled'):
        assert create_password_view.is_create_password_button_enabled is False


@allure.testcase('https://ethstatus.testrail.net/index.php?/cases/view/702995',
                 'Sign up with incorrect confirmation-again password')
@pytest.mark.case(702995)
@pytest.mark.parametrize('user_account', [constants.user.user_account_one])
@pytest.mark.parametrize('password, confirmation_again_password, error', [
    pytest.param('TesTEr16843/!@01', 'TesTEr16843/!@)', OnboardingMessages.PASSWORDS_DONT_MATCH.value),
])
def test_sign_up_with_wrong_password_in_confirmation_again_field(keys_screen, user_account, password: str,
                                                                 confirmation_again_password: str, error: str):
    with step('Input correct user name'):
        profile_view = keys_screen.generate_new_keys()
        profile_view.set_display_name(user_account.name)

    with step('Input correct password in both first and confirmation fields'):
        details_view = profile_view.next()
        create_password_view = details_view.next()
        confirm_password_view = create_password_view.create_password(password)

    with step('Input wrong password in confirmation again field'):
        confirm_password_view.set_password(confirmation_again_password)

    with step('Verify that button Finalise Status Password Creation is disabled and correct error appears'):
        assert confirm_password_view.is_confirm_password_button_enabled is False
        assert confirm_password_view.confirmation_error_message == error


@allure.testcase('https://ethstatus.testrail.net/index.php?/cases/view/702999',
                 'Sign up with wrong imported seed phrase')
@pytest.mark.case(702999)
@pytest.mark.parametrize('seed_phrase', [
    pytest.param('pelican chief sudden oval media rare swamp elephant lawsuit wheal knife initial'),
])
def test_sign_up_with_wrong_seed_phrase(keys_screen, seed_phrase: str):
    with step('Open import seed phrase view and enter seed phrase'):
        input_view = keys_screen.open_import_seed_phrase_view().open_seed_phrase_input_view()
        input_view.input_seed_phrase(seed_phrase.split(), autocomplete=False)

    with step('Verify that import button is disabled'):
        assert input_view.is_import_button_enabled is False
