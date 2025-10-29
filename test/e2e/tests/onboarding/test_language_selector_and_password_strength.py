import random

import allure
import pytest
from allure_commons._allure import step

from gui.screens.onboarding import OnboardingWelcomeToStatusView
from . import marks

from constants.onboarding import very_weak_lower_elements, very_weak_upper_elements, \
    very_weak_numbers_elements, very_weak_symbols_elements, weak_elements, okay_elements, good_elements, \
    strong_elements, LanguageCodes

pytestmark = marks


@pytest.mark.case(702989)
def test_check_language_selector_password_strength_and_login(main_window, user_account):

    with step('Verify user can change language on onboarding screen'):
        welcome_screen = OnboardingWelcomeToStatusView().wait_until_appears()
        assert welcome_screen.language_selector.object.text == LanguageCodes.ENGLISH.value, f'English should be default'

        selector = welcome_screen.open_language_selector()
        new_language = random.choice([LanguageCodes.KOREAN.value, LanguageCodes.CZECH.value])
        selector.select_language(new_language.lower())

        assert welcome_screen.create_profile_button.object.text != 'Create profile', f'Language was not changed'

        welcome_screen.open_language_selector().select_language(LanguageCodes.ENGLISH.value.lower())

        assert welcome_screen.language_selector.object.text == LanguageCodes.ENGLISH.value, f'Language was not changed'

    with step('Verify password strength'):
        values = [('abcdefghij', very_weak_lower_elements),
                  ('ABCDEFGHIJ', very_weak_upper_elements),
                  ('1234567890', very_weak_numbers_elements),
                  ('+_!!!!!!!!', very_weak_symbols_elements),
                  ('+1_3!48888', weak_elements),
                  ('+1_3!48a11', okay_elements),
                  ('+1_3!48aT1', good_elements),
                  ('+1_3!48aTq', strong_elements)]

        profile_view = welcome_screen.open_create_your_profile_view()
        create_password_view = profile_view.open_password_view()

        for (input_text, expected_indicator) in values:
            create_password_view.set_password_in_first_field(input_text)
            assert create_password_view.strength_indicator_color == expected_indicator[1]
            assert str(create_password_view.strength_indicator_text) == expected_indicator[0]
            assert sorted(create_password_view.green_indicator_messages) == sorted(expected_indicator[2])
            assert not create_password_view.confirm_password_button.is_visible
