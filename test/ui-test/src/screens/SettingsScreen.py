# ******************************************************************************
# Status.im
# *****************************************************************************/
# /**
# * \file    SettingsScreen.py
# *
# * \date    June 2022
# * \brief   Home Screen.
# *****************************************************************************/


from enum import Enum
from drivers.SquishDriver import *
from drivers.SquishDriverVerification import *
from .StatusMainScreen import MainScreenComponents
from .StatusMainScreen import StatusMainScreen

class SidebarComponents(Enum):
    ADVANCED_OPTION: str = "advanced_StatusBaseText"
    WALLET_ITEM: str = "wallet_AppMenu_StatusNavigationListItem"
    SIGN_OUT_AND_QUIT: str = "sign_out_Quit_ExtraMenu_StatusNavigationListItem"
    COMMUNITIES_ITEM: str = "communities_AppMenu_StatusNavigationListItem"


class AdvancedOptionScreen(Enum):
    ACTIVATE_OR_DEACTIVATE_WALLET: str = "walletSettingsLineButton"
    I_UNDERSTAND_POP_UP: str = "i_understand_StatusBaseText"


class WalletSettingsScreen(Enum):
    GENERATED_ACCOUNTS: str = "settings_Wallet_MainView_GeneratedAccounts"
    DELETE_ACCOUNT: str = "settings_Wallet_AccountView_DeleteAccount"
    DELETE_ACCOUNT_CONFIRM: str = "settings_Wallet_AccountView_DeleteAccount_Confirm"
    NETWORKS_ITEM: str = "settings_Wallet_MainView_Networks"
    TESTNET_TOGGLE: str = "settings_Wallet_NetworksView_TestNet_Toggle"
    EDIT_ACCOUNT_BUTTON: str = "settings_Wallet_AccountView_EditAccountButton"
    EDIT_ACCOUNT_NAME_INPUT: str = "settings_Wallet_AccountView_EditAccountNameInput"
    EDIT_ACCOUNT_COLOR_REPEATER: str = "settings_Wallet_AccountView_EditAccountColorRepeater"
    EDIT_ACCOUNT_SAVE_BUTTON: str = "settings_Wallet_AccountView_EditAccountSaveButton"
    ACCOUNT_VIEW_ACCOUNT_NAME: str = "settings_Wallet_AccountView_AccountName"
    ACCOUNT_VIEW_ICON_SETTINGS: str = "settings_Wallet_AccountView_IconSettings"    

    
class ConfirmationDialog(Enum):
    SIGN_OUT_CONFIRMATION: str = "signOutConfirmation_StatusButton"

class CommunitiesSettingsScreen(Enum):
    LEAVE_COMMUNITY_BUTTONS: str = "settings_Communities_MainView_LeaveCommunityButtons"
    LEAVE_COMMUNITY_POPUP_LEAVE_BUTTON: str = "settings_Communities_MainView_LeavePopup_LeaveCommunityButton"




class SettingsScreen:
    __pid = 0
    
    def __init__(self):
        verify_screen(SidebarComponents.ADVANCED_OPTION.value)
    
    def open_wallet_settings(self):
        click_obj_by_name(SidebarComponents.WALLET_ITEM.value)
        
    def activate_open_wallet_settings(self):
        if not (is_found(SidebarComponents.WALLET_ITEM.value)) :
            click_obj_by_name(SidebarComponents.ADVANCED_OPTION.value)
            click_obj_by_name(AdvancedOptionScreen.ACTIVATE_OR_DEACTIVATE_WALLET.value)
            click_obj_by_name(AdvancedOptionScreen.I_UNDERSTAND_POP_UP.value)
            verify_object_enabled(SidebarComponents.WALLET_ITEM.value)
           
        self.open_wallet_settings()

    def activate_open_wallet_section(self):
        if not (is_found(SidebarComponents.WALLET_ITEM.value)):
            click_obj_by_name(SidebarComponents.ADVANCED_OPTION.value)
            click_obj_by_name(AdvancedOptionScreen.ACTIVATE_OR_DEACTIVATE_WALLET.value)
            click_obj_by_name(AdvancedOptionScreen.I_UNDERSTAND_POP_UP.value)
            verify_object_enabled(SidebarComponents.WALLET_ITEM.value)
           
        click_obj_by_name(MainScreenComponents.WALLET_BUTTON.value)
    
    def delete_account(self, account_name: str):
        click_obj_by_name(SidebarComponents.WALLET_ITEM.value)
        
        index = self._find_account_index(account_name)
            
        if index == -1:
            raise Exception("Account not found")
        
        accounts = get_obj(WalletSettingsScreen.GENERATED_ACCOUNTS.value)
        click_obj(accounts.itemAtIndex(index))
        click_obj_by_name(WalletSettingsScreen.DELETE_ACCOUNT.value)
        click_obj_by_name(WalletSettingsScreen.DELETE_ACCOUNT_CONFIRM.value)
        
    def verify_no_account(self, account_name: str):
        index = self._find_account_index(account_name)
        verify_equal(index, -1)
        
    def verify_address(self, address: str):
        accounts = get_obj(WalletSettingsScreen.GENERATED_ACCOUNTS.value)
        verify_text_matching_insensitive(accounts.itemAtIndex(0).statusListItemSubTitle, address)
        
    def toggle_test_networks(self):
        click_obj_by_name(WalletSettingsScreen.NETWORKS_ITEM.value)
        get_and_click_obj(WalletSettingsScreen.TESTNET_TOGGLE.value)
    
    def _find_account_index(self, account_name: str) -> int:
        accounts = get_obj(WalletSettingsScreen.GENERATED_ACCOUNTS.value)
        for index in range(accounts.count):
            if(accounts.itemAtIndex(index).objectName == account_name):
                return index
        return -1
    
    def sign_out_and_quit_the_app(self, pid: int):
        SettingsScreen.__pid = pid
        click_obj_by_name(SidebarComponents.SIGN_OUT_AND_QUIT.value)
        click_obj_by_name(ConfirmationDialog.SIGN_OUT_CONFIRMATION.value)
        
    def verify_the_app_is_closed(self):
        verify_the_app_is_closed(SettingsScreen.__pid)

    def select_default_account(self):
        accounts = get_obj(WalletSettingsScreen.GENERATED_ACCOUNTS.value)
        click_obj(accounts.itemAtIndex(0))
        click_obj_by_name(WalletSettingsScreen.EDIT_ACCOUNT_BUTTON.value)

    def edit_account(self, account_name: str, account_color: str):
        type(WalletSettingsScreen.EDIT_ACCOUNT_NAME_INPUT.value, account_name)
        colorList = get_obj(WalletSettingsScreen.EDIT_ACCOUNT_COLOR_REPEATER.value)
        for index in range(colorList.count):
            color = colorList.itemAt(index)
            if(color.radioButtonColor == account_color):
                click_obj(colorList.itemAt(index))

        click_obj_by_name(WalletSettingsScreen.EDIT_ACCOUNT_SAVE_BUTTON.value)


    def verify_editedAccount(self, new_name: str, new_color: str):
        accountName = get_obj(WalletSettingsScreen.ACCOUNT_VIEW_ACCOUNT_NAME.value)
        iconSettings = get_obj(WalletSettingsScreen.ACCOUNT_VIEW_ICON_SETTINGS.value)
        verify_values_equal(str(accountName.text), str(new_name), "Edited account name not updated")
        verify_values_equal(str(iconSettings.icon.color.name), str(new_color.lower()), "Edited account color not updated")

    def open_communities_section(self):
        click_obj_by_name(SidebarComponents.COMMUNITIES_ITEM.value)

    def leave_community(self):
        StatusMainScreen.wait_for_banner_to_disappear()
        # In our case we have only one visible community and only one button
        click_obj_by_name(CommunitiesSettingsScreen.LEAVE_COMMUNITY_BUTTONS.value)
        click_obj_by_name(CommunitiesSettingsScreen.LEAVE_COMMUNITY_POPUP_LEAVE_BUTTON.value)
