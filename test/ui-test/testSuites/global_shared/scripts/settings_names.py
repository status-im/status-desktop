from scripts.global_names import *
from enum import Enum

# Side bar section items object name helpers:
_MAIN_MENU_ITEM_OBJ_NAME = "-MainMenuItem"
_APP_MENU_ITEM_OBJ_NAME = "-AppMenuItem"
_SETTINGS_MENU_ITEM_OBJ_NAME = "-SettingsMenuItem"
_EXTRA_MENU_ITEM_OBJ_NAME = "-ExtraMenuItem"

# This is the exact enum definition done in app `Constants.qml` to determine each subsection itemId of each navigation list item
# These values are used to determine the dynamic `objectName` of the subsection item instead of using "design" properties like `text`.
class SettingsSubsection(Enum):
    PROFILE: str = "0" + _MAIN_MENU_ITEM_OBJ_NAME
    CONTACTS: str = "1" + _MAIN_MENU_ITEM_OBJ_NAME
    ENS_USERNAMES: str = "2" + _MAIN_MENU_ITEM_OBJ_NAME
    MESSAGING: str = "3" + _APP_MENU_ITEM_OBJ_NAME
    WALLET: str = "4" + _APP_MENU_ITEM_OBJ_NAME
    APPEARANCE: str = "5" + _SETTINGS_MENU_ITEM_OBJ_NAME
    LANGUAGE: str = "6" + _SETTINGS_MENU_ITEM_OBJ_NAME
    NOTIFICATIONS: str = "7" + _SETTINGS_MENU_ITEM_OBJ_NAME
    DEVICE_SETTINGS: str = "8" + _SETTINGS_MENU_ITEM_OBJ_NAME
    BROWSER: str = "9" + _APP_MENU_ITEM_OBJ_NAME
    ADVANCED: str = "10" + _SETTINGS_MENU_ITEM_OBJ_NAME
    ABOUT: str = "11" + _EXTRA_MENU_ITEM_OBJ_NAME
    COMMUNITY: str = "12" + _APP_MENU_ITEM_OBJ_NAME
    KEYCARD: str = "13" + _MAIN_MENU_ITEM_OBJ_NAME
    SIGNOUT: str = "14" + _EXTRA_MENU_ITEM_OBJ_NAME
    BACKUP_SEED: str = "15" + _MAIN_MENU_ITEM_OBJ_NAME

# Main:
navBarListView_Settings_navbar_StatusNavBarTabButton = {"checkable": True, "container": mainWindow_navBarListView_ListView, "objectName": "Settings-navbar", "type": "StatusNavBarTabButton", "visible": True}
settingsSave_StatusButton = {"container": statusDesktop_mainWindow, "objectName": "settingsDirtyToastMessageSaveButton", "type": "StatusButton", "visible": True}
settings_Sidebar_ENS_Item = {"container": mainWindow_ScrollView, "objectName": "ENS usernames-MainMenu", "type": "StatusNavigationListItem"}

# ENS view;
settings_ENS_Start_Button = {"container": statusDesktop_mainWindow, "objectName": "ensStartButton", "type": "StatusButton"}
settings_ENS_Search_Input = {"container": statusDesktop_mainWindow, "objectName": "ensUsernameInput", "type": "StyledTextField"}
settings_ENS_Search_Next_Button = {"container": statusDesktop_mainWindow, "objectName": "ensNextButton", "type": "StatusRoundButton"}
settings_ENS_Terms_Agree = {"container": statusDesktop_mainWindow, "objectName": "ensAgreeTerms", "type": "StatusCheckBox"}
settings_ENS_Terms_Open_Transaction = {"container": statusDesktop_mainWindow, "objectName": "ensStartTransaction", "type": "StatusButton"}
settings_ENS_Terms_Transaction_Next_Button = {"container": statusDesktop_mainWindow, "objectName": "sendNextButton", "type": "StatusButton"}
settings_ENS_Terms_Transaction_Password_Input = {"container": statusDesktop_mainWindow, "objectName": "transactionSignerPasswordInput", "type": "StyledTextField"}

# Side bar items (Secondary navigation):
wallet_StatusNavigationListItem = {"container": mainWindow_ScrollView, "objectName": SettingsSubsection.WALLET.value, "type": "StatusNavigationListItem", "visible": True}
language_StatusNavigationListItem = {"container": mainWindow_ScrollView, "objectName": SettingsSubsection.LANGUAGE.value, "type": "StatusNavigationListItem", "visible": True}
advanced_StatusNavigationListItem = {"container": mainWindow_ScrollView, "objectName": SettingsSubsection.ADVANCED.value, "type": "StatusNavigationListItem", "visible": True}
sign_out_Quit_StatusNavigationListItem = {"container": mainWindow_ScrollView, "objectName": SettingsSubsection.SIGNOUT.value, "type": "StatusNavigationListItem", "visible": True}
communities_StatusNavigationListItem = {"container": mainWindow_ScrollView, "objectName": SettingsSubsection.COMMUNITY.value, "type": "StatusNavigationListItem", "visible": True}
profile_StatusNavigationListItem = {"container": mainWindow_ScrollView, "objectName": SettingsSubsection.PROFILE.value, "type": "StatusNavigationListItem", "visible": True}
messaging_StatusNavigationListItem = {"container": mainWindow_ScrollView, "objectName": SettingsSubsection.MESSAGING.value, "type": "StatusNavigationListItem", "visible": True}


# Profile Settings:
displayName_StatusInput = {"container": mainWindow_ScrollView_2, "objectName": "displayNameInput", "type": "StatusInput", "visible": True}
displayName_TextEdit = {"container": displayName_StatusInput, "type": "TextEdit", "unnamed": 1, "visible": True}
bio_StatusInput = {"container": mainWindow_ScrollView_2, "objectName": "bioInput", "type": "StatusInput", "visible": True}
bio_TextEdit = {"container": bio_StatusInput, "type": "TextEdit", "unnamed": 1, "visible": True}
twitter_StaticSocialLinkInput = {"container": mainWindow_ScrollView_2, "objectName": "__twitter-socialLinkInput", "type": "StaticSocialLinkInput", "visible": True}
personalSite_StaticSocialLinkInput = {"container": mainWindow_ScrollView_2, "objectName": "__personal_site-socialLinkInput", "type": "StaticSocialLinkInput", "visible": True}
addMoreSocialLinks_StatusIconTextButton = {"container": mainWindow_ScrollView_2, "objectName": "addMoreSocialLinksButton", "type": "StatusIconTextButton", "visible": True}
twitter_popup_StaticSocialLinkInput = {"container": statusDesktop_mainWindow_overlay, "objectName": "__twitter-socialLinkInput", "type": "StaticSocialLinkInput", "visible": True}
twitter_popup_TextEdit = {"container": twitter_popup_StaticSocialLinkInput, "type": "TextEdit", "unnamed": 1, "visible": True}
personalSite_popup_StaticSocialLinkInput = {"container": statusDesktop_mainWindow_overlay, "objectName": "__personal_site-socialLinkInput", "type": "StaticSocialLinkInput", "visible": True}
personalSite_popup_TextEdit = {"container": personalSite_popup_StaticSocialLinkInput, "type": "TextEdit", "unnamed": 1, "visible": True}
customLink_popup_StatusInput = {"container": statusDesktop_mainWindow_overlay, "objectName": "hyperlinkInput", "type": "StatusInput", "visible": True}
customLink_popup_TextEdit = {"container": customLink_popup_StatusInput, "type": "TextEdit", "unnamed": 1, "visible": True}
customUrl_popup_StatusInput = {"container": statusDesktop_mainWindow_overlay, "objectName": "urlInput", "type": "StatusInput", "visible": True}
customUrl_popup_TextEdit = {"container": customUrl_popup_StatusInput, "type": "TextEdit", "unnamed": 1, "visible": True}
change_password_button = {"container": statusDesktop_mainWindow, "type": "StatusButton", "objectName": "profileSettingsChangePasswordButton", "visible": True}

# Wallet Settings:
settings_Wallet_MainView_GeneratedAccounts = {"container": statusDesktop_mainWindow, "objectName":'generatedAccounts', "type": 'ListView'}
settings_Wallet_AccountView_DeleteAccount = {"container": statusDesktop_mainWindow, "type": "StatusButton", "objectName": "deleteAccountButton"}
settings_Wallet_AccountView_DeleteAccount_Confirm = {"container": statusDesktop_mainWindow, "type": "StatusButton", "objectName": "confirmDeleteAccountButton"}
mainWindow_ScrollView_2 = {"container": statusDesktop_mainWindow, "occurrence": 2, "type": "StatusScrollView", "unnamed": 1, "visible": True}
settings_Wallet_MainView_Networks = {"container": statusDesktop_mainWindow, "objectName": "networksItem", "type": "StatusListItem"}
settings_Wallet_NetworksView_TestNet_Toggle = {"container": statusDesktop_mainWindow, "objectName": "testnetModeSwitch", "type": "StatusSwitch"}
settings_Wallet_AccountView_EditAccountButton = {"container": statusDesktop_mainWindow, "type": "StatusFlatRoundButton", "objectName": "walletAccountViewEditAccountButton"}
settings_Wallet_AccountView_EditAccountNameInput = {"container": statusDesktop_mainWindow_overlay, "type": "TextEdit", "objectName": "renameAccountNameInput", "visible": True}
settings_Wallet_AccountView_EditAccountSaveButton = {"container": statusDesktop_mainWindow_overlay, "type": "StatusButton", "objectName": "renameAccountModalSaveBtn"}
settings_Wallet_AccountView_EditAccountColorRepeater = {"container": statusDesktop_mainWindow, "type": "Repeater", "objectName": "statusColorRepeater", "visible": True}
settings_Wallet_AccountView_AccountName = {"container": statusDesktop_mainWindow, "type": "StatusBaseText", "objectName": "walletAccountViewAccountName"}
settings_Wallet_AccountView_IconSettings = {"container": statusDesktop_mainWindow, "type": "StatusSmartIdenticon", "objectName": "walletAccountViewAccountImage" , "visible": True}
settings_Wallet_MainView_BackupSeedPhrase = {"container": mainWindow_ScrollView, "objectName": SettingsSubsection.BACKUP_SEED.value, "type": "StatusNavigationListItem", "visible": True}

generatedAccounts_ListView = {"container": statusDesktop_mainWindow, "objectName": "generatedAccounts", "type": "ListView"}

# Messaging Settings:
settingsContentBase_ScrollView = {"container": statusDesktop_mainWindow, "objectName": "settingsContentBaseScrollView", "type": "StatusScrollView", "visible": True}
displayMessageLinkPreviewItem = {"container": statusDesktop_mainWindow, "objectName": "displayMessageLinkPreviewsItem", "type": "StatusListItem"}
imageUnfurlingItem = {"container": statusDesktop_mainWindow, "objectName": "imageUnfurlingItem", "type": "StatusListItem"}
tenorGifsPreviewSwitchItem = {"container": statusDesktop_mainWindow, "objectName": "MessagingView_sitesListView_StatusListItem_tenor_gifs_subdomain", "type": "StatusListItem"}

# Communities Settings:
settings_Communities_MainView_LeaveCommunityButtons = {"container": statusDesktop_mainWindow, "objectName":"CommunitiesListPanel_leaveCommunityPopupButton", "type": "StatusBaseButton", "visible": True}
settings_Communities_MainView_LeavePopup_LeaveCommunityButton = {"container": statusDesktop_mainWindow, "objectName":"CommunitiesListPanel_leaveCommunityButtonInPopup", "type": "StatusBaseButton", "visible": True}

# Advanced Settings:
walletSettingsLineButton = {"container": statusDesktop_mainWindow, "objectName": "WalletSettingsLineButton", "type": "StatusSettingsLineButton", "visible": True}
i_understand_StatusBaseText = {"container": statusDesktop_mainWindow_overlay, "text": "I understand", "type": "StatusBaseText", "unnamed": 1, "visible": True}

# Extra Settings:
signOutConfirmation_StatusButton = {"container": statusDesktop_mainWindow_overlay, "objectName": "signOutConfirmation", "type": "StatusButton", "visible": True}

# Language Settings:
settings_LanguageView = {"container": statusDesktop_mainWindow, "objectName": "languageView", "type": "LanguageView"}
languageView_language_StatusListPicker = {"container": statusDesktop_mainWindow, "objectName": "languagePicker", "type": "StatusListPicker"}
languageView_language_StatusPickerButton = {"container": languageView_language_StatusListPicker,  "type": "StatusPickerButton", "unnamed": 1}
languageView_language_ListView = {"container": languageView_language_StatusListPicker,  "type": "ListView", "unnamed": 1}
languageView_language_StatusInput = {"container": languageView_language_ListView,  "type": "StatusInput", "unnamed": 1}

# Backup seed phrase:
backup_seed_phrase_popup_Acknowledgements_havePen_checkbox = {"container": statusDesktop_mainWindow_overlay, "objectName": "Acknowledgements_havePen", "type": "StatusCheckBox", "checkable": True, "visible": True}
backup_seed_phrase_popup_Acknowledgements_writeDown_checkbox = {"container": statusDesktop_mainWindow_overlay, "objectName": "Acknowledgements_writeDown", "type": "StatusCheckBox", "checkable": True, "visible": True}
backup_seed_phrase_popup_Acknowledgements_storeIt_checkbox = {"container": statusDesktop_mainWindow_overlay, "objectName": "Acknowledgements_storeIt", "type": "StatusCheckBox", "checkable": True, "visible": True}
backup_seed_phrase_popup_nextButton = {"container": statusDesktop_mainWindow_overlay, "objectName": "BackupSeedModal_nextButton", "type": "StatusButton", "visible": True, "enabled": True}
backup_seed_phrase_popup_ConfirmSeedPhrasePanel_RevealSeedPhraseButton = {"container": statusDesktop_mainWindow_overlay, "objectName": "ConfirmSeedPhrasePanel_RevealSeedPhraseButton", "type": "StatusButton", "visible": True}
backup_seed_phrase_popup_ConfirmSeedPhrasePanel_StatusSeedPhraseInput_placeholder = {"container": statusDesktop_mainWindow_overlay, "objectName": "ConfirmSeedPhrasePanel_StatusSeedPhraseInput_%WORD_NO%", "type": "StatusSeedPhraseInput", "visible": True}
backup_seed_phrase_popup_BackupSeedStepBase_confirmFirstWord = {"container": statusDesktop_mainWindow_overlay, "objectName": "BackupSeedModal_BackupSeedStepBase_confirmFirstWord", "type": "BackupSeedStepBase", "visible": True}
backup_seed_phrase_popup_BackupSeedStepBase_confirmFirstWord_inputText = {"container": backup_seed_phrase_popup_BackupSeedStepBase_confirmFirstWord, "objectName": "BackupSeedStepBase_inputText", "type": "TextEdit", "visible": True}
backup_seed_phrase_popup_BackupSeedStepBase_confirmSecondWord = {"container": statusDesktop_mainWindow_overlay, "objectName": "BackupSeedModal_BackupSeedStepBase_confirmSecondWord", "type": "BackupSeedStepBase", "visible": True}
backup_seed_phrase_popup_BackupSeedStepBase_confirmSecondWord_inputText = {"container": backup_seed_phrase_popup_BackupSeedStepBase_confirmSecondWord, "objectName": "BackupSeedStepBase_inputText", "type": "TextEdit", "visible": True}
backup_seed_phrase_popup_ConfirmStoringSeedPhrasePanel_storeCheck = {"container": statusDesktop_mainWindow_overlay, "objectName": "ConfirmStoringSeedPhrasePanel_storeCheck", "type": "StatusCheckBox", "checkable": True, "visible": True}
backup_seed_phrase_popup_BackupSeedModal_completeAndDeleteSeedPhraseButton = {"container": statusDesktop_mainWindow_overlay, "objectName": "BackupSeedModal_completeAndDeleteSeedPhraseButton", "type": "StatusButton", "visible": True}

# User Status Profile Menu
userContextmenu_AlwaysActiveButton= {"container": statusDesktop_mainWindow_overlay, "objectName": "userStatusMenuAlwaysOnlineAction", "type": "StatusMenuItemDelegate", "visible": True}
userContextmenu_InActiveButton= {"container": statusDesktop_mainWindow_overlay, "objectName": "userStatusMenuInactiveAction", "type": "StatusMenuItemDelegate", "visible": True}
userContextmenu_AutomaticButton= {"container": statusDesktop_mainWindow_overlay, "objectName": "userStatusMenuAutomaticAction", "type": "StatusMenuItemDelegate", "visible": True}

# Change Password Menu 
change_password_menu_current_password = {"container": statusDesktop_mainWindow_overlay, "objectName": "passwordViewCurrentPassword", "type": "StatusPasswordInput", "visible": True}
change_password_menu_new_password = {"container": statusDesktop_mainWindow_overlay, "objectName": "passwordViewNewPassword", "type": "StatusPasswordInput", "visible": True}
change_password_menu_new_password_confirm = {"container": statusDesktop_mainWindow_overlay, "objectName": "passwordViewNewPasswordConfirm", "type": "StatusPasswordInput", "visible": True}
change_password_menu_submit_button = {"container": statusDesktop_mainWindow_overlay, "objectName": "changePasswordModalSubmitButton", "type": "StatusButton", "visible": True}
change_password_success_menu_sign_out_quit_button = {"container": statusDesktop_mainWindow_overlay, "objectName": "changePasswordSuccessModalSignOutAndQuitButton", "type": "StatusButton", "visible": True}

