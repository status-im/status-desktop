from objectmaphelper import *
from . main_names import *

mainWindow_WalletLayout = {"container": statusDesktop_mainWindow, "type": "WalletLayout", "unnamed": 1, "visible": True}

# Left Wallet Panel
mainWallet_LeftTab = {"container": statusDesktop_mainWindow, "objectName": "walletLeftTab", "type": "LeftTabView", "visible": True}
mainWallet_Saved_Addresses_Button = {"container": mainWindow_RighPanel, "objectName": "savedAddressesBtn", "type": "StatusFlatButton"}
walletAccounts_StatusListView = {"container": statusDesktop_mainWindow, "objectName": "walletAccountsListView", "type": "StatusListView", "visible": True}
mainWallet_All_Accounts_Button = {"container": walletAccounts_StatusListView, "objectName": "allAccountsBtn", "type": "Button", "visible": True}
mainWallet_Add_Account_Button = {"container": statusDesktop_mainWindow, "objectName": "addAccountButton", "type": "StatusRoundButton", "visible": True}
walletAccount_StatusListItem = {"container": walletAccounts_StatusListView, "objectName": RegularExpression("walletAccount*"), "type": "StatusListItem", "visible": True}
mainWallet_All_Accounts_Balance = {"container": mainWallet_All_Accounts_Button, "objectName": "walletLeftListAmountValue", "type": "StatusTextWithLoadingState", "visible": True}

# Saved Address View
mainWindow_SavedAddressesView = {"container": mainWindow_WalletLayout, "type": "SavedAddressesView", "unnamed": 1, "visible": True}
mainWallet_Saved_Addreses_Add_Buttton = {"container": mainWindow_SavedAddressesView, "objectName": "walletHeaderButton", "type": "StatusButton"}
mainWallet_Saved_Addreses_List = {"container": mainWindow_SavedAddressesView, "objectName": "SavedAddressesView_savedAddresses", "type": "StatusListView"}
savedAddressView_Delegate = {"container": mainWallet_Saved_Addreses_List, "objectName": RegularExpression("savedAddressView_Delegate*"), "type": "SavedAddressesDelegate", "visible": True}
send_StatusRoundButton = {"container": "", "type": "StatusRoundButton", "unnamed": 1, "visible": True}
savedAddressView_Delegate_menuButton = {"container": mainWindow_SavedAddressesView, "objectName": RegularExpression("savedAddressView_Delegate_menuButton*"), "type": "StatusRoundButton", "visible": True}

# Wallet Account View
mainWindow_StatusSectionLayout_ContentItem = {"container": statusDesktop_mainWindow, "objectName": "StatusSectionLayout", "type": "ContentItem", "visible": True}
mainWallet_Account_Name = {"container": mainWindow_StatusSectionLayout_ContentItem, "objectName": "accountName", "type": "StatusBaseText", "visible": True}
mainWindow_Send_Button = {"container": mainWindow_StatusWindow, "type": "DisabledTooltipButton", "icon": "send", "visible": True}
