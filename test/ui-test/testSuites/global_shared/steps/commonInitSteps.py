"""It defines starting-up or driving-the-app-into-an-idle-state static methods outside bdd context that can be reused in different `hooks` as well as in specific bdd steps files."""

import os
from datetime import datetime

import constants
import configs
import utils.FileManager as filesMngr
import common.Common as common
import configs
import drivers.SquishDriver as driver

from screens.StatusWelcomeScreen import StatusWelcomeScreen
from screens.StatusMainScreen import StatusMainScreen
from screens.StatusChatScreen import StatusChatScreen
from screens.StatusCommunityPortalScreen import StatusCommunityPortalScreen
from screens.StatusCommunityScreen import StatusCommunityScreen
from screens.StatusLoginScreen import StatusLoginScreen
from screens.SettingsScreen import SettingsScreen

# Project settings properties:
_status_desktop_app_name = "nim_status_client"
_status_data_folder_path = "../../../../../Status/data"
_status_fixtures_folder_path = "../../../fixtures/"
_status_shared_images_path = "../shared/searchImages/"
_status_qt_path = "../../../../../Status/qt"
_app_closure_timeout = 2 #[seconds]

# Test context properties names:
_aut_name = "aut_name"
_status_data_folder = "status_data_folder_path"
_fixtures_root = "fixtures_root"
_search_images = "search_images"
_feature_name = "feature_name"

def context_init(context, testSettings, screenshot_on_fail = True):
    # With this property it is enabled that every test failure will cause Squish to take a screenshot of the desktop when the failure occurred
    testSettings.logScreenshotOnFail = screenshot_on_fail
    testSettings.logScreenshotOnError = screenshot_on_fail
    testSettings.waitForObjectTimeout = 5000

    filesMngr.erase_directory(_status_qt_path)
    context.userData = {}
    context.userData['aut'] = []
    context.userData[_aut_name] = _status_desktop_app_name
    context.userData[_status_data_folder] = _status_data_folder_path
    context.userData[_fixtures_root] = os.path.join(os.path.dirname(__file__), _status_fixtures_folder_path)
    context.userData[_search_images] = os.path.join(os.path.dirname(__file__), _status_shared_images_path)

    context.userData[_feature_name] = context._data["title"]

    base_path = os.path.join(os.path.dirname(__file__))
    split_path = base_path.split("/")

    # Remove the last three parts of the path to go back to the fixtures
    del split_path[len(split_path) - 1]
    del split_path[len(split_path) - 1]
    del split_path[len(split_path) - 1]

    joined_path = ""
    for path_part in split_path:
        joined_path += path_part + "/"

    context.userData[_fixtures_root] = os.path.join(joined_path, "fixtures/")

def a_first_time_user_lands_on(context):
    driver.start_application(context)

def switch_aut_context(context, index: int):
    for _index, aut in enumerate(context.userData['aut']):
        if _index != index:
            aut.attach().window.minimize()
    context.userData['aut'][index].attach().window.prepare()

def a_user_starts_the_application_with_a_specific_data_folder(context, data_folder_path):
    driver.start_application(context, user_data=data_folder_path)

def a_first_time_user_lands_on_and_generates_new_key(context):
    a_first_time_user_lands_on(context)
    welcome_screen = StatusWelcomeScreen()
    welcome_screen.agree_terms_conditions_and_generate_new_key()

def a_user_lands_on_and_generates_new_key(context):
    welcome_screen = StatusWelcomeScreen()
    welcome_screen.generate_new_key()

def a_first_time_user_lands_on_and_navigates_to_import_seed_phrase(context):
    driver.start_application(context)
    welcome_screen = StatusWelcomeScreen()
    welcome_screen.agree_terms_conditions_and_navigate_to_import_seed_phrase()

def the_user_inputs_username(username: str):
    welcome_screen = StatusWelcomeScreen()
    welcome_screen.input_username(username)

def the_user_signs_up(user: str, password: str):
    welcome_screen = StatusWelcomeScreen()
    welcome_screen.input_username_and_password_and_finalize_sign_up(user, password)

def the_user_signs_again_up(user: str, password: str):
    welcome_screen = StatusWelcomeScreen()
    welcome_screen.input_username_and_password_again_and_finalize_sign_up(user, password)

def the_user_lands_on_the_signed_in_app():
    main_screen = StatusMainScreen()
    main_screen.is_ready()

def signs_up_process_steps(context, user: str, password: str):
    a_first_time_user_lands_on_and_generates_new_key(context)
    the_user_signs_up(user, password)
    the_user_lands_on_the_signed_in_app()

def the_user_inputs_the_seed_phrase(seed_phrase: str):
    welcome_screen = StatusWelcomeScreen()
    welcome_screen.input_seed_phrase(seed_phrase)

def the_user_clicks_on_the_following_ui_component(component: str):
    common.click_on_an_object(component)

def signs_up_with_seed_phrase_process_steps(context, seed_phrase: str, user: str, password: str):
    a_first_time_user_lands_on_and_navigates_to_import_seed_phrase(context)
    the_user_inputs_the_seed_phrase(seed_phrase)
    the_user_clicks_on_the_following_ui_component("seedPhraseView_Submit_Button")
    the_user_signs_up(user, password)
    the_user_lands_on_the_signed_in_app()

def the_user_opens_the_chat_section():
    main_screen = StatusMainScreen()
    main_screen.open_chat_section()

def the_user_opens_the_community_portal_section():
    main_screen = StatusMainScreen()
    main_screen.open_community_portal()

def the_user_lands_on_the_community_portal_section():
    StatusCommunityPortalScreen()

def the_user_creates_a_community(name: str, description: str, intro: str, outro: str):
    communitity_portal_screen = StatusCommunityPortalScreen()
    communitity_portal_screen.create_community(name, description, intro, outro)

def the_user_lands_on_the_community(name: str):
    community_screen = StatusCommunityScreen()
    community_screen.verify_community_name(name)

def the_admin_creates_a_community_channel(name: str, description: str, method: str):
    community_screen = StatusCommunityScreen()
    community_screen.create_community_channel(name, description, method)

def the_channel_is_open(name: str):
    chat_screen = StatusChatScreen()
    chat_screen.verify_chat_title(name)

def the_user_logs_in(username: str, password: str):
    loginScreen = StatusLoginScreen()
    loginScreen.login(username, password)

def login_process_steps(context, user: str, password: str, data_dir_path: str):
    a_user_starts_the_application_with_a_specific_data_folder(context, data_dir_path)
    the_user_logs_in(user, password)
    the_user_lands_on_the_signed_in_app()

def the_user_opens_app_settings_screen():
    main_screen = StatusMainScreen()
    main_screen.open_settings()

def the_user_navigates_back_to_user_profile_page():
    welcome_screen = StatusWelcomeScreen()
    welcome_screen.navigate_back_to_user_profile_page()

def the_user_opens_the_wallet_section():
    settings_screen = SettingsScreen()
    settings_screen.open_wallet_section()

def the_user_toggles_test_networks():
    settings_screen = SettingsScreen()
    settings_screen.toggle_test_networks()
    main_screen = StatusMainScreen()
    main_screen.click_tool_bar_back_button()
