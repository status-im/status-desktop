import allure
import pytest
from allure_commons._allure import step
from . import marks

import configs.system
import constants
from constants.onboarding import very_weak_lower_elements, very_weak_upper_elements, \
    very_weak_numbers_elements, very_weak_symbols_elements, weak_elements, so_so_elements, good_elements, great_elements
from gui.components.onboarding.before_started_popup import BeforeStartedPopUp
from gui.screens.onboarding import AllowNotificationsView, WelcomeToStatusView, KeysView

pytestmark = marks

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
def test_check_password_strength_and_login(keys_screen, main_window, user_account):
    values = [('abcdefghij', very_weak_lower_elements),
              ('ABCDEFGHIJ', very_weak_upper_elements),
              ('1234567890', very_weak_numbers_elements),
              ('+_!!!!!!!!', very_weak_symbols_elements),
              ('+1_3!48888', weak_elements),
              ('+1_3!48a11', so_so_elements),
              ('+1_3!48aT1', good_elements),
              ('+1_3!48aTq', great_elements)]
    expected_password = ""

    with step('Input correct user name'):
        profile_view = keys_screen.generate_new_keys()
        profile_view.set_display_name(user_account.name)

    with step('Verify that correct strength indicator color, text and green messages appear'):
        details_view = profile_view.next()
        create_password_view = details_view.next()

        for (input_text, expected_indicator) in values:
            expected_password = input_text
            create_password_view.set_password_in_first_field(input_text)
            assert create_password_view.strength_indicator_color == expected_indicator[1]
            assert create_password_view.strength_indicator_text == expected_indicator[0]
            assert sorted(create_password_view.green_indicator_messages) == sorted(expected_indicator[2])
            assert not create_password_view.is_create_password_button_enabled

    with step('Toggle view/hide password buttons'):
        create_password_view.set_password_in_confirmation_field(expected_password)
        assert create_password_view.is_create_password_button_enabled

        create_password_view.click_show_icon(0)
        assert create_password_view.get_password_from_first_field(0) == expected_password

        create_password_view.click_hide_icon(0)
        assert create_password_view.get_password_from_first_field(2) == '••••••••••'

        create_password_view.click_show_icon(1)
        assert create_password_view.get_password_from_confirmation_field(0) == expected_password

        create_password_view.click_hide_icon(0)
        assert create_password_view.get_password_from_confirmation_field(2) == '••••••••••'

    with step('Confirm creation of password and set password in confirmation again field'):
        confirm_password_view = create_password_view.click_create_password()
        assert not confirm_password_view.is_confirm_password_button_enabled

        confirm_password_view.set_password(expected_password)
        assert confirm_password_view.is_confirm_password_button_enabled

    with step('Click show icon to show password and check that shown password is correct'):
        create_password_view.click_show_icon(0)
        assert confirm_password_view.get_password_from_confirmation_again_field(0) == expected_password

    with step('Click show icon to hide password and check that there are dots instead'):
        create_password_view.click_hide_icon(0)
        assert confirm_password_view.get_password_from_confirmation_again_field(2) == '••••••••••'
