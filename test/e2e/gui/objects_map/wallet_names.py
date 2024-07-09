from objectmaphelper import *
from gui.objects_map.names import statusDesktop_mainWindow, mainWindow_RighPanel, statusDesktop_mainWindow_overlay

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
mainWindow_SavedAddressesView = {"container": statusDesktop_mainWindow, "type": "SavedAddressesView", "unnamed": 1, "visible": True}
mainWindow_SavedAddressesView_2 = {"container": mainWindow_WalletLayout, "type": "SavedAddressesView", "unnamed": 1, "visible": True}
mainWallet_Saved_Addresses_Add_Buttton = {"container": mainWindow_SavedAddressesView, "objectName": "walletHeaderButton", "type": "StatusButton"}
mainWallet_Saved_Addresses_List = {"container": mainWindow_SavedAddressesView, "objectName": "SavedAddressesView_savedAddresses", "type": "StatusListView"}
savedAddressView_Delegate = {"container": mainWallet_Saved_Addresses_List, "objectName": RegularExpression("savedAddressView_Delegate*"), "type": "SavedAddressesDelegate", "visible": True}
send_StatusRoundButton = {"container": "", "type": "StatusRoundButton", "unnamed": 1, "visible": True}
savedAddressView_Delegate_menuButton = {"container": mainWindow_SavedAddressesView, "objectName": RegularExpression("savedAddressView_Delegate_menuButton*"), "type": "StatusRoundButton", "visible": True}
savedAddressesArea_SavedAddresses = {"container": mainWindow_SavedAddressesView, "objectName": "savedAddressesArea", "type": "SavedAddresses", "visible": True}
savedAddresses_area = {"container": mainWindow_SavedAddressesView_2, "objectName": "savedAddressesArea", "type": "SavedAddresses", "visible": True}

# Wallet Account View
mainWindow_RightTabView = {"container": statusDesktop_mainWindow, "type": "RightTabView", "unnamed": 1, "visible": True}
mainWallet_Account_Name = {"container": mainWindow_RightTabView, "objectName": "walletHeaderTitle", "type": "StatusBaseText", "visible": True}
mainWindow_Send_Button = {"container": statusDesktop_mainWindow, "objectName": "walletFooterSendButton", "type": "StatusFlatButton", "visible": True}
mainWindow_RightTabView = {"container": statusDesktop_mainWindow, "type": "RightTabView", "unnamed": 1, "visible": True}
filterButton_StatusFlatButton = {"checkable": True, "container": mainWindow_RightTabView, "objectName": "filterButton", "type": "StatusFlatButton", "visible": True}
cmbTokenOrder_SortOrderComboBox = {"container": mainWindow_RightTabView, "objectName": "cmbTokenOrder", "type": "SortOrderComboBox", "visible": True}
collectibles_cmbTokenOrder_SortOrderComboBox = {"container": mainWindow_RightTabView, "id": "cmbTokenOrder", "type": "SortOrderComboBox", "unnamed": 1, "visible": True}
rightSideWalletTabBar_StatusTabBar = {"container": mainWindow_RightTabView, "objectName": "rightSideWalletTabBar", "type": "StatusTabBar", "visible": True}
rightSideWalletTabBar_Assets_StatusTabButton = {"checkable": True, "container": rightSideWalletTabBar_StatusTabBar, "objectName": "assetsTabButton", "text": "Assets", "type": "StatusTabButton", "visible": True}
rightSideWalletTabBar_Collectibles_StatusTabButton = {"checkable": True, "container": rightSideWalletTabBar_StatusTabBar, "objectName": "collectiblesTabButton", "text": "Collectibles", "type": "StatusTabButton", "visible": True}
rightSideWalletTabBar_Activity_StatusTabButton = {"checkable": True, "container": rightSideWalletTabBar_StatusTabBar, "objectName": "activityTabButton", "text": "Activity", "type": "StatusTabButton", "visible": True}
o_AssetsView = {"container": mainWindow_RightTabView, "type": "AssetsView", "unnamed": 1, "visible": True}
itemDelegate = {"checkable": False, "container": statusDesktop_mainWindow_overlay, "id": "menuDelegate", "type": "ItemDelegate", "unnamed": 1, "visible": True}
assetView_TokenListItem_TokenDelegate = {"container": mainWindow_RightTabView, "objectName": RegularExpression("AssetView_TokenListItem_*"), "type": "TokenDelegate", "visible": True}
arrow_icon_StatusIcon = {"container": statusDesktop_mainWindow_overlay, "objectName": "arrow-up-icon", "type": "StatusIcon", "visible": True}
collectible_item = {"container": mainWindow_RightTabView, "type": "CollectibleView", "unnamed": 1, "visible": True}
mainWindow_settingsContentBaseScrollView_StatusScrollView_general = {"container":  statusDesktop_mainWindow, "objectName": "settingsContentBaseScrollView", "type": "StatusScrollView", "visible": True}
settingsContentBaseScrollView_manageTokensDelegate_ManageTokensDelegate = {"container": mainWindow_settingsContentBaseScrollView_StatusScrollView_general, "objectName": RegularExpression("manageTokensDelegate-*"), "type": "ManageTokensDelegate", "visible": True}
settingsContentBaseScrollView_manageTokensView_ManageTokensView = {"container": mainWindow_settingsContentBaseScrollView_StatusScrollView_general, "id": "manageTokensView", "type": "ManageTokensView", "unnamed": 1, "visible": True}

mainWindow_Save_and_apply_StatusButton = {"checkable": False, "container": statusDesktop_mainWindow, "objectName": "settingsDirtyToastMessageSaveButton", "text": "Save and apply", "type": "StatusButton", "visible": True}
mainWindow_Save_StatusFlatButton = {"checkable": False, "container": statusDesktop_mainWindow, "id": "saveForLaterButton", "text": "Save", "type": "StatusFlatButton", "unnamed": 1, "visible": True}
