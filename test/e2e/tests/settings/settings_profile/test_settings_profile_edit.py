import allure
import pytest
from allure_commons._allure import step

from constants import UserAccount, RandomUser
from scripts.utils.generators import random_name_string
from . import marks

import constants
from driver.aut import AUT
from gui.components.changes_detected_popup import ChangesDetectedToastMessage
from gui.main_window import MainWindow

pytestmark = marks


@allure.testcase('https://ethstatus.testrail.net/index.php?/cases/view/703006',
                 'Set display name, bio and social links')
@pytest.mark.case(703006)
@pytest.mark.parametrize('user_account',
                         [
                             pytest.param(
                                 RandomUser())
                         ])
@pytest.mark.parametrize('bio, links', [pytest.param('This is my bio', constants.social_links)])
def test_set_name_bio_social_links(main_screen: MainWindow, aut: AUT, user_account, bio, links):
    with step('Open profile settings and check name, bio and links'):
        profile_settings = main_screen.left_panel.open_settings().left_panel.open_profile_settings()
        assert profile_settings.get_display_name == user_account.name
        assert profile_settings.get_bio == ''
        assert len(profile_settings.get_social_links) == 0

    with (step('Set new name, bio and links')):
        new_user_name = random_name_string()
        profile_settings.set_name(new_user_name)
        profile_settings.set_bio(bio)
        ChangesDetectedToastMessage().click_save_changes_button()
        assert ChangesDetectedToastMessage().is_visible is False, \
            f'Bottom floating buttons are not hidden'
        assert \
            main_screen.left_panel.open_online_identifier().open_profile_popup_from_online_identifier().user_name \
            == new_user_name, \
            f'Display name was not applied after changing'
        main_screen.left_panel.click()
        profile_settings.set_social_links(links)
        ChangesDetectedToastMessage().click_save_changes_button()
        assert ChangesDetectedToastMessage().is_visible is False, \
            f'Bottom floating buttons are not hidden'
        assert len(profile_settings.get_social_links) > 0, f'No social links were added'

    with step('Restart application'):
        aut.restart()
        main_screen.authorize_user(user_account=UserAccount(name=new_user_name, password=user_account.password))

    with step('Open profile settings and check new name, bio and links'):
        profile_settings = main_screen.left_panel.open_settings().left_panel.open_profile_settings()
        assert profile_settings.get_display_name == new_user_name
        assert profile_settings.get_bio == bio
        profile_settings.verify_social_links(links)
