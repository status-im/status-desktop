import pytest
from allure_commons._allure import step

import configs
import driver
from gui.main_window import MainWindow


@pytest.mark.communities
def test_join_leave_status_community(main_screen: MainWindow, user_account):

    with step('Open community portal'):

        portal = main_screen.left_panel.open_communities_portal()


    with step('Import Status community'):
        import_popup = portal.open_import_community_popup()
        community_screen = import_popup.import_community_with_key()
        welcome_popup = community_screen.left_panel.open_welcome_community_popup()
        assert 'Status' in welcome_popup.title
        assert driver.waitFor(lambda: "Welcome to the Status" in welcome_popup.intro,
                              configs.timeouts.UI_LOAD_TIMEOUT_MSEC), \
            f"Expected text 'Welcome to the Status' community' not found in intro: {welcome_popup.intro}"
        auth_popup = welcome_popup.join_with_sharing_all_addresses()
        auth_popup.authenticate(user_account.password)
        assert driver.waitFor(lambda: not community_screen.left_panel.is_join_community_visible,
                             configs.timeouts.APP_LOAD_TIMEOUT_MSEC), 'Join community button not hidden'

    with step('Leave status community'):
        context_menu = main_screen.left_panel.open_community_context_menu('Status')
        assert context_menu.leave_community_option.is_visible
        confirmation = context_menu.open_leave_community_popup()
        confirmation.confirm_action()

    with step('Verify that Status community is no longer visible'):
        assert not main_screen.left_panel.communities(), "Communities list is not empty"


