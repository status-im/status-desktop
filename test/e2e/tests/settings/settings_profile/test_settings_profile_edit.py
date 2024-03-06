import allure
import pytest
from allure_commons._allure import step
from . import marks

import constants
from driver.aut import AUT
from gui.components.changes_detected_popup import ChangesDetectedToastMessage
from gui.main_window import MainWindow

pytestmark = marks


@allure.testcase('https://ethstatus.testrail.net/index.php?/cases/view/703006',
                 'Set display name, bio and social links')
@pytest.mark.case(703006)
@pytest.mark.parametrize('user_account, user_account_changed',
                         [pytest.param(constants.user.user_account_one, constants.user.user_account_one_changed_name)])
@pytest.mark.parametrize('bio, links', [pytest.param('This is my bio', constants.social_links)])
@pytest.mark.skip(reason='https://github.com/status-im/status-desktop/issues/13868')
def test_set_name_bio_social_links(main_screen: MainWindow, aut: AUT, user_account, user_account_changed, bio, links):
    with step('Open profile settings and check name, bio and links'):
        profile_settings = main_screen.left_panel.open_settings().left_panel.open_profile_settings()
        assert profile_settings.display_name == user_account.name
        assert profile_settings.bio == ''
        for value in profile_settings.social_links.values():
            assert value == ''

    with step('Set new name, bio and links'):
        profile_settings.set_name(user_account_changed.name)
        profile_settings.bio = bio
        profile_settings.social_links = links
        ChangesDetectedToastMessage().save()

    with step('Restart application'):
        aut.restart()
        main_screen.authorize_user(user_account_changed)

    with step('Open profile settings and check new name, bio and links'):
        profile_settings = main_screen.left_panel.open_settings().left_panel.open_profile_settings()
        assert profile_settings.display_name == user_account_changed.name
        assert profile_settings.bio == bio
        profile_settings.verify_social_links(links)
