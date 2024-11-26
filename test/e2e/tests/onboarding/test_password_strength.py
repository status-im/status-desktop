import allure
import pytest
from allure_commons._allure import step

from helpers.OnboardingHelper import open_generate_new_keys_view
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
    expected_password = ""

    keys_screen = open_generate_new_keys_view()

    with step('Input correct user name'):
        profile_view = keys_screen.generate_new_keys()
        profile_view.set_display_name(user_account.name)

    with step('Verify that correct strength indicator color, text and green messages appear'):
        create_password_view = profile_view.next()

        for (input_text, expected_indicator) in values:
            expected_password = input_text
            create_password_view.set_password_in_first_field(input_text)
            assert create_password_view.strength_indicator_color == expected_indicator[1]
            assert str(create_password_view.strength_indicator_text) == expected_indicator[0]
            assert sorted(create_password_view.green_indicator_messages) == sorted(expected_indicator[2])
            assert not create_password_view.is_create_password_button_enabled

    with step('Toggle view/hide password buttons'):
        create_password_view.set_password_in_confirmation_field(expected_password)
        assert create_password_view.is_create_password_button_enabled

        create_password_view.click_show_icon(0)
        assert create_password_view.get_password_from_first_field() == expected_password

        create_password_view.click_hide_icon(0)

        create_password_view.click_show_icon(1)
        assert create_password_view.get_password_from_confirmation_field() == expected_password

        create_password_view.click_hide_icon(0)

    with step('Confirm creation of password and set password in confirmation again field'):
        confirm_password_view = create_password_view.click_create_password()
        assert not confirm_password_view.is_confirm_password_button_enabled

        confirm_password_view.set_password(expected_password)
        assert confirm_password_view.is_confirm_password_button_enabled

    with step('Click show icon to show password and check that shown password is correct'):
        create_password_view.click_show_icon(0)
        assert confirm_password_view.get_password_from_confirmation_again_field() == expected_password


