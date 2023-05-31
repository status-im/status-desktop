# ******************************************************************************
# Status.im
# *****************************************************************************/
# /**
# * \file    SettingsScreen.py
# *
# * \date    June 2022
# * \brief   Home Screen.
# *****************************************************************************/


import random
import string
from enum import Enum

from drivers.SquishDriver import *
from drivers.SquishDriverVerification import *
from utils.ObjectAccess import *

from .StatusMainScreen import MainScreenComponents
from .StatusMainScreen import authenticate_popup_enter_password
from .components.change_password_popup import ChangePasswordPopup
from .components.social_links_popup import SocialLinksPopup


class SignOutPopup(BaseElement):

    def __init__(self):
        super(SignOutPopup, self).__init__('statusDesktop_mainWindow_overlay')
        self._sign_out_quit_button = Button('signOutConfirmation_StatusButton')

    def sign_out_and_quit(self):
        self._sign_out_quit_button.click()


class MenuPanel(BaseElement):

    def __init__(self):
        super(MenuPanel, self).__init__('mainWindow_LeftTabView')
        self._scroll = Scroll('LeftTabView_ScrollView')
        self._back_up_seed_phrase_item = Button('sign_out_Quit_StatusNavigationListItem')

    def sign_out_and_quit(self):
        self._scroll.vertical_scroll_to(self._back_up_seed_phrase_item)
        self._back_up_seed_phrase_item.click()
        SignOutPopup().wait_until_appears().sign_out_and_quit()


class SidebarComponents(Enum):
    ADVANCED_OPTION: str = "advanced_StatusNavigationListItem"
    KEYCARD_OPTION: str = "keycard_StatusNavigationListItem"
    WALLET_OPTION: str = "wallet_StatusNavigationListItem"
    LANGUAGE_CURRENCY_OPTION: str = "language_StatusNavigationListItem"
    SIGN_OUT_AND_QUIT_OPTION: str = "sign_out_Quit_StatusNavigationListItem"
    COMMUNITIES_OPTION: str = "communities_StatusNavigationListItem"
    PROFILE_OPTION: str = "profile_StatusNavigationListItem"
    ENS_ITEM: str = "settings_Sidebar_ENS_Item"
    MESSAGING_ITEM: str = "messaging_StatusNavigationListItem"


class AdvancedOptionScreen(Enum):
    ACTIVATE_OR_DEACTIVATE_COMMUNITY_PERMISSIONS: str = "communitySettingsLineButton"
    I_UNDERSTAND_POP_UP: str = "i_understand_StatusBaseText"


class ENSScreen(Enum):
    START_BUTTON: str = "settings_ENS_Start_Button"
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
    RECEIVED_REQUESTS_CONTACT_PANEL_LIST_VIEW: str = "receivedRequests_contactListPanel_ListView"


class ProfilePopupScreen(Enum):
    PROFILE_POPUP_SEND_CONTACT_REQUEST_BUTTON = "ProfilePopup_SendContactRequestButton"
    SAY_WHO_YOU_ARE_INPUT: str = "ProfilePopup_SayWhoYouAre_TextEdit"
    SEND_CONTACT_REQUEST_BUTTON: str = "ProfilePopup_SendContactRequest_Button"


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


class CommunitiesSettingsScreen(Enum):
    LIST_PANEL: str = "settings_Communities_CommunitiesListPanel"
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
        self.menu = MenuPanel()
        self._profile_view = ProfileSettingsView()
        self._profile_button = Button('profile_StatusNavigationListItem')

    @property
    def profile_settings(self) -> 'ProfileSettingsView':
        if not self._profile_button.is_selected:
            verify_object_enabled(SidebarComponents.PROFILE_OPTION.value)
            self._profile_button.click()
        return self._profile_view

    def open_advanced_settings(self):
        click_obj_by_name(SidebarComponents.ADVANCED_OPTION.value)

    def open_wallet_settings(self):
        click_obj_by_name(SidebarComponents.WALLET_OPTION.value)

    def open_wallet_section(self):
        click_obj_by_name(MainScreenComponents.WALLET_BUTTON.value)

    def delete_account(self, account_name: str, password: str):
        self.open_wallet_settings()

        index = self._find_account_index(account_name)

        if index == -1:
            raise Exception("Account not found")

        accounts = get_obj(WalletSettingsScreen.GENERATED_ACCOUNTS.value)
        click_obj(accounts.itemAtIndex(index))
        click_obj_by_name(WalletSettingsScreen.DELETE_ACCOUNT.value)
        click_obj_by_name(WalletSettingsScreen.DELETE_ACCOUNT_CONFIRM.value)

        authenticate_popup_enter_password(password)

    def verify_no_account(self, account_name: str):
        index = self._find_account_index(account_name)
        verify_equal(index, -1)

    def verify_address(self, address: str):
        accounts = get_obj(WalletSettingsScreen.GENERATED_ACCOUNTS.value)
        verify_text_matching_insensitive(accounts.itemAtIndex(0).statusListItemSubTitle, address)

    # Post condition: Messaging Settings is visible (@see StatusMainScreen.open_settings)
    def open_messaging_settings(self):
        click_obj_by_name(SidebarComponents.MESSAGING_ITEM.value)

    def open_contacts_settings(self):
        click_obj_by_name(MessagingOptionScreen.CONTACTS_BTN.value)

    # if link preview is activated do nothing
    def activate_link_preview_if_dectivated(self):
        click_obj_by_name(SidebarComponents.MESSAGING_ITEM.value)
        # view can be scrolled down, we need to reset scroll
        reset_scroll_obj_by_name(MessagingOptionScreen.SCROLLVIEW.value)
        scroll_item_until_item_is_visible(MessagingOptionScreen.SCROLLVIEW.value,
                                          MessagingOptionScreen.LINK_PREVIEW_SWITCH.value)
        switch = wait_and_get_obj(MessagingOptionScreen.LINK_PREVIEW_SWITCH.value)
        if not switch.checked:
            click_obj_by_name(MessagingOptionScreen.LINK_PREVIEW_SWITCH.value)

    # Post condition: Messaging Settings is active and Link Preview is activated (@see open_messaging_settings and activate_link_preview_if_dectivated)
    def activate_image_unfurling(self):
        scroll_item_until_item_is_visible(MessagingOptionScreen.SCROLLVIEW.value,
                                          MessagingOptionScreen.ACTIVATE_OR_DECTIVATE_IMAGE_UNFURLING.value)
        click_obj_by_name(MessagingOptionScreen.ACTIVATE_OR_DECTIVATE_IMAGE_UNFURLING.value)

    # Post condition: Messaging Settings is active and Link Preview is activated (@see open_messaging_settings and activate_link_preview_if_dectivated)
    def the_user_activates_tenor_gif_preview(self):
        click_obj_by_name(SidebarComponents.MESSAGING_ITEM.value)
        scroll_item_until_item_is_visible(MessagingOptionScreen.SCROLLVIEW.value,
                                          MessagingOptionScreen.TENOR_GIFS_PREVIEW_SWITCH_ITEM.value)
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

        type_text(ENSScreen.ENS_SEARCH_INPUT.value, name)
        time.sleep(1)

        click_obj_by_name(ENSScreen.NEXT_BUTTON.value)
        click_obj_by_name(ENSScreen.AGREE_TERMS.value)
        click_obj_by_name(ENSScreen.OPEN_TRANSACTION.value)
        click_obj_by_name(ENSScreen.TRANSACTION_NEXT_BUTTON.value)
        click_obj_by_name(ENSScreen.TRANSACTION_NEXT_BUTTON.value)

        type_text(ENSScreen.PASSWORD_INPUT.value, password)
        click_obj_by_name(ENSScreen.TRANSACTION_NEXT_BUTTON.value)

    def _find_account_index(self, account_name: str) -> int:
        accounts = get_obj(WalletSettingsScreen.GENERATED_ACCOUNTS.value)
        for index in range(accounts.count):
            if (accounts.itemAtIndex(index).objectName == account_name):
                return index
        return -1

    def verify_the_app_is_closed(self):
        verify_the_app_is_closed(SettingsScreen.__pid)

    def select_default_account(self):
        accounts = get_obj(WalletSettingsScreen.GENERATED_ACCOUNTS.value)
        click_obj(accounts.itemAtIndex(0))
        click_obj_by_name(WalletSettingsScreen.EDIT_ACCOUNT_BUTTON.value)

    def edit_account(self, account_name: str, account_color: str):
        type_text(WalletSettingsScreen.EDIT_ACCOUNT_NAME_INPUT.value, account_name)
        colorList = get_obj(WalletSettingsScreen.EDIT_ACCOUNT_COLOR_REPEATER.value)
        for index in range(colorList.count):
            color = colorList.itemAt(index)
            if (color.radioButtonColor == account_color):
                click_obj(colorList.itemAt(index))

        click_obj_by_name(WalletSettingsScreen.EDIT_ACCOUNT_SAVE_BUTTON.value)

    def verify_editedAccount(self, new_name: str, new_color: str):
        accountName = get_obj(WalletSettingsScreen.ACCOUNT_VIEW_ACCOUNT_NAME.value)
        iconSettings = get_obj(WalletSettingsScreen.ACCOUNT_VIEW_ICON_SETTINGS.value)
        verify_values_equal(str(accountName.text), str(new_name), "Edited account name not updated")
        verify_values_equal(str(iconSettings.asset.color.name), str(new_color.lower()),
                            "Edited account color not updated")

    def open_communities_section(self):
        click_obj_by_name(SidebarComponents.COMMUNITIES_OPTION.value)

    def leave_community(self, community_name: str):
        communities_list = get_obj(CommunitiesSettingsScreen.LIST_PANEL.value)
        verify(communities_list.count > 0, "At least one joined community exists")
        for i in range(communities_list.count):
            delegate = communities_list.itemAtIndex(i)
            if str(delegate.title) == community_name:
                buttons = get_children_with_object_name(delegate, "CommunitiesListPanel_leaveCommunityPopupButton")
                verify(len(buttons) > 0, "Leave community button exists")
                click_obj(buttons[0])
                click_obj_by_name(CommunitiesSettingsScreen.LEAVE_COMMUNITY_POPUP_LEAVE_BUTTON.value)
                return
        verify(False, "Community left")

    def check_backup_seed_phrase_workflow(self):
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
        started_at = time.monotonic()
        while wait_for_is_visible(BackupSeedPhrasePopup.REVEAL_SEED_PHRASE_BUTTON.value, verify=False):
            try:
                click_obj_by_name(BackupSeedPhrasePopup.REVEAL_SEED_PHRASE_BUTTON.value)
            except (LookupError, RuntimeError) as error:           
                pass
            if time.monotonic() - started_at > 10:
                raise RuntimeError('Reveal seed phrase button not clicked')

        # Collect word phrases for the next random confirmation steps
        seed_phrase = [wait_by_wildcards(BackupSeedPhrasePopup.SEED_PHRASE_WORD_PLACEHOLDER.value, "%WORD_NO%",
                                         str(i + 1)).textEdit.input.edit.text for i in range(12)]
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
        assert wait_until_hidden(
            WalletSettingsScreen.BACKUP_SEED_PHRASE_BUTTON.value,
        ), "Backup seed phrase settings button is visible"

    def add_contact_by_chat_key(self, chat_key: str, who_you_are: str):
        click_obj_by_name(ContactsViewScreen.CONTACT_REQUEST_CHAT_KEY_BTN.value)

        type_text(ContactsViewScreen.CONTACT_REQUEST_CHAT_KEY_INPUT.value, chat_key)
        type_text(ContactsViewScreen.CONTACT_REQUEST_SAY_WHO_YOU_ARE_INPUT.value, who_you_are)

        click_obj_by_name(ContactsViewScreen.CONTACT_REQUEST_SEND_BUTTON.value)

    def send_contact_request_via_profile_popup(self, who_you_are: str):
        click_obj_by_name(ProfilePopupScreen.PROFILE_POPUP_SEND_CONTACT_REQUEST_BUTTON.value)
        type_text(ProfilePopupScreen.SAY_WHO_YOU_ARE_INPUT.value, who_you_are)

        click_obj_by_name(ProfilePopupScreen.SEND_CONTACT_REQUEST_BUTTON.value)

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

    def verify_there_is_a_sent_contact_request(self):
        click_obj_by_name(ContactsViewScreen.CONTACT_REQUEST_PENDING_REQUEST_TAB_BUTTON.value)
        contact_list = get_obj(ContactsViewScreen.SENT_REQUESTS_CONTACT_PANEL_LIST_VIEW.value)
        verify_equal(contact_list.count, 1, "Checking if there is exactly one pending contact request")

    def verify_there_is_a_received_contact_request(self):
        click_obj_by_name(ContactsViewScreen.CONTACT_REQUEST_PENDING_REQUEST_TAB_BUTTON.value)
        contact_list = get_obj(ContactsViewScreen.RECEIVED_REQUESTS_CONTACT_PANEL_LIST_VIEW.value)
        verify_equal(contact_list.count, 1, "Checking if there is exactly one pending contact request")

    def open_community(self, community_name: str):
        communities_list = get_obj(CommunitiesSettingsScreen.LIST_PANEL.value)
        verify(communities_list.count > 0, "At least one joined community exists")
        for i in range(communities_list.count):
            delegate = communities_list.itemAtIndex(i)
            if str(delegate.title) == community_name:
                click_obj(delegate)
                return
        verify(False, "Community not found")
        
    def toggle_experimental_feature(self, settings_type: str):
        warning("TODO: Implement toggle_experimental_feature method foreach settings type")


class ProfileSettingsView(BaseElement):

    def __init__(self):
        super(ProfileSettingsView, self).__init__('mainWindow_MyProfileView')
        self._scroll_view = Scroll('settingsContentBase_ScrollView')
        self._display_name_text_field = TextEdit('displayName_TextEdit')
        self._bio_text_field = TextEdit('bio_TextEdit')
        self._add_more_links_label = TextLabel('addMoreSocialLinks')
        self._save_button = Button('settingsSave_StatusButton')
        self._links_list = BaseElement('linksView')
        self._change_password_button = Button('change_password_button')

    @property
    def display_name(self) -> str:
        self._scroll_view.vertical_scroll_to(self._display_name_text_field)
        return self._display_name_text_field.text

    @display_name.setter
    def display_name(self, value: str):
        self._scroll_view.vertical_scroll_to(self._display_name_text_field)
        self._display_name_text_field.text = value
        self.save_changes()

    @property
    def bio(self) -> str:
        self._scroll_view.vertical_scroll_to(self._display_name_text_field)
        return self._bio_text_field.text

    @bio.setter
    def bio(self, value: str):
        self._scroll_view.vertical_scroll_to(self._display_name_text_field)
        self._bio_text_field.text = value
        self.save_changes()

    @property
    def social_links(self) -> dict:
        self._scroll_view.vertical_scroll_to(self._add_more_links_label)
        links = {}
        for link_name in walk_children(self._links_list.existent):
            if getattr(link_name, 'id', '') == 'draggableDelegate':
                for link_value in walk_children(link_name):
                    if getattr(link_value, 'id', '') == 'textMouseArea':
                        links[str(link_name.title)] = str(object.parent(link_value).text)
        return links

    @social_links.setter
    def social_links(self, table):
        verify_equals(8, len(table))  # Expecting 8 as social media link fields to verify
        links = {
            'Twitter': [table[0][0]],
            'Personal Site': [table[1][0]],
            'Github': [table[2][0]],
            'YouTube': [table[3][0]],
            'Discord': [table[4][0]],
            'Telegram': [table[5][0]],
            'Custom link': [table[6][0], table[7][0]],
        }

        for network, link in links.items():
            social_links_popup = self.open_social_links_popup()
            social_links_popup.add_link(network, link)

    def save_changes(self):
        self._save_button.click()

    def open_social_links_popup(self):
        self._scroll_view.vertical_scroll_to(self._add_more_links_label)
        self._add_more_links_label.click()
        return SocialLinksPopup().wait_until_appears()

    def verify_display_name(self, display_name: str):
        self._scroll_view.vertical_scroll_to(self._display_name_text_field)
        compare_text(display_name, self.display_name)

    def verify_bio(self, bio: str):
        compare_text(bio, self.bio)

    def verify_social_links(self, table):
        verify_equals(8, len(table))  # Expecting 8 as social media link fields to verify
        twitter = table[0][0]
        personal_site = table[1][0]
        github = table[2][0]
        youtube = table[3][0]
        discord = table[4][0]
        telegram = table[5][0]
        custom_link_text = table[6][0]
        custom_link = table[7][0]

        links = self.social_links

        compare_text(links['Twitter'], twitter)
        compare_text(links['Personal Site'], personal_site)
        compare_text(links['Github'], github)
        compare_text(links['YouTube'], youtube)
        compare_text(links['Discord'], discord)
        compare_text(links['Telegram'], telegram)
        compare_text(links[custom_link_text], custom_link)

    def verify_social_no_links(self):
        links = self.social_links
        for value in links.values():
            compare_text(value, '')

    def open_change_password_popup(self):
        self._scroll_view.vertical_scroll_to(self._change_password_button)
        self._change_password_button.click()
        return ChangePasswordPopup().wait_until_appears()
