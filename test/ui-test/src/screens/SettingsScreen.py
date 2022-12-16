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
import random
import time
import string
from wsgiref import validate
from drivers.SquishDriver import *
from drivers.SquishDriverVerification import *
from utils.ObjectAccess import *
from .StatusMainScreen import MainScreenComponents
from .StatusMainScreen import StatusMainScreen

class SettingsScreenComponents(Enum):
    SAVE_BUTTON: str = "settingsSave_StatusButton"

class SidebarComponents(Enum):
    ADVANCED_OPTION: str = "advanced_StatusNavigationListItem"
    WALLET_OPTION: str = "wallet_StatusNavigationListItem"
    LANGUAGE_CURRENCY_OPTION: str = "language_StatusNavigationListItem"
    SIGN_OUT_AND_QUIT_OPTION: str = "sign_out_Quit_StatusNavigationListItem"
    COMMUNITIES_OPTION: str = "communities_StatusNavigationListItem"
    PROFILE_OPTION: str = "profile_StatusNavigationListItem"
    ENS_ITEM: str = "settings_Sidebar_ENS_Item"
    MESSAGING_ITEM: str = "messaging_StatusNavigationListItem"


class AdvancedOptionScreen(Enum):
    ACTIVATE_OR_DEACTIVATE_WALLET: str = "walletSettingsLineButton"
    I_UNDERSTAND_POP_UP: str = "i_understand_StatusBaseText"

class ENSScreen(Enum):
    START_BUTTON :str = "settings_ENS_Start_Button"
    ENS_SEARCH_INPUT: str = "settings_ENS_Search_Input"
    NEXT_BUTTON: str = "settings_ENS_Search_Next_Button"
    AGREE_TERMS: str = "settings_ENS_Terms_Agree"
    OPEN_TRANSACTION: str = "settings_ENS_Terms_Open_Transaction"
    TRANSACTION_NEXT_BUTTON: str = "settings_ENS_Terms_Transaction_Next_Button"
    PASSWORD_INPUT: str = "settings_ENS_Terms_Transaction_Password_Input"
   
class MessagingOptionScreen(Enum):
    ACTIVATE_OR_DEACTIVATE_LINK_PREVIEW: str = "displayMessageLinkPreviewItem"
    LINK_PREVIEW_SWITCH: str = "linkPreviewSwitch"
    ACTIVATE_OR_DECTIVATE_IMAGE_UNFURLING: str = "imageUnfurlingItem"
    TENOR_GIFS_PREVIEW_SWITCH_ITEM: str = "tenorGifsPreviewSwitchItem"
    SCROLLVIEW: str = "settingsContentBase_ScrollView"
    CONTACTS_BTN: str = "contacts_listItem_btn"
   
class ContactsViewScreen(Enum):
    CONTACT_REQUEST_CHAT_KEY_BTN: str = "contact_request_to_chat_key_btn"
    CONTACT_REQUEST_CHAT_KEY_INPUT: str = "contactRequest_ChatKey_Input"
    CONTACT_REQUEST_SAY_WHO_YOU_ARE_INPUT: str = "contactRequest_SayWhoYouAre_Input"
    CONTACT_REQUEST_SEND_BUTTON: str = "contactRequest_Send_Button"
    CONTACT_REQUEST_PENDING_REQUEST_TAB_BUTTON: str = "contactRequest_PendingRequests_Button"
    SENT_REQUESTS_CONTACT_PANEL_LIST_VIEW: str = "sentRequests_contactListPanel_ListView"

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
    BACKUP_SEED_PHRASE_BUTTON: str = "settings_Wallet_MainView_BackupSeedPhrase"

class ProfileSettingsScreen(Enum):
    DISPLAY_NAME: str = "displayName_TextEdit"
    BIO: str = "bio_TextEdit"
    TWITTER_SOCIAL_LINK: str = "twitter_TextEdit"
    PERSONAL_SITE_SOCIAL_LINK: str = "personalSite_TextEdit"
    OPEN_SOCIAL_LINKS_DIALOG: str = "addMoreSocialLinks_StatusIconTextButton"
    CLOSE_SOCIAL_LINKS_DIALOG: str = "closeButton_StatusHeaderAction"
    TWITTER_SOCIAL_LINK_IN_DIALOG: str = "twitter_popup_TextEdit"
    PERSONAL_SITE_LINK_IN_DIALOG: str = "personalSite_popup_TextEdit"
    GITHUB_SOCIAL_LINK_IN_DIALOG: str = "github_popup_TextEdit"
    YOUTUBE_SOCIAL_LINK_IN_DIALOG: str = "youtube_popup_TextEdit"
    DISCORD_SOCIAL_LINK_IN_DIALOG: str = "discord_popup_TextEdit"
    TELEGRAM_SOCIAL_LINK_IN_DIALOG: str = "telegram_popup_TextEdit"
    CUSTOM_LINK_IN_DIALOG: str = "customLink_popup_TextEdit"
    CUSTOM_URL_IN_DIALOG: str = "customUrl_popup_TextEdit"
    CHANGE_PASSWORD_BUTTON: str = "change_password_button"

class ChangePasswordMenu(Enum):
    CHANGE_PASSWORD_CURRENT_PASSWORD_INPUT: str = "change_password_menu_current_password"
    CHANGE_PASSWORD_NEW_PASSWORD_INPUT: str = "change_password_menu_new_password"
    CHANGE_PASSWORD_NEW_PASSWORD_CONFIRM_INPUT: str = "change_password_menu_new_password_confirm"
    CHANGE_PASSWORD_SUBMIT_BUTTON: str = "change_password_menu_submit_button"
    CHANGE_PASSWORD_SUCCESS_MENU_SIGN_OUT_QUIT_BUTTON: str = "change_password_success_menu_sign_out_quit_button"

class ConfirmationDialog(Enum):
    SIGN_OUT_CONFIRMATION: str = "signOutConfirmation_StatusButton"

class CommunitiesSettingsScreen(Enum):
    LEAVE_COMMUNITY_BUTTONS: str = "settings_Communities_MainView_LeaveCommunityButtons"
    LEAVE_COMMUNITY_POPUP_LEAVE_BUTTON: str = "settings_Communities_MainView_LeavePopup_LeaveCommunityButton"

class BackupSeedPhrasePopup(Enum):
    HAVE_PEN_CHECKBOX: str = "backup_seed_phrase_popup_Acknowledgements_havePen_checkbox"
    WRITE_DOWN_CHECKBOX: str = "backup_seed_phrase_popup_Acknowledgements_writeDown_checkbox"
    STORE_IT_CHECKBOX: str = "backup_seed_phrase_popup_Acknowledgements_storeIt_checkbox"
    NEXT_BUTTON: str = "backup_seed_phrase_popup_nextButton"
    REVEAL_SEED_PHRASE_BUTTON: str = "backup_seed_phrase_popup_ConfirmSeedPhrasePanel_RevealSeedPhraseButton"
    SEED_PHRASE_WORD_PLACEHOLDER: str = "backup_seed_phrase_popup_ConfirmSeedPhrasePanel_StatusSeedPhraseInput_placeholder"
    CONFIRM_FIRST_WORD_PAGE: str = "backup_seed_phrase_popup_BackupSeedStepBase_confirmFirstWord"
    CONFIRM_FIRST_WORD_INPUT: str = "backup_seed_phrase_popup_BackupSeedStepBase_confirmFirstWord_inputText"
    CONFIRM_SECOND_WORD_PAGE: str = "backup_seed_phrase_popup_BackupSeedStepBase_confirmSecondWord"
    CONFIRM_SECOND_WORD_INPUT: str = "backup_seed_phrase_popup_BackupSeedStepBase_confirmSecondWord_inputText"
    CONFIRM_YOU_STORED_CHECKBOX: str = "backup_seed_phrase_popup_ConfirmStoringSeedPhrasePanel_storeCheck"
    CONFIRM_YOU_STORED_BUTTON: str = "backup_seed_phrase_popup_BackupSeedModal_completeAndDeleteSeedPhraseButton"

class SettingsScreen:
    __pid = 0
    
    def __init__(self):
        verify_screen(SidebarComponents.ADVANCED_OPTION.value)
    
    def open_wallet_settings(self):
        click_obj_by_name(SidebarComponents.WALLET_OPTION.value)

    def activate_wallet_option(self):
        click_obj_by_name(SidebarComponents.ADVANCED_OPTION.value)
        click_obj_by_name(AdvancedOptionScreen.ACTIVATE_OR_DEACTIVATE_WALLET.value)
        click_obj_by_name(AdvancedOptionScreen.I_UNDERSTAND_POP_UP.value)
        verify_object_enabled(SidebarComponents.WALLET_OPTION.value)

    def activate_open_wallet_section(self):
        self.activate_wallet_option()    
        click_obj_by_name(MainScreenComponents.WALLET_BUTTON.value)
    
    def delete_account(self, account_name: str):
        self.open_wallet_settings()
        
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

    # Post condition: Messaging Settings is visible (@see StatusMainScreen.open_settings)
    def open_messaging_settings(self):
        click_obj_by_name(SidebarComponents.MESSAGING_ITEM.value)

    # if link preview is activated do nothing
    def activate_link_preview_if_dectivated(self):
        click_obj_by_name(SidebarComponents.MESSAGING_ITEM.value)
        # view can be scrolled down, we need to reset scroll
        reset_scroll_obj_by_name(MessagingOptionScreen.SCROLLVIEW.value)
        scroll_item_until_item_is_visible(MessagingOptionScreen.SCROLLVIEW.value, MessagingOptionScreen.LINK_PREVIEW_SWITCH.value)
        switch = wait_and_get_obj(MessagingOptionScreen.LINK_PREVIEW_SWITCH.value)
        if not switch.checked:
            click_obj_by_name(MessagingOptionScreen.LINK_PREVIEW_SWITCH.value)

    # Post condition: Messaging Settings is active and Link Preview is activated (@see open_messaging_settings and activate_link_preview_if_dectivated)
    def activate_image_unfurling(self):
        scroll_item_until_item_is_visible(MessagingOptionScreen.SCROLLVIEW.value, MessagingOptionScreen.ACTIVATE_OR_DECTIVATE_IMAGE_UNFURLING.value)
        click_obj_by_name(MessagingOptionScreen.ACTIVATE_OR_DECTIVATE_IMAGE_UNFURLING.value)

    # Post condition: Messaging Settings is active and Link Preview is activated (@see open_messaging_settings and activate_link_preview_if_dectivated)
    def the_user_activates_tenor_gif_preview(self):
        click_obj_by_name(SidebarComponents.MESSAGING_ITEM.value)
        scroll_item_until_item_is_visible(MessagingOptionScreen.SCROLLVIEW.value, MessagingOptionScreen.TENOR_GIFS_PREVIEW_SWITCH_ITEM.value)
        click_obj_by_name(MessagingOptionScreen.TENOR_GIFS_PREVIEW_SWITCH_ITEM.value)

    def toggle_test_networks(self):
        # needed cause if we do it immmediately the toggle doesn't work
        time.sleep(2)
        click_obj_by_name(WalletSettingsScreen.NETWORKS_ITEM.value)
        click_obj_by_name(WalletSettingsScreen.TESTNET_TOGGLE.value)      
        
    def open_language_and_currency_settings(self):
        click_obj_by_name(SidebarComponents.LANGUAGE_CURRENCY_OPTION.value)

    def register_random_ens_name(self, password: str):
        click_obj_by_name(SidebarComponents.ENS_ITEM.value)
        get_and_click_obj(ENSScreen.START_BUTTON.value)
        
        name = ""
        for _ in range(4):
            name += string.ascii_lowercase[random.randrange(26)]
            
        type(ENSScreen.ENS_SEARCH_INPUT.value, name)
        time.sleep(1)
        
        click_obj_by_name(ENSScreen.NEXT_BUTTON.value)
        click_obj_by_name(ENSScreen.AGREE_TERMS.value)
        click_obj_by_name(ENSScreen.OPEN_TRANSACTION.value)
        click_obj_by_name(ENSScreen.TRANSACTION_NEXT_BUTTON.value)
        click_obj_by_name(ENSScreen.TRANSACTION_NEXT_BUTTON.value)
        
        type(ENSScreen.PASSWORD_INPUT.value, password)
        click_obj_by_name(ENSScreen.TRANSACTION_NEXT_BUTTON.value)
    
    def _find_account_index(self, account_name: str) -> int:
        accounts = get_obj(WalletSettingsScreen.GENERATED_ACCOUNTS.value)
        for index in range(accounts.count):
            if(accounts.itemAtIndex(index).objectName == account_name):
                return index
        return -1
    
    def sign_out_and_quit_the_app(self, pid: int):
        SettingsScreen.__pid = pid
        click_obj_by_name(SidebarComponents.SIGN_OUT_AND_QUIT_OPTION.value)
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
        verify_values_equal(str(iconSettings.asset.color.name), str(new_color.lower()), "Edited account color not updated")

    def open_communities_section(self):
        click_obj_by_name(SidebarComponents.COMMUNITIES_OPTION.value)

    def leave_community(self):
        # In our case we have only one visible community and only one button
        click_obj_by_name(CommunitiesSettingsScreen.LEAVE_COMMUNITY_BUTTONS.value)
        click_obj_by_name(CommunitiesSettingsScreen.LEAVE_COMMUNITY_POPUP_LEAVE_BUTTON.value)

    def open_profile_settings(self):
        verify_object_enabled(SidebarComponents.PROFILE_OPTION.value)
        click_obj_by_name(SidebarComponents.PROFILE_OPTION.value)

    def verify_display_name(self, display_name: str):
        verify_text_matching(ProfileSettingsScreen.DISPLAY_NAME.value, display_name)

    def set_display_name(self, display_name: str):
        click_obj_by_name(ProfileSettingsScreen.DISPLAY_NAME.value)
        name_changed = setText(ProfileSettingsScreen.DISPLAY_NAME.value, display_name)
        verify(name_changed, "set display name")
        click_obj_by_name(SettingsScreenComponents.SAVE_BUTTON.value)
        self.verify_display_name(display_name)

    def verify_bio(self, bio: str):
        verify_text_matching(ProfileSettingsScreen.BIO.value, bio)

    def set_bio(self, bio: str):
        click_obj_by_name(ProfileSettingsScreen.BIO.value)
        verify(setText(ProfileSettingsScreen.BIO.value, bio), "set bio")
        click_obj_by_name(SettingsScreenComponents.SAVE_BUTTON.value)
        self.verify_bio(bio)

    def set_social_links(self, table):
        
        twitter = ""
        personal_site = ""
        github = ""
        youtube = ""
        discord = ""
        telegram = ""
        custom_link_text = ""
        custom_link = ""
        
        if table is not None:
            verify_equals(8, len(table)) # Expecting 8 as social media link fields to verify
            twitter = table[0][0]
            personal_site = table[1][0]
            github = table[2][0]
            youtube = table[3][0]
            discord = table[4][0]
            telegram = table[5][0]
            custom_link_text = table[6][0]
            custom_link = table[7][0]       
        
        click_obj_by_name(ProfileSettingsScreen.OPEN_SOCIAL_LINKS_DIALOG.value)

        click_obj_by_name(ProfileSettingsScreen.TWITTER_SOCIAL_LINK_IN_DIALOG.value)
        verify(setText(ProfileSettingsScreen.TWITTER_SOCIAL_LINK_IN_DIALOG.value, twitter), "set twitter")
        click_obj_by_name(ProfileSettingsScreen.PERSONAL_SITE_LINK_IN_DIALOG.value)
        verify(setText(ProfileSettingsScreen.PERSONAL_SITE_LINK_IN_DIALOG.value, personal_site), "set personal site")
        click_obj_by_name(ProfileSettingsScreen.GITHUB_SOCIAL_LINK_IN_DIALOG.value)
        verify(setText(ProfileSettingsScreen.GITHUB_SOCIAL_LINK_IN_DIALOG.value, github), "set github")
        click_obj_by_name(ProfileSettingsScreen.YOUTUBE_SOCIAL_LINK_IN_DIALOG.value)
        verify(setText(ProfileSettingsScreen.YOUTUBE_SOCIAL_LINK_IN_DIALOG.value, youtube), "set youtube")
        click_obj_by_name(ProfileSettingsScreen.DISCORD_SOCIAL_LINK_IN_DIALOG.value)
        verify(setText(ProfileSettingsScreen.DISCORD_SOCIAL_LINK_IN_DIALOG.value, discord), "set discord")
        click_obj_by_name(ProfileSettingsScreen.TELEGRAM_SOCIAL_LINK_IN_DIALOG.value)
        verify(setText(ProfileSettingsScreen.TELEGRAM_SOCIAL_LINK_IN_DIALOG.value, telegram), "set telegram")
        click_obj_by_name(ProfileSettingsScreen.CUSTOM_LINK_IN_DIALOG.value)
        verify(setText(ProfileSettingsScreen.CUSTOM_LINK_IN_DIALOG.value, custom_link_text), "set custom link name")
        click_obj_by_name(ProfileSettingsScreen.CUSTOM_URL_IN_DIALOG.value)
        verify(setText(ProfileSettingsScreen.CUSTOM_URL_IN_DIALOG.value, custom_link), "set custom link url")

        click_obj_by_name(ProfileSettingsScreen.CLOSE_SOCIAL_LINKS_DIALOG.value)
        click_obj_by_name(SettingsScreenComponents.SAVE_BUTTON.value)

    def verify_social_links(self, table):
        
        twitter = ""
        personal_site = ""
        github = ""
        youtube = ""
        discord = ""
        telegram = ""
        custom_link_text = ""
        custom_link = ""
        
        if table is not None:
            verify_equals(8, len(table)) # Expecting 8 as social media link fields to verify
            twitter = table[0][0]
            personal_site = table[1][0]
            github = table[2][0]
            youtube = table[3][0]
            discord = table[4][0]
            telegram = table[5][0]
            custom_link_text = table[6][0]
            custom_link = table[7][0]       
        
        verify_text_matching(ProfileSettingsScreen.TWITTER_SOCIAL_LINK.value, twitter)
        verify_text_matching(ProfileSettingsScreen.PERSONAL_SITE_SOCIAL_LINK.value, personal_site)

        click_obj_by_name(ProfileSettingsScreen.OPEN_SOCIAL_LINKS_DIALOG.value)
        verify_text_matching(ProfileSettingsScreen.TWITTER_SOCIAL_LINK_IN_DIALOG.value, twitter)
        verify_text_matching(ProfileSettingsScreen.PERSONAL_SITE_LINK_IN_DIALOG.value, personal_site)
        verify_text_matching(ProfileSettingsScreen.GITHUB_SOCIAL_LINK_IN_DIALOG.value, github)
        verify_text_matching(ProfileSettingsScreen.YOUTUBE_SOCIAL_LINK_IN_DIALOG.value, youtube)
        verify_text_matching(ProfileSettingsScreen.DISCORD_SOCIAL_LINK_IN_DIALOG.value, discord)
        verify_text_matching(ProfileSettingsScreen.TELEGRAM_SOCIAL_LINK_IN_DIALOG.value, telegram)
        verify_text_matching(ProfileSettingsScreen.CUSTOM_LINK_IN_DIALOG.value, custom_link_text)
        verify_text_matching(ProfileSettingsScreen.CUSTOM_URL_IN_DIALOG.value, custom_link)
        click_obj_by_name(ProfileSettingsScreen.CLOSE_SOCIAL_LINKS_DIALOG.value)

    def check_backup_seed_phrase_workflow(self):
        self.open_wallet_settings()
        click_obj_by_name(WalletSettingsScreen.BACKUP_SEED_PHRASE_BUTTON.value)

        # Check all checkboxes and click next button
        obj = wait_and_get_obj(BackupSeedPhrasePopup.HAVE_PEN_CHECKBOX.value)
        obj.checked = True
        obj = wait_and_get_obj(BackupSeedPhrasePopup.WRITE_DOWN_CHECKBOX.value)
        obj.checked = True
        obj = wait_and_get_obj(BackupSeedPhrasePopup.STORE_IT_CHECKBOX.value)
        obj.checked = True
        click_obj_by_name(BackupSeedPhrasePopup.NEXT_BUTTON.value)

        # Show seed phrase
        click_obj_by_name(BackupSeedPhrasePopup.REVEAL_SEED_PHRASE_BUTTON.value)

        # Collect word phrases for the next random confirmation steps
        seed_phrase = [wait_by_wildcards(BackupSeedPhrasePopup.SEED_PHRASE_WORD_PLACEHOLDER.value, "%WORD_NO%", str(i + 1)).textEdit.input.edit.text for i in range(12)]
        click_obj_by_name(BackupSeedPhrasePopup.NEXT_BUTTON.value)

        # Confirm first random word of the seed phrase
        firstSeedBaseObj = wait_and_get_obj(BackupSeedPhrasePopup.CONFIRM_FIRST_WORD_PAGE.value)
        firstSeedWord = str(seed_phrase[firstSeedBaseObj.wordRandomNumber])
        wait_for_object_and_type(BackupSeedPhrasePopup.CONFIRM_FIRST_WORD_INPUT.value, firstSeedWord)
        click_obj_by_name(BackupSeedPhrasePopup.NEXT_BUTTON.value)

        # Confirm second random word of the seed phrase
        secondSeedBaseObj = wait_and_get_obj(BackupSeedPhrasePopup.CONFIRM_SECOND_WORD_PAGE.value)
        secondSeedWord = str(seed_phrase[secondSeedBaseObj.wordRandomNumber])
        wait_for_object_and_type(BackupSeedPhrasePopup.CONFIRM_SECOND_WORD_INPUT.value, secondSeedWord)

        click_obj_by_name(BackupSeedPhrasePopup.NEXT_BUTTON.value)

        # Acknowledge and confirm that you won't have access to the seed phrase anymore
        obj = wait_and_get_obj(BackupSeedPhrasePopup.CONFIRM_YOU_STORED_CHECKBOX.value)
        obj.checked = True
        click_obj_by_name(BackupSeedPhrasePopup.CONFIRM_YOU_STORED_BUTTON.value)

    def verify_seed_phrase_indicator_not_visible(self):
        verify_not_found(WalletSettingsScreen.BACKUP_SEED_PHRASE_BUTTON.value, "Check that backup seed phrase settings button is visible")
        
    def change_user_password(self, oldPassword: str, newPassword: str):
        get_and_click_obj(ProfileSettingsScreen.CHANGE_PASSWORD_BUTTON.value)
        
        type(ChangePasswordMenu.CHANGE_PASSWORD_CURRENT_PASSWORD_INPUT.value, oldPassword)
        
        type(ChangePasswordMenu.CHANGE_PASSWORD_NEW_PASSWORD_INPUT.value, newPassword)

        type(ChangePasswordMenu.CHANGE_PASSWORD_NEW_PASSWORD_CONFIRM_INPUT.value, newPassword)

        click_obj_by_name(ChangePasswordMenu.CHANGE_PASSWORD_SUBMIT_BUTTON.value)
        click_obj_by_name(ChangePasswordMenu.CHANGE_PASSWORD_SUCCESS_MENU_SIGN_OUT_QUIT_BUTTON.value)
        
    def add_contact_by_chat_key(self, chat_key: str, who_you_are: str):
        click_obj_by_name(MessagingOptionScreen.CONTACTS_BTN.value)
        click_obj_by_name(ContactsViewScreen.CONTACT_REQUEST_CHAT_KEY_BTN.value)
        
        type(ContactsViewScreen.CONTACT_REQUEST_CHAT_KEY_INPUT.value, chat_key)
        type(ContactsViewScreen.CONTACT_REQUEST_SAY_WHO_YOU_ARE_INPUT.value, who_you_are)
        
        click_obj_by_name(ContactsViewScreen.CONTACT_REQUEST_SEND_BUTTON.value)

    def verify_contact_request(self, chat_key: str):
        click_obj_by_name(ContactsViewScreen.CONTACT_REQUEST_PENDING_REQUEST_TAB_BUTTON.value)
        contact_list = get_obj(ContactsViewScreen.SENT_REQUESTS_CONTACT_PANEL_LIST_VIEW.value)
        contact_keys = []
        for index in range(contact_list.count):
            contact = contact_list.itemAtIndex(index)
            contact_keys.append(str(contact.compressedPk))
            if (contact.compressedPk == chat_key):
                return
        contact_keys_tr = ", ".join(contact_keys)
        verify_failure(f'The list of pending contacts contains "{contact_keys_tr}"  but we wanted the key"{chat_key}"')
        
        
