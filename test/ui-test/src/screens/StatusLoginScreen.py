# ******************************************************************************
# Status.im
# *****************************************************************************/
# /**
# * \file    StatusLoginScreen.py
# *
# * \date    February 2022
# * \brief   It defines the status login screen behavior and properties.
# *****************************************************************************/

from enum import Enum
from screens.StatusAccountsScreen import StatusAccountsScreen
from drivers.SquishDriver import *
from drivers.SquishDriverVerification import *


# It defines the identifier for each Login View component:
class SLoginComponents(Enum):
    MAIN_VIEW = "loginView_main"
    PASSWORD_INPUT = "loginView_passwordInput"
    SUBMIT_BTN = "loginView_submitBtn"
    CHANGE_ACCOUNT_BTN = "loginView_changeAccountBtn"
    ERR_MSG_LABEL = "loginView_errMsgLabel"


# It defines expected password placeholder text.
class PswPlaceholderTextType(Enum):
    NONE = None
    CONNECTING = "Connecting..."
    PASSWORD = "Enter password"


# It defines the status login screen behavior and properties.
class StatusLoginScreen():
    __is_loaded = False
    __login_view_obj = None

    def __init__(self):
        verify_screen(SLoginComponents.MAIN_VIEW.value)

    def login(self, password):
        click_obj_by_name(SLoginComponents.PASSWORD_INPUT.value)
        type(SLoginComponents.PASSWORD_INPUT.value, password)
        click_obj_by_name(SLoginComponents.SUBMIT_BTN.value)

    def verify_error_message_is_displayed(self):
        verify_object_enabled(SLoginComponents.ERR_MSG_LABEL.value)

    def get_accounts_selector_popup(self):
        return StatusAccountsScreen()

    def submit_password(self):
        return click_obj_by_name(SLoginComponents.SUBMIT_BTN.value)

    def open_accounts_selector_popup(self):
        return click_obj_by_name(SLoginComponents.CHANGE_ACCOUNT_BTN.value)

    def get_password_placeholder_text(self):
        result = ""
        [loaded, obj] = is_loaded(SLoginComponents.PASSWORD_INPUT.value)
        if loaded:
            result = obj.placeholderText
        return result

    def get_error_message_text(self):
        result = ""
        [loaded, obj] = is_loaded_visible_and_enabled(SLoginComponents.ERR_MSG_LABEL.value)
        if loaded:
            result = obj.text
        return result

    def get_expected_error_message_text(self):  # , language):
        # NOTE: It could introduce language checkers.
        return "Login failed. Please re-enter your password and try again."

    # NOT IMPLEMENTED STUFF:
    def get_expected_placeholder_text(self, pswPlaceholderTextType):  # , language):
        # NOTE: It could introduce language checkers.
        raise NotImplementedError("TODO: get_expected_placeholder_text method")

    def open_generate_new_keys_popup(self):
        raise NotImplementedError("TODO: open_generate_new_keys_popup method")

    def get_current_account_name(self):
        raise NotImplementedError("TODO: get_current_account_name method")

    def get_current_identicon(self):
        raise NotImplementedError("TODO: get_current_identicon method")
