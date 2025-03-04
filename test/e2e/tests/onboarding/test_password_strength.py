import allure
import pytest

from gui.screens.onboarding import OnboardingWelcomeToStatusView
from . import marks

from constants.onboarding import very_weak_lower_elements, very_weak_upper_elements, \
    very_weak_numbers_elements, very_weak_symbols_elements, weak_elements, okay_elements, good_elements, strong_elements

pytestmark = marks


@allure.testcase('https://ethstatus.testrail.net/index.php?/cases/view/702989',
                 'Strength of the password')
@pytest.mark.case(702989)
def test_check_password_strength_and_login(main_window, user_account):
    values = [('abcdefghij', very_weak_lower_elements),
              ('ABCDEFGHIJ', very_weak_upper_elements),
              ('1234567890', very_weak_numbers_elements),
              ('+_!!!!!!!!', very_weak_symbols_elements),
              ('+1_3!48888', weak_elements),
              ('+1_3!48a11', okay_elements),
              ('+1_3!48aT1', good_elements),
              ('+1_3!48aTq', strong_elements)]

    welcome_screen = OnboardingWelcomeToStatusView().wait_until_appears()
    profile_view = welcome_screen.open_create_your_profile_view()
    create_password_view = profile_view.open_password_view()

    for (input_text, expected_indicator) in values:
        create_password_view.set_password_in_first_field(input_text)
        assert create_password_view.strength_indicator_color == expected_indicator[1]
        assert str(create_password_view.strength_indicator_text) == expected_indicator[0]
        assert sorted(create_password_view.green_indicator_messages) == sorted(expected_indicator[2])
        assert not create_password_view.confirm_password_button.is_visible
