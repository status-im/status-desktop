# ******************************************************************************
# Status.im
# *****************************************************************************/
# /**
# * \file    StatusMainScreen.py
# *
# * \date    June 2022
# * \brief   Home Screen.
# *****************************************************************************/


import time
from enum import Enum
from drivers.SquishDriver import *
from drivers.SquishDriverVerification import *
import time

class MainScreenComponents(Enum):
    STATUS_ICON = "mainWindow_statusIcon_StatusIcon_2"
    PUBLIC_CHAT_ICON = "mainWindow_public_chat_icon_StatusIcon"
    COMMUNITY_PORTAL_BUTTON = "navBarListView_Communities_Portal_navbar_StatusNavBarTabButton"
    JOIN_PUBLIC_CHAT = "join_public_chat_StatusMenuItemDelegate"
    SETTINGS_BUTTON = "settings_navbar_settings_icon_StatusIcon"
    WALLET_BUTTON = "wallet_navbar_wallet_icon_StatusIcon"
    START_CHAT_BTN = "mainWindow_startChat"
    CHAT_LIST = "chatList_Repeater"
    MARK_AS_READ_BUTTON = "mark_as_Read_StatusMenuItemDelegate"
    COMMUNITY_NAVBAR_BUTTONS = "navBarListView_All_Community_Buttons"
    MODULE_WARNING_BANNER = "moduleWarning_Banner"

class ChatNamePopUp(Enum):
    CHAT_NAME_TEXT = "chat_name_PlaceholderText"
    INPUT_ROOM_TOPIC_TEXT = "joinPublicChat_input"
    START_CHAT_BTN = "startChat_Btn"


class StatusMainScreen:

    def __init__(self):
        verify_screen(MainScreenComponents.PUBLIC_CHAT_ICON.value)

    # Wait for the banner to disappear otherwise the click might land badly
    def wait_for_banner_to_disappear():
        [bannerLoaded, _] = is_loaded_visible_and_enabled(MainScreenComponents.MODULE_WARNING_BANNER.value)
        if (bannerLoaded):
            time.sleep(5)

    def join_chat_room(self, room: str):
        click_obj_by_name(MainScreenComponents.PUBLIC_CHAT_ICON.value)
        #click_obj_by_name(MainScreenComponents.JOIN_PUBLIC_CHAT.value)
        type(ChatNamePopUp.INPUT_ROOM_TOPIC_TEXT.value, room)
        click_obj_by_name(ChatNamePopUp.START_CHAT_BTN.value)
        
    def open_community_portal(self):
        click_obj_by_name(MainScreenComponents.COMMUNITY_PORTAL_BUTTON.value)
    
    def open_settings(self):
        click_obj_by_name(MainScreenComponents.SETTINGS_BUTTON.value)
        time.sleep(0.5)
        
    def open_start_chat_view(self):
        click_obj_by_name(MainScreenComponents.START_CHAT_BTN.value)
        
    def open_chat(self, chatName: str):
        [loaded, chat_button] = self._find_chat(chatName)
        if loaded:
            click_obj(chat_button)
        verify(loaded, "Trying to get chat: " + chatName)
        
    def _find_chat(self, chatName: str):
        [loaded, chat_lists] = is_loaded(MainScreenComponents.CHAT_LIST.value)
        if loaded:
            for index in range(chat_lists.count):
                chat = chat_lists.itemAt(index)
                if(chat.objectName == chatName):
                    return True, chat        
        return False, None

    def mark_as_read(self, chatName: str):
        [loaded, chat_button] = self._find_chat(chatName)
        if loaded:
            right_click_obj(chat_button)
        else:
            test.fail("Chat is not loaded")
        
        click_obj_by_name(MainScreenComponents.MARK_AS_READ_BUTTON.value)

    def open_wallet(self):
        click_obj_by_name(MainScreenComponents.WALLET_BUTTON.value)

    def verify_communities_count(self, expected_count: int):
        objects = get_objects(MainScreenComponents.COMMUNITY_NAVBAR_BUTTONS.value)
        verify_equals(len(objects), int(expected_count))