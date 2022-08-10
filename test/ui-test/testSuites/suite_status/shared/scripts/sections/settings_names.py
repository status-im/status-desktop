
from sections.global_names import *

# Main:
navBarListView_Settings_navbar_StatusNavBarTabButton = {"checkable": True, "container": mainWindow_navBarListView_ListView, "objectName": "Settings-navbar", "type": "StatusNavBarTabButton", "visible": True}
settings_navbar_settings_icon_StatusIcon = {"container": navBarListView_Settings_navbar_StatusNavBarTabButton, "objectName": "settings-icon", "type": "StatusIcon", "visible": True}
advanced_StatusBaseText = {"container": statusDesktop_mainWindow, "text": "Advanced", "type": "StatusBaseText", "unnamed": 1, "visible": True}
mainWindow_ScrollView = {"container": statusDesktop_mainWindow, "type": "StatusScrollView", "unnamed": 1, "visible": True}
wallet_AppMenu_StatusNavigationListItem = {"container": mainWindow_ScrollView, "objectName": "Wallet-AppMenu", "type": "StatusNavigationListItem", "visible": True}

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

generatedAccounts_ListView = {"container": statusDesktop_mainWindow, "objectName": "generatedAccounts", "type": "ListView"}

# Advanced Settings:
walletSettingsLineButton = {"container": statusDesktop_mainWindow, "objectName": "WalletSettingsLineButton", "type": "StatusSettingsLineButton", "visible": True}
i_understand_StatusBaseText = {"container": statusDesktop_mainWindow_overlay, "text": "I understand", "type": "StatusBaseText", "unnamed": 1, "visible": True}

# Extra Settings:
sign_out_Quit_ExtraMenu_StatusNavigationListItem = {"container": mainWindow_ScrollView, "objectName": "Sign out & Quit-ExtraMenu", "type": "StatusNavigationListItem", "visible": True}
signOutConfirmation_StatusButton = {"container": statusDesktop_mainWindow_overlay, "objectName": "signOutConfirmation", "type": "StatusButton", "visible": True}