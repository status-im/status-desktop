import time

import allure
import pytest
from allure_commons._allure import step

from gui.main_window import MainWindow
from . import marks

from constants import UserAccount
from scripts.utils.generators import random_password_string
from constants.onboarding import OnboardingMessages
from driver.aut import AUT
from gui.screens.onboarding import ReturningLoginView, OnboardingWelcomeToStatusView

pytestmark = marks


@pytest.mark.case(702991)
@pytest.mark.parametrize('error', [OnboardingMessages.PASSWORD_INCORRECT.value
                                   ])
def test_login_with_wrong_password(aut: AUT, main_screen: MainWindow, user_account, error: str):

    with step('Verify that the user logged in correctly'):
        user_image = main_screen.left_panel.open_online_identifier()
        profile_popup = user_image.open_profile_popup_from_online_identifier()
        assert profile_popup.user_name == user_account.name

    with step('Restart application and input wrong password'):
        aut.restart()
        main_screen.prepare()
        login_view = ReturningLoginView()
        login_view.log_in(UserAccount(
            name=user_account.name,
            password=random_password_string()
        ))

    with step('Verify that user cannot log in and the error appears'):
        assert error in str(login_view.password_box.object.validationError)


@pytest.mark.case(702993)
@pytest.mark.parametrize('error', [
    pytest.param(OnboardingMessages.WRONG_PASSWORD.value),
])
def test_sign_up_with_wrong_password_length(user_account, error: str, aut: AUT, main_window):

    welcome_screen = OnboardingWelcomeToStatusView().wait_until_appears()
    profile_view = welcome_screen.open_create_your_profile_view()
    create_password_view = profile_view.open_password_view()

    with step('Input wrong password in both first and confirmation fields'):
        create_password_view.set_password_in_first_field(user_account.password[:8])
        create_password_view.set_password_in_repeat_field(user_account.password[:8])

    with step('Verify that Continue button is disabled and correct error appears'):
        assert not create_password_view.confirm_password_button.is_visible
        assert str(create_password_view.create_password_view.object.strengthenText) == error


@pytest.mark.case(702999)
@pytest.mark.parametrize('seed_phrase', [
    pytest.param('pelican chief sudden oval media rare swamp elephant lawsuit wheal knife initial'),
])
def test_sign_up_with_wrong_seed_phrase(seed_phrase: str, aut: AUT, main_window):

    welcome_screen = OnboardingWelcomeToStatusView().wait_until_appears()
    profile_view = welcome_screen.open_create_your_profile_view()
    input_seed_view = profile_view.open_seed_phrase_view()

    with step('Open import seed phrase view and enter seed phrase'):
        input_seed_view.fill_in_seed_phrase_grid(seed_phrase.split(), False)

    with step('Verify that import button is disabled'):
        assert not input_seed_view.continue_button.is_visible
