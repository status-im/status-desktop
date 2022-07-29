
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
twelve_seed_phrase_address = {"container": mainWindow_ScrollView_2, "text": "0x8285cb9bf17b23d64a489a8dad29163dd227d0fd", "type": "StatusBaseText", "unnamed": 1, "visible": True}
eighteen_seed_phrase_address = {"container": mainWindow_ScrollView_2, "text": "0xba1d0d6ef35df8751df5faf55ebd885ad0e877b0", "type": "StatusBaseText", "unnamed": 1, "visible": True}
twenty_four_seed_phrase_address = {"container": mainWindow_ScrollView_2, "text": "0x28cf6770664821a51984daf5b9fb1b52e6538e4b", "type": "StatusBaseText", "unnamed": 1, "visible": True}
settings_Wallet_MainView_Networks = {"container": statusDesktop_mainWindow, "objectName": "networksItem", "type": "StatusListItem"}
settings_Wallet_NetworksView_TestNet_Toggle = {"container": statusDesktop_mainWindow, "objectName": "testnetModeSwitch", "type": "StatusSwitch"}

# Advanced Settings:
walletSettingsLineButton = {"container": statusDesktop_mainWindow, "objectName": "WalletSettingsLineButton", "type": "StatusSettingsLineButton", "visible": True}
i_understand_StatusBaseText = {"container": statusDesktop_mainWindow_overlay, "text": "I understand", "type": "StatusBaseText", "unnamed": 1, "visible": True}
