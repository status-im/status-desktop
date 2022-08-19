# -*- coding: utf-8 -*-
# This file contains hook functions to run as the .feature file is executed

sys.path.append(os.path.join(os.path.dirname(__file__), "../../../testSuites/global_shared/"))
sys.path.append(os.path.join(os.path.dirname(__file__), "../../../src/"))

from utils.FileManager import *

_status_desktop_app_name = "nim_status_client"
_status_data_folder_path = "../../../../../Status/data"
_status_qt_path = "../../../../../Status/qt"
_app_closure_timeout = 2 #[seconds]

@OnScenarioStart
def hook(context):
    erase_directory(_status_qt_path)
    context.userData = {}
    context.userData["aut_name"] = _status_desktop_app_name
    context.userData["status_data_folder_path"] = _status_data_folder_path
    context.userData["fixtures_root"] = os.path.join(os.path.dirname(__file__), "../../../fixtures/")
    context.userData["search_images"] = os.path.join(os.path.dirname(__file__), "../shared/searchImages/")

    base_path = os.path.join(os.path.dirname(__file__))
    split_path = base_path.split("/")

    # Remove the last three parts of the path to go back to the fixtures
    del split_path[len(split_path) - 1]
    del split_path[len(split_path) - 1]
    del split_path[len(split_path) - 1]

    joined_path = ""
    for path_part in split_path:
        joined_path += path_part + "/"

    context.userData["fixtures_root"] = os.path.join(joined_path, "fixtures/")

@OnScenarioEnd
def hook(context):
    currentApplicationContext().detach()
    snooze(_app_closure_timeout)

