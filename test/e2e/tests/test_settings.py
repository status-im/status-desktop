import time

import allure
import pytest
from allure import step

import constants
from constants.social_links import social_links
from driver.aut import AUT
from gui.components.back_up_your_seed_phrase_banner import BackUpSeedPhraseBanner
from gui.components.settings.changes_detected_popup import ChangesDetectedToastMessage
from gui.main_window import MainWindow

pytestmark = allure.suite("Settings")


@allure.testcase('https://ethstatus.testrail.net/index.php?/cases/view/703007',
                 'Change own display name in profile popup')
@pytest.mark.case(703007)
@pytest.mark.parametrize('user_account', [constants.user.user_account_one])
@pytest.mark.parametrize('new_name', [pytest.param('NewUserName')])
def test_change_own_display_name(main_screen: MainWindow, user_account, new_name):
    with step('Open own profile popup and check name of user is correct'):
        profile = main_screen.left_panel.open_user_canvas()
        profile_popup = profile.open_profile_popup()
        assert profile_popup.user_name == user_account.name

    with step('Go to edit profile settings and change the name of the user'):
        profile_popup.edit_profile().set_name(new_name)

    with step('Open own profile popup and check name of user is correct'):
        assert main_screen.left_panel.open_user_canvas().open_profile_popup().user_name == new_name


@allure.testcase('https://ethstatus.testrail.net/index.php?/cases/view/703002', 'Switch state to offline')
@pytest.mark.case(703002)
def test_switch_states_between_offline_and_online(aut: AUT, main_screen: MainWindow, user_account):
    with (step('Open settings and switch state to offline')):
        settings = main_screen.left_panel
        settings.set_user_to_offline()

    with step('Verify user appears offline'):
        assert settings.user_is_offline()

    with step('Restart application'):
        aut.restart()
        main_screen.authorize_user(user_account)

    with step('Verify user appears offline'):
        assert settings.user_is_offline()

    with (step('Open settings and switch state to online')):
        settings = main_screen.left_panel
        settings.set_user_to_online()

    with step('Restart application'):
        aut.restart()
        main_screen.authorize_user(user_account)

    with step('Verify user appears online'):
        assert settings.user_is_online()


@allure.testcase('https://ethstatus.testrail.net/index.php?/cases/view/703004', 'Switch state to automatic')
@pytest.mark.case(703004)
def test_switch_state_to_automatic(aut: AUT, main_screen: MainWindow, user_account):
    with step('Open settings and switch state to automatic'):
        settings = main_screen.left_panel
        settings.set_user_to_automatic()

    with step('Verify user status set automatically to online'):
        assert settings.user_is_set_to_automatic()

    with step('Restart application'):
        aut.restart()
        main_screen.authorize_user(user_account)

    with step('Verify user status set automatically to online'):
        assert settings.user_is_set_to_automatic()


@allure.testcase('https://ethstatus.testrail.net/index.php?/cases/view/703005',
                 'Change the password and login with new password')
@pytest.mark.case(703005)
@pytest.mark.parametrize('user_account, user_account_new',
                         [pytest.param(constants.user.user_account_one, constants.user.user_account_one_changed_name)])
def test_change_password_and_login(aut: AUT, main_screen: MainWindow, user_account, user_account_new):
    with step('Open profile settings and change password'):
        main_screen.left_panel.open_settings().left_panel.open_profile_settings().open_change_password_popup().change_password(
            user_account.password, user_account_new.password)

    with step('Restart application'):
        aut.restart()
        main_screen.authorize_user(user_account_new)

    with step('Verify that the user logged in correctly'):
        user_canvas = main_screen.left_panel.open_user_canvas()
        profile_popup = user_canvas.open_profile_popup()
        assert profile_popup.user_name == user_account_new.name


@allure.testcase('https://ethstatus.testrail.net/index.php?/cases/view/703001','Backup seed phrase')
@pytest.mark.case(703001)
def test_back_up_seed_phrase(main_screen: MainWindow):
    with step('Open back up seed phrase in settings'):
        settings = main_screen.left_panel.open_settings()
        back_up = settings.left_panel.open_back_up_seed_phrase()
        back_up.back_up_seed_phrase()
    with step('Verify back up seed phrase banner dissapeared'):
        assert not BackUpSeedPhraseBanner().is_visible, 'Secure your seed phrase banner visible'


@allure.testcase('https://ethstatus.testrail.net/index.php?/cases/view/703006',
                 'Set display name, bio and social links')
@pytest.mark.case(703006)
@pytest.mark.parametrize('user_account, user_account_changed',
                         [pytest.param(constants.user.user_account_one, constants.user.user_account_one_changed_name)])
@pytest.mark.parametrize('bio, links', [pytest.param('This is my bio', constants.social_links.social_links)])
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
