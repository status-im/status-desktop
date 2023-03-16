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
    POPUP_OVERLAY = "statusDesktop_mainWindow_overlay"
    CHAT_NAVBAR_ICON = "navBarListView_Chat_navbar_StatusNavBarTabButton"
    COMMUNITY_PORTAL_BUTTON = "navBarListView_Communities_Portal_navbar_StatusNavBarTabButton"
    SETTINGS_BUTTON = "navBarListView_Settings_navbar_StatusNavBarTabButton"
    WALLET_BUTTON = "wallet_navbar_wallet_icon_StatusIcon"
    START_CHAT_BTN = "mainWindow_startChat"
    CHAT_LIST = "chatList"
    COMMUNITY_NAVBAR_BUTTONS = "navBarListView_All_Community_Buttons"
    PROFILE_SETTINGS_VIEW = "mainWindow_ProfileSettingsView" 
    PROFILE_NAVBAR_BUTTON = "mainWindow_ProfileNavBarButton"
    USERSTATUSMENU_ALWAYS_ACTIVE_ACTION = "userContextmenu_AlwaysActiveButton"
    USERSTATUSMENU_INACTIVE_ACTION = "userContextmenu_InActiveButton"
    USERSTATUSMENU_AUTOMATIC_ACTION = "userContextmenu_AutomaticButton"
    USERSTATUSMENU_OPEN_PROFILE_POPUP = "userContextMenu_ViewMyProfileAction"
    SPLASH_SCREEN = "splashScreen"
    TOOLBAR_BACK_BUTTON = "main_toolBar_back_button"
    LEAVE_CHAT_MENUITEM = "leaveChatMenuItem"
    CONTACTS_COLUMN_MESSAGES_HEADLINE = "mainWindow_ContactsColumn_Messages_Headline"

class ProfilePopup(Enum):
    USER_IMAGE = "ProfileHeader_userImage"
    DISPLAY_NAME = "ProfilePopup_displayName"
    EDIT_PROFILE_BUTTON = "ProfilePopup_editButton"
    
class ChatNamePopUp(Enum):
    CHAT_NAME_TEXT = "chat_name_PlaceholderText"
    START_CHAT_BTN = "startChat_Btn"


class StatusMainScreen:

    def __init__(self):
        verify_screen(MainScreenComponents.CONTACTS_COLUMN_MESSAGES_HEADLINE.value)
        
    # Main screen is ready to interact with it (Splash screen animation not present)
    def is_ready(self):
        self.wait_for_splash_animation_ends()
        verify(is_displayed(MainScreenComponents.CONTACTS_COLUMN_MESSAGES_HEADLINE.value), "Verifying if the Messages headline is displayed")
        
    def wait_for_splash_animation_ends(self, timeoutMSec: int = 10000):
        start = time.time()
        [loaded, obj] = is_loaded_visible_and_enabled(MainScreenComponents.SPLASH_SCREEN.value)
        while loaded and (start + timeoutMSec / 1000 > time.time()):
            log("Splash screen animation present!")
            [loaded, obj] = is_loaded_visible_and_enabled(MainScreenComponents.SPLASH_SCREEN.value, 1000)            
            sleep_test(0.5)
        verify_equal(loaded, False, "Checking splash screen animation has ended.")

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
                chat = chat_lists.statusChatListItems.itemAtIndex(index)
                if(chat.objectName == chatName):
                    return True, chat        
        return False, None

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
    
    def profile_image_is_updated(self):
        # open profile popup and check image on profileNavBarButton and profileNavBarPopup
        profileNavBarButton = wait_and_get_obj(MainScreenComponents.PROFILE_NAVBAR_BUTTON.value)
        click_obj(profileNavBarButton)
        profilePopupImage = wait_and_get_obj(ProfilePopup.USER_IMAGE.value)
        image_present("loginUserName", True, 95, 75, 100, True, profileNavBarButton)
        image_present("loginUserName", True, 95, 75, 100, True, profilePopupImage)
        
    def profile_modal_image_is_updated(self):
        click_obj_by_name(MainScreenComponents.PROFILE_NAVBAR_BUTTON.value)
        click_obj_by_name(MainScreenComponents.USERSTATUSMENU_OPEN_PROFILE_POPUP.value)
        image_present("profiletestimage", True, 97, 95, 100, True)
        
    def profile_settings_image_is_updated(self):
        # first time clicking on settings button closes the my profile modal
        click_obj_by_name(MainScreenComponents.SETTINGS_BUTTON.value)
        click_obj_by_name(MainScreenComponents.SETTINGS_BUTTON.value)
        myProfileSettingsObject = wait_and_get_obj(MainScreenComponents.PROFILE_SETTINGS_VIEW.value)
        image_present("profiletestimage", True, 95, 100, 183, True, myProfileSettingsObject)
        
    def navigate_to_edit_profile(self):
        click_obj_by_name(ProfilePopup.EDIT_PROFILE_BUTTON.value)
        
    def close_popup(self):
        # Click in the corner of the overlay to close the popup
        click_obj_by_name_at_coordinates(MainScreenComponents.POPUP_OVERLAY.value, 1, 1)
