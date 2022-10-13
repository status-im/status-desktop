"""It defines starting-up or driving-the-app-into-an-idle-state static methods outside bdd context that can be reused in different `hooks` as well as in specific bdd steps files."""

from utils.FileManager import *
from common.Common import *

from screens.StatusWelcomeScreen import StatusWelcomeScreen
from screens.StatusMainScreen import StatusMainScreen
from screens.StatusChatScreen import StatusChatScreen

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
_scenario_name = "scenario_name"

# Test static objects creation:
_welcome_screen = StatusWelcomeScreen()
_main_screen = StatusMainScreen()
_chat_screen = StatusChatScreen()
    
def context_init(context):
    erase_directory(_status_qt_path)
    context.userData = {}
    context.userData[_aut_name] = _status_desktop_app_name
    context.userData[_status_data_folder] = _status_data_folder_path
    context.userData[_fixtures_root] = os.path.join(os.path.dirname(__file__), _status_fixtures_folder_path)
    context.userData[_search_images] = os.path.join(os.path.dirname(__file__), _status_shared_images_path)

    context.userData[_scenario_name] = context._data["title"]

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

def given_a_first_time_user_lands_on_and_generates_new_key(context):
    erase_directory(context.userData[_status_data_folder])
    start_application(context.userData[_aut_name])
    _welcome_screen.agree_terms_conditions_and_generate_new_key()
    
def given_a_first_time_user_lands_on_and_navigates_to_import_seed_phrase(context):
    erase_directory(context.userData[_status_data_folder])
    start_application(context.userData[_aut_name])
    _welcome_screen.agree_terms_conditions_and_navigate_to_import_seed_phrase()
    
def when_the_user_signs_up(user, password):        
    _welcome_screen = StatusWelcomeScreen()
    _welcome_screen.input_username_and_password_and_finalize_sign_up(user, password)
    
def when_the_user_lands_on_the_signed_in_app():
    _main_screen.is_ready()
    
def signs_up_process_steps(context, user, password):
    given_a_first_time_user_lands_on_and_generates_new_key(context)
    when_the_user_signs_up(user, password)
    when_the_user_lands_on_the_signed_in_app()

def when_the_user_joins_chat_room(_chat_room):        
    _main_screen.join_chat_room(_chat_room)
    _chat_screen.verify_chat_title(_chat_room)

def when_the_user_opens_the_chat_section():        
    _main_screen.open_chat_section()