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
from drivers.SDKeyboardCommands import *
from utils.ObjectAccess import *
import time

class MainScreenComponents(Enum):
    MAIN_WINDOW = "statusDesktop_mainWindow"
    PUBLIC_CHAT_ICON = "mainWindow_public_chat_icon_StatusIcon"
    CHAT_NAVBAR_ICON = "navBarListView_Chat_navbar_StatusNavBarTabButton"
    COMMUNITY_PORTAL_BUTTON = "navBarListView_Communities_Portal_navbar_StatusNavBarTabButton"
    JOIN_PUBLIC_CHAT = "join_public_chat_StatusMenuItem"
    SETTINGS_BUTTON = "navBarListView_Settings_navbar_StatusNavBarTabButton"
    WALLET_BUTTON = "wallet_navbar_wallet_icon_StatusIcon"
    START_CHAT_BTN = "mainWindow_startChat"
    CHAT_LIST = "chatList"
    MARK_AS_READ_BUTTON = "mark_as_Read_StatusMenuItem"
    COMMUNITY_NAVBAR_BUTTONS = "navBarListView_All_Community_Buttons"
    SECURE_SEEDPHRASE_BANNER = "secureSeedPhrase_Banner"
    CONNECTION_INFO_BANNER = "connectionInfo_Banner"
    UPDATE_APP_BANNER = "appVersionUpdate_Banner"
    TESTNET_INFO_BANNER = "testnetInfo_Banner"    
    PROFILE_NAVBAR_BUTTON = "mainWindow_ProfileNavBarButton"
    USERSTATUSMENU_ALWAYS_ACTIVE_ACTION = "userContextmenu_AlwaysActiveButton"
    USERSTATUSMENU_INACTIVE_ACTION = "userContextmenu_InActiveButton"
    USERSTATUSMENU_AUTOMATIC_ACTION = "userContextmenu_AutomaticButton"
    USERSTATUSMENU_OPEN_PROFILE_POPUP = "userContextMenu_ViewMyProfileAction"
    SPLASH_SCREEN = "splashScreen"
    TOOLBAR_BACK_BUTTON = "main_toolBar_back_button"
    LEAVE_CHAT_MENUITEM = "leaveChatMenuItem"
    EMPTY_CHAT_PANEL_IMAGE = "mainWindow_emptyChatPanelImage"

class ProfilePopup(Enum):
    USER_IMAGE = "ProfileHeader_userImage"
    DISPLAY_NAME = "ProfileHeader_displayName"
    DISPLAY_NAME_EDIT_ICON = "ProfileHeader_displayNameEditIcon"

class DisplayNamePopup(Enum):
    DISPLAY_NAME_INPUT = "DisplayNamePopup_displayNameInput"
    DISPLAY_NAME_OK_BUTTON = "DisplayNamePopup_okButton"
    
class ChatNamePopUp(Enum):
    CHAT_NAME_TEXT = "chat_name_PlaceholderText"
    INPUT_ROOM_TOPIC_TEXT = "joinPublicChat_input"
    START_CHAT_BTN = "startChat_Btn"


class StatusMainScreen:

    def __init__(self):
        verify_screen(MainScreenComponents.EMPTY_CHAT_PANEL_IMAGE.value)
        
    # Main screen is ready to interact with it (Splash screen animation not present and no banners on top of the screen)
    def is_ready(self):
        self.wait_for_splash_animation_ends()
        self.close_banners()
        verify(is_displayed(MainScreenComponents.EMPTY_CHAT_PANEL_IMAGE.value), "Verifying if empty chat panel image is displayed")
        
    def wait_for_splash_animation_ends(self, timeoutMSec: int = 10000):
        start = time.time()
        [loaded, obj] = is_loaded_visible_and_enabled(MainScreenComponents.SPLASH_SCREEN.value)
        while loaded and (start + timeoutMSec / 1000 > time.time()):
            log("Splash screen animation present!")
            [loaded, obj] = is_loaded_visible_and_enabled(MainScreenComponents.SPLASH_SCREEN.value)            
            sleep_test(0.5)
        verify_equal(loaded, False, "Checking splash screen animation has ended.")
    
    # It closes all existing banner and waits them to disappear:
    def close_banners(self):
        self.wait_for_banner_to_disappear(MainScreenComponents.CONNECTION_INFO_BANNER.value)
        self.wait_for_banner_to_disappear(MainScreenComponents.UPDATE_APP_BANNER.value)
        self.wait_for_banner_to_disappear(MainScreenComponents.SECURE_SEEDPHRASE_BANNER.value)

    # Close banner and wait to disappear otherwise the click might land badly
    def wait_for_banner_to_disappear(self, banner_type: str, timeoutMSec: int = 3000):
        start = time.time()
        while(start + timeoutMSec / 1000 > time.time()):
            try:
                obj = get_obj(banner_type)
                if not obj.visible:
                    log("Banner object not visible")
                    return
                obj.close()
                log("Closed banner: " + banner_type)
            except:
                log("Banner object not found")
                return
            sleep_test(0.5)
        verify_failure(f"Banner is still visible after {timeoutMSec}ms")

    def join_chat_room(self, room: str):
        click_obj_by_name(MainScreenComponents.PUBLIC_CHAT_ICON.value)
        #click_obj_by_name(MainScreenComponents.JOIN_PUBLIC_CHAT.value)
        type(ChatNamePopUp.INPUT_ROOM_TOPIC_TEXT.value, room)
        click_obj_by_name(ChatNamePopUp.START_CHAT_BTN.value)
        
    def open_chat_section(self):
        click_obj_by_name(MainScreenComponents.CHAT_NAVBAR_ICON.value)
        
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

    def verify_chat_does_not_exist(self, chatName: str):
        [loaded, chat_button] = self._find_chat(chatName)
        verify_false(loaded, "Chat "+chatName+ " exists")

    def _find_chat(self, chatName: str):
        [loaded, chat_lists] = is_loaded(MainScreenComponents.CHAT_LIST.value)
        if loaded:
            for index in range(chat_lists.statusChatListItems.count):
                chat = chat_lists.statusChatListItems.itemAt(index)
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

    def click_community(self, community_name: str):
        wait_and_get_obj(MainScreenComponents.COMMUNITY_NAVBAR_BUTTONS.value)
        community_buttons = get_objects(MainScreenComponents.COMMUNITY_NAVBAR_BUTTONS.value)
        for index in range(len(community_buttons)):
            community_button = community_buttons[index]
            if (community_button.name == community_name):
                click_obj(community_button)
                return
        verify_failure("Community named " + community_name + " not found in the community nav buttons")

    def verify_communities_count(self, expected_count: int):
        objects = get_objects(MainScreenComponents.COMMUNITY_NAVBAR_BUTTONS.value)
        verify_equals(len(objects), int(expected_count))

    def user_is_online(self):
        profileButton = squish.waitForObject(getattr(names, MainScreenComponents.PROFILE_NAVBAR_BUTTON.value))
        verify_equal(profileButton.badge.color.name, "#4ebc60", "The user is not online by default")

    def user_is_offline(self):
        profileButton = squish.waitForObject(getattr(names, MainScreenComponents.PROFILE_NAVBAR_BUTTON.value))
        verify_equal(profileButton.badge.color.name, "#7f8990", "The user is not offline")
        
    def user_is_set_to_automatic(self):
        profileButton = squish.waitForObject(getattr(names, MainScreenComponents.PROFILE_NAVBAR_BUTTON.value))
        verify_equal(profileButton.badge.color.name, "#4ebc60", "The user is not online by default")
        
    def set_user_state_offline(self):
        click_obj_by_name(MainScreenComponents.PROFILE_NAVBAR_BUTTON.value)
        click_obj_by_name(MainScreenComponents.USERSTATUSMENU_INACTIVE_ACTION.value)
        
    def set_user_state_online(self):
        click_obj_by_name(MainScreenComponents.PROFILE_NAVBAR_BUTTON.value)
        click_obj_by_name(MainScreenComponents.USERSTATUSMENU_ALWAYS_ACTIVE_ACTION.value)
        
    def set_user_state_to_automatic(self):
        click_obj_by_name(MainScreenComponents.PROFILE_NAVBAR_BUTTON.value)
        click_obj_by_name(MainScreenComponents.USERSTATUSMENU_AUTOMATIC_ACTION.value)

    def open_own_profile_popup(self):
        click_obj_by_name(MainScreenComponents.PROFILE_NAVBAR_BUTTON.value)
        click_obj_by_name(MainScreenComponents.USERSTATUSMENU_OPEN_PROFILE_POPUP.value)

    def verify_profile_popup_display_name(self, display_name: str):
        verify_text_matching(ProfilePopup.DISPLAY_NAME.value, display_name)

    def set_profile_popup_display_name(self, display_name: str):
        click_obj_by_name(ProfilePopup.DISPLAY_NAME_EDIT_ICON.value)
        name_changed = setText(DisplayNamePopup.DISPLAY_NAME_INPUT.value, display_name)
        verify(name_changed, "set display name")
        click_obj_by_name(DisplayNamePopup.DISPLAY_NAME_OK_BUTTON.value)
        
    def click_escape(self):
        press_escape(MainScreenComponents.MAIN_WINDOW.value)        
    
    def click_tool_bar_back_button(self):   
        click_obj_by_name(MainScreenComponents.TOOLBAR_BACK_BUTTON.value)  

    def leave_chat(self, chatName: str):
        [loaded, chat_button] = self._find_chat(chatName)
        if loaded:
            right_click_obj(chat_button)
            hover_and_click_object_by_name(MainScreenComponents.LEAVE_CHAT_MENUITEM.value)
            
        verify(loaded, "Trying to get chat: " + chatName)
