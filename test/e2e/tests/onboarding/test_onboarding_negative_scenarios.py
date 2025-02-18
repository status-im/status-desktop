import random
import string
import time

import allure
import pytest
from allure_commons._allure import step

from gui.components.signing_phrase_popup import SigningPhrasePopup
from helpers.OnboardingHelper import open_generate_new_keys_view
from . import marks

import configs.system
from constants import UserAccount, RandomUser
from scripts.utils.generators import random_password_string
from constants.onboarding import OnboardingMessages
from driver.aut import AUT
from gui.components.splash_screen import SplashScreen
from gui.screens.onboarding import BiometricsView, LoginView, \
    YourEmojihashAndIdenticonRingView

pytestmark = marks


@allure.testcase('https://ethstatus.testrail.net/index.php?/cases/view/702991', 'Login with an invalid password')
@pytest.mark.case(702991)
@pytest.mark.parametrize('error', [OnboardingMessages.PASSWORD_INCORRECT.value
                                   ])
def test_login_with_wrong_password(aut: AUT, main_window, error: str):
    user_one: UserAccount = RandomUser()

    keys_screen = open_generate_new_keys_view()

    with step('Open generate keys view and set user name'):
        profile_view = keys_screen.generate_new_keys()
        profile_view.set_display_name(user_one.name)

    with step('Finalize onboarding and open main screen'):
        create_password_view = profile_view.next()
        confirm_password_view = create_password_view.create_password(user_one.password)
        confirm_password_view.confirm_password(user_one.password)
        if configs.system.get_platform() == "Darwin":
            BiometricsView().wait_until_appears().prefer_password()
        SplashScreen().wait_until_appears().wait_until_hidden(timeout_msec=90000)
        next_view = YourEmojihashAndIdenticonRingView().verify_emojihash_view_present().next()
        if configs.system.get_platform() == "Darwin":
            next_view.start_using_status()
        SplashScreen().wait_until_appears().wait_until_hidden(timeout_msec=90000)
        if SigningPhrasePopup().is_visible:
            SigningPhrasePopup().confirm_phrase()

    with step('Verify that the user logged in correctly'):
        user_image = main_window.left_panel.open_online_identifier()
        profile_popup = user_image.open_profile_popup_from_online_identifier()
        assert profile_popup.user_name == user_one.name

    with step('Restart application and input wrong password'):
        aut.restart()
        login_view = LoginView()
        login_view.log_in(UserAccount(
            name=user_one.name,
            password=random_password_string()
        ))
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
def test_sign_up_with_wrong_name(aut: AUT, main_window, user_name, error):
    keys_screen = open_generate_new_keys_view()

    with step(f'Input name Athl'):
        profile_view = keys_screen.generate_new_keys()
        profile_view.set_display_name(user_name)

    with step('Verify that button Next is disabled and correct error appears'):
        assert profile_view.is_next_button_enabled is False
        assert profile_view.get_error_message == error

    with step('Clear content of disply name field and verify it is empty'):
        profile_view.clear_field()
        assert profile_view.get_display_name() == ''


@allure.testcase('https://ethstatus.testrail.net/index.php?/cases/view/702993',
                 'Sign up with password shorter than 10 chars')
@pytest.mark.case(702993)
@pytest.mark.parametrize('error', [
    pytest.param(OnboardingMessages.WRONG_PASSWORD.value),
])
def test_sign_up_with_wrong_password_length(user_account, error: str, aut: AUT, main_window):
    keys_screen = open_generate_new_keys_view()

    with step('Input correct user name'):
        profile_view = keys_screen.generate_new_keys()
        profile_view.set_display_name(user_account.name)

    with step('Input wrong password in both first and confirmation fields'):
        create_password_view = profile_view.next()
        create_password_view.set_password_in_first_field(user_account.password[:8])
        create_password_view.set_password_in_confirmation_field(user_account.password[:8])

    with step('Verify that button Create password is disabled and correct error appears'):
        assert create_password_view.is_create_password_button_enabled is False
        assert str(create_password_view.password_error_message) == error


@allure.testcase('https://ethstatus.testrail.net/index.php?/cases/view/702994',
                 'Sign up with right password format in new password input but incorrect in confirmation password input')
@pytest.mark.case(702994)
def test_sign_up_with_wrong_password_in_confirmation_field(user_account, aut: AUT, main_window):
    keys_screen = open_generate_new_keys_view()

    with step('Input correct user name'):
        profile_view = keys_screen.generate_new_keys()
        profile_view.set_display_name(user_account.name)

    with step('Input correct password in first field and wrong password in confirmation field'):
        create_password_view = profile_view.next()
        create_password_view.set_password_in_first_field(user_account.password)
        create_password_view.set_password_in_confirmation_field(random_password_string())

    with step('Verify that button Create password is disabled'):
        assert create_password_view.is_create_password_button_enabled is False


@allure.testcase('https://ethstatus.testrail.net/index.php?/cases/view/702995',
                 'Sign up with incorrect confirmation-again password')
@pytest.mark.case(702995)
@pytest.mark.parametrize('error', [
    pytest.param(OnboardingMessages.PASSWORDS_DONT_MATCH.value),
])
def test_sign_up_with_wrong_password_in_confirmation_again_field(user_account,
                                                                 error: str, aut: AUT, main_window):
    keys_screen = open_generate_new_keys_view()

    with step('Input correct user name'):
        profile_view = keys_screen.generate_new_keys()
        profile_view.set_display_name(user_account.name)

    with step('Input correct password in both first and confirmation fields'):
        create_password_view = profile_view.next()
        confirm_password_view = create_password_view.create_password(user_account.password)

    with step('Input wrong password in confirmation again field'):
        confirm_password_view.set_password(random_password_string())

    with step('Verify that button Finalise Status Password Creation is disabled and correct error appears'):
        assert confirm_password_view.is_confirm_password_button_enabled is False
        assert confirm_password_view.confirmation_error_message == error


@allure.testcase('https://ethstatus.testrail.net/index.php?/cases/view/702999',
                 'Sign up with wrong imported seed phrase')
@pytest.mark.case(702999)
@pytest.mark.parametrize('seed_phrase', [
    pytest.param('pelican chief sudden oval media rare swamp elephant lawsuit wheal knife initial'),
])
def test_sign_up_with_wrong_seed_phrase(seed_phrase: str, aut: AUT, main_window):
    keys_screen = open_generate_new_keys_view()

    with step('Open import seed phrase view and enter seed phrase'):
        input_view = keys_screen.open_import_seed_phrase_view().open_seed_phrase_input_view()
        input_view.input_seed_phrase(seed_phrase.split(), False)

    with step('Verify that import button is disabled'):
        assert input_view.is_import_button_enabled is False
