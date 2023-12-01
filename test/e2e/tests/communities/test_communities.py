from copy import deepcopy
from datetime import datetime

import allure
import pytest
from allure_commons._allure import step

import configs.testpath
import constants
import driver
from constants import UserAccount
from gui.main_window import MainWindow
from gui.screens.community import CommunityScreen
from scripts.tools import image


@allure.testcase('https://ethstatus.testrail.net/index.php?/cases/view/703084', 'Create community')
@pytest.mark.case(703084)
#@pytest.mark.skip(reason="https://github.com/status-im/desktop-qa-automation/issues/167")
@pytest.mark.parametrize('params', [constants.community_params])
def test_create_community(user_account, main_screen: MainWindow, params):
    with step('Create community'):
        communities_portal = main_screen.left_panel.open_communities_portal()
        create_community_form = communities_portal.open_create_community_popup()
        community_screen = create_community_form.create(params)

    with step('Verify community parameters in community overview'):
        # TODO: change image comparison https://github.com/status-im/desktop-qa-automation/issues/263
        # with step('Icon is correct'):
        # community_icon = main_screen.left_panel.get_community_logo(params['name'])
        # image.compare(community_icon, 'button_logo.png', timout_sec=5)
        with step('Name is correct'):
            assert community_screen.left_panel.name == params['name']
        with step('Members count is correct'):
            assert '1' in community_screen.left_panel.members
        # TODO: change image comparison https://github.com/status-im/desktop-qa-automation/issues/263
        # with step('Logo is correct'):
        # image.compare(community_screen.left_panel.logo, 'logo.png')

    with step('Verify community parameters in community settings view'):
        community_setting = community_screen.left_panel.open_community_settings()
        overview_setting = community_setting.left_panel.open_overview()
        with step('Name is correct'):
            assert overview_setting.name == params['name']
        with step('Description is correct'):
            assert overview_setting.description == params['description']
        with step('Members count is correct'):
            members_settings = community_setting.left_panel.open_members()
            assert user_account.name in members_settings.members

    with step('Verify community parameters in community settings screen'):
        settings_screen = main_screen.left_panel.open_settings()
        community_settings = settings_screen.left_panel.open_communities_settings()
        community = community_settings.get_community_info(params['name'])
        assert community.name == params['name']
        assert community.description == params['description']
        # assert '1' in community.members TODO: Test on linux, members label is not visible
        # TODO: change image comparison https://github.com/status-im/desktop-qa-automation/issues/263
        # image.compare(community.image, 'logo_in_settings.png')


@allure.testcase('https://ethstatus.testrail.net/index.php?/cases/view/703056', 'Edit community separately')
@pytest.mark.case(703056)
@pytest.mark.parametrize('community_params', [
    {
        'name': f'Name_{datetime.now():%H%M%S}',
        'description': f'Description_{datetime.now():%H%M%S}',
        'color': '#ff7d46',
    },

])
@pytest.mark.skip(reason="https://github.com/status-im/desktop-qa-automation/issues/167")
def test_edit_community_separately(main_screen, community_params):
    main_screen.create_community(constants.community_params)

    with step('Edit community name'):
        community_screen = main_screen.left_panel.select_community(constants.community_params['name'])
        community_setting = community_screen.left_panel.open_community_settings()
        edit_community_form = community_setting.left_panel.open_overview().open_edit_community_view()
        edit_community_form.edit({'name': community_params['name']})

    with step('Name is correct'):
        overview_setting = community_setting.left_panel.open_overview()
        assert overview_setting.name == community_params['name']
    with step('Description is correct'):
        assert overview_setting.description == constants.community_params['description']

    with step('Edit community name'):
        edit_community_form = overview_setting.open_edit_community_view()
        edit_community_form.edit({'description': community_params['description']})

    with step('Name is correct'):
        overview_setting = community_setting.left_panel.open_overview()
        assert overview_setting.name == community_params['name']
    with step('Description is correct'):
        assert overview_setting.description == community_params['description']


@allure.testcase('https://ethstatus.testrail.net/index.php?/cases/view/703057', 'Edit community')
@pytest.mark.case(703057)
@pytest.mark.parametrize('params', [
    {
        'name': 'Updated Name',
        'description': 'Updated Description',
        'logo': {'fp': configs.testpath.TEST_FILES / 'banner.png', 'zoom': None, 'shift': None},
        'banner': {'fp': configs.testpath.TEST_FILES / 'tv_signal.png', 'zoom': None, 'shift': None},
        'color': '#ff7d46',
        'tags': ['Ethereum'],
        'intro': 'Updated Intro',
        'outro': 'Updated Outro'
    }
])
@pytest.mark.skip(reason="https://github.com/status-im/desktop-qa-automation/issues/167")
def test_edit_community(main_screen: MainWindow, params):
    main_screen.create_community(constants.community_params)

    with step('Edit community'):
        community_screen = main_screen.left_panel.select_community(constants.community_params['name'])
        community_setting = community_screen.left_panel.open_community_settings()
        edit_community_form = community_setting.left_panel.open_overview().open_edit_community_view()
        edit_community_form.edit(params)

    with step('Verify community parameters on settings overview'):
        overview_setting = community_setting.left_panel.open_overview()
        with step('Name is correct'):
            assert overview_setting.name == params['name']
        with step('Description is correct'):
            assert overview_setting.description == params['description']

    with step('Verify community parameters in community screen'):
        community_setting.left_panel.back_to_community()
        # TODO: change image comparison https://github.com/status-im/desktop-qa-automation/issues/263
        # with step('Icon is correct'):
        #     community_icon = main_screen.left_panel.get_community_logo(params['name'])
        # image.compare(community_icon, 'button_updated_logo.png')
        with step('Name is correct'):
            assert community_screen.left_panel.name == params['name']
        # TODO: change image comparison https://github.com/status-im/desktop-qa-automation/issues/263
        # with step('Logo is correct'):
        # image.compare(community_screen.left_panel.logo, 'updated_logo.png')

    with step('Verify community parameters in community settings screen'):
        settings_screen = main_screen.left_panel.open_settings()
        community_settings = settings_screen.left_panel.open_communities_settings()
        community_info = community_settings.communities[0]
        assert community_info.name == params['name']
        assert community_info.description == params['description']
        assert '1' in community_info.members
        # image.compare(community_info.image, 'logo_in_settings_updated.png')


@allure.testcase('https://ethstatus.testrail.net/index.php?/cases/view/703049', 'Create community channel')
@pytest.mark.case(703049)
@pytest.mark.parametrize('channel_name, channel_description, channel_emoji', [('Channel', 'Description', 'sunglasses')])
@pytest.mark.skip(reason="https://github.com/status-im/desktop-qa-automation/issues/167")
def test_create_community_channel(main_screen: MainWindow, channel_name, channel_description, channel_emoji):
    main_screen.create_community(constants.community_params)
    community_screen = main_screen.left_panel.select_community(constants.community_params['name'])
    community_screen.create_channel(channel_name, channel_description, channel_emoji)

    with step('Verify channel'):
        community_screen.verify_channel(
            channel_name,
            channel_description,
            'channel_icon_in_list.png',
            'channel_icon_in_toolbar.png',
            'channel_icon_in_chat.png'
        )


@allure.testcase('https://ethstatus.testrail.net/index.php?/cases/view/703050', 'Edit community channel')
@pytest.mark.case(703050)
@pytest.mark.parametrize('channel_name, channel_description, channel_emoji', [('Channel', 'Description', 'sunglasses')])
@pytest.mark.skip(reason="https://github.com/status-im/desktop-qa-automation/issues/167")
def test_edit_community_channel(main_screen, channel_name, channel_description, channel_emoji):
    main_screen.create_community(constants.community_params)
    community_screen = CommunityScreen()

    with step('Verify General channel'):
        community_screen.verify_channel(
            'general',
            'General channel for the community',
            'general_channel_icon_in_list.png',
            'general_channel_icon_in_toolbar.png',
            'general_channel_icon_in_chat.png'
        )

    community_screen.edit_channel('general', channel_name, channel_description, channel_emoji)

    with step('Verify General channel'):
        community_screen.verify_channel(
            channel_name,
            channel_description,
            'channel_icon_in_list.png',
            'channel_icon_in_toolbar.png',
            'channel_icon_in_chat.png'
        )


@allure.testcase('https://ethstatus.testrail.net/index.php?/cases/view/703051', 'Delete community channel')
@pytest.mark.case(703051)
#@pytest.mark.skip(reason="https://github.com/status-im/desktop-qa-automation/issues/167")
def test_delete_community_channel(main_screen):
    main_screen.create_community(constants.community_params)

    with step('Delete channel'):
        CommunityScreen().delete_channel('general')

    with step('Verify channel is not exists'):
        assert not CommunityScreen().left_panel.channels


@allure.testcase('https://ethstatus.testrail.net/index.php?/cases/view/703510', 'Join community via owner invite')
@pytest.mark.case(703510)
@pytest.mark.parametrize('user_data_one, user_data_two', [
    (configs.testpath.TEST_USER_DATA / 'user_account_one', configs.testpath.TEST_USER_DATA / 'user_account_two')
])
@pytest.mark.skip(reason="https://github.com/status-im/desktop-qa-automation/issues/167")
def test_join_community_via_owner_invite(multiple_instance, user_data_one, user_data_two):
    user_one: UserAccount = constants.user_account_one
    user_two: UserAccount = constants.user_account_two
    community_params = deepcopy(constants.community_params)
    community_params['name'] = f'{datetime.now():%d%m%Y_%H%M%S}'
    main_window = MainWindow()

    with multiple_instance() as aut_one, multiple_instance() as aut_two:
        with step(f'Launch multiple instances with authorized users {user_one.name} and {user_two.name}'):
            for aut, account in zip([aut_one, aut_two], [user_one, user_two]):
                aut.attach()
                main_window.wait_until_appears(configs.timeouts.APP_LOAD_TIMEOUT_MSEC).prepare()
                main_window.authorize_user(account)
                main_window.hide()

        with step(f'User {user_two.name}, get chat key'):
            aut_two.attach()
            main_window.prepare()
            profile_popup = main_window.left_panel.open_user_canvas().open_profile_popup()
            chat_key = profile_popup.chat_key
            profile_popup.close()
            main_window.hide()

        with step(f'User {user_one.name}, send contact request to {user_two.name}'):
            aut_one.attach()
            main_window.prepare()
            settings = main_window.left_panel.open_settings()
            messaging_settings = settings.left_panel.open_messaging_settings()
            contacts_settings = messaging_settings.open_contacts_settings()
            contact_request_popup = contacts_settings.open_contact_request_form()
            contact_request_popup.send(chat_key, f'Hello {user_two.name}')
            main_window.hide()

        with step(f'User {user_two.name}, accept contact request from {user_one.name}'):
            aut_two.attach()
            main_window.prepare()
            settings = main_window.left_panel.open_settings()
            messaging_settings = settings.left_panel.open_messaging_settings()
            contacts_settings = messaging_settings.open_contacts_settings()
            contacts_settings.accept_contact_request(user_one.name)
            main_window.hide()

        with step(f'User {user_one.name}, create community and {user_two.name}'):
            aut_one.attach()
            main_window.prepare()
            main_window.create_community(community_params)
            main_window.left_panel.invite_people_in_community([user_two.name], 'Message', community_params['name'])
            main_window.hide()

        with step(f'User {user_two.name}, accept invitation from {user_one.name}'):
            aut_two.attach()
            main_window.prepare()
            messages_view = main_window.left_panel.open_messages_screen()
            chat = messages_view.left_panel.open_chat(user_one.name)
            community_screen = chat.accept_community_invite(community_params['name'])

        with step(f'User {user_two.name}, verify welcome community popup'):
            welcome_popup = community_screen.left_panel.open_welcome_community_popup()
            assert community_params['name'] in welcome_popup.title
            assert community_params['intro'] == welcome_popup.intro
            welcome_popup.join().authenticate(user_one.password)
            assert driver.waitFor(lambda: not community_screen.left_panel.is_join_community_visible,
                                  configs.timeouts.UI_LOAD_TIMEOUT_MSEC), 'Join community button not hidden'

        with step(f'User {user_two.name}, see two members in community members list'):
            assert user_one.name in community_screen.right_panel.members
            assert driver.waitFor(lambda: '2' in community_screen.left_panel.members)
            main_window.hide()

        with step(f'User {user_one.name}, see two members in community members list'):
            aut_one.attach()
            main_window.prepare()
            assert user_one.name in community_screen.right_panel.members
            assert driver.waitFor(lambda: user_two.name in community_screen.right_panel.members)
            assert '2' in community_screen.left_panel.members
