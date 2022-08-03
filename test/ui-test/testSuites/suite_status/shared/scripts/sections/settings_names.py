
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

generatedAccounts_ListView = {"container": statusDesktop_mainWindow, "objectName": "generatedAccounts", "type": "ListView"}
generatedAccounts_walletSettingsAccountDelegate_WalletAccountDelegate = {"container": generatedAccounts_ListView, "index": 0, "objectName": "walletSettingsAccountDelegate", "type": "WalletAccountDelegate"}
walletSettingsAccountDelegate_WalletAddress_Text = {"container": generatedAccounts_walletSettingsAccountDelegate_WalletAccountDelegate, "objectName": "statusListItemSubTitle", "type": "StatusBaseText"}

# Advanced Settings:
walletSettingsLineButton = {"container": statusDesktop_mainWindow, "objectName": "WalletSettingsLineButton", "type": "StatusSettingsLineButton", "visible": True}
i_understand_StatusBaseText = {"container": statusDesktop_mainWindow_overlay, "text": "I understand", "type": "StatusBaseText", "unnamed": 1, "visible": True}
