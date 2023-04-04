from scripts.global_names import *

# Main:
navBarListView_Wallet_navbar_StatusNavBarTabButton = {"checkable": True, "container": mainWindow_navBarListView_ListView, "objectName": "Wallet-navbar", "type": "StatusNavBarTabButton", "visible": True}
wallet_navbar_wallet_icon_StatusIcon = {"container": navBarListView_Wallet_navbar_StatusNavBarTabButton, "objectName": "wallet-icon", "type": "StatusIcon", "visible": True}
mainWallet_Account_Name = {"container": statusDesktop_mainWindow, "objectName": "accountName", "type": "StatusBaseText", "visible": True}
mainWallet_Address_Panel = {"container": statusDesktop_mainWindow, "objectName": "addressPanel", "type": "StatusAddressPanel", "visible": True}
mainWallet_Add_Account_Button = {"container": statusDesktop_mainWindow, "objectName": "addAccountButton", "type": "StatusRoundButton", "visible": True}
signPhrase_Ok_Button = {"container": statusDesktop_mainWindow, "type": "StatusFlatButton", "objectName": "signPhraseModalOkButton", "visible": True}
mainWallet_Saved_Addresses_Button = {"container": statusDesktop_mainWindow, "objectName": "savedAddressesBtn", "type": "StatusButton"}
mainWallet_Network_Selector_Button = {"container": statusDesktop_mainWindow, "objectName": "networkSelectorButton", "type": "StatusListItem"}
mainWallet_Right_Side_Tab_Bar = {"container": statusDesktop_mainWindow, "objectName": "rightSideWalletTabBar", "type": "StatusTabBar"}
mainWallet_Ephemeral_Notification_List = {"container": statusDesktop_mainWindow, "objectName": "ephemeralNotificationList", "type": "StatusListView"}

accounts_StatusListView = {"container": statusDesktop_mainWindow, "objectName": "walletAccountsListView", "type": "StatusListView", "visible": True}
firstWalletAccount_Item = {"container": accounts_StatusListView, "index": 0, "objectName": "walletAccountItem", "type": "StatusListItem", "visible": True}


# Assets view:
mainWallet_Assets_View_List = {"container": statusDesktop_mainWindow, "objectName": "assetViewStatusListView", "type": "StatusListView"}

# Network selector popup
mainWallet_Network_Popup_Chain_Repeater_1 = {"container": statusDesktop_mainWindow, "objectName": "networkSelectPopupChainRepeaterLayer1", "type": "Repeater"}

# Send popup:
mainWallet_totalCurrencyBalance = {"container": statusDesktop_mainWindow, "objectName": "walletLeftListAmountValue", "type": "StyledTextEdit"}
mainWallet_Footer_Send_Button = {"container": statusDesktop_mainWindow, "objectName": "walletFooterSendButton", "type": "StatusFlatButton"}
mainWallet_Send_Popup_Main = {"container": statusDesktop_mainWindow, "objectName": "sendModalScroll", "type": "StatusScrollView"}
mainWallet_Send_Popup_Amount_Input = {"container": statusDesktop_mainWindow, "objectName": "amountInput", "type": "TextEdit"}
mainWallet_Send_Popup_My_Accounts_Tab = {"container": statusDesktop_mainWindow, "objectName": "myAccountsTab", "type": "StatusTabButton"}
mainWallet_Send_Popup_My_Accounts_List = {"container": statusDesktop_mainWindow, "objectName": "myAccountsList", "type": "StatusListView"}
mainWallet_Send_Popup_Header_Accounts = {"container": statusDesktop_mainWindow, "objectName": "accountsListFloatingHeader", "type": "Repeater"}
mainWallet_Send_Popup_Networks_List = {"container": statusDesktop_mainWindow, "objectName": "networksList", "type": "Repeater"}
mainWallet_Send_Popup_Send_Button = {"container": statusDesktop_mainWindow, "objectName": "sendModalFooterSendButton", "type": "StatusFlatButton"}
mainWallet_Send_Popup_Asset_Selector = {"container": statusDesktop_mainWindow, "objectName": "assetSelectorButton", "type": "StatusComboBox"}
mainWallet_Send_Popup_Asset_List = {"container": statusDesktop_mainWindow, "objectName": "assetSelectorList", "type": "StatusListView"}
mainWallet_Send_Popup_GasPrice_Input = {"container": statusDesktop_mainWindow, "objectName": "gasPriceSelectorInput", "type": "StyledTextField"}

# Add account popup:

# saved address view
mainWallet_Saved_Addreses_Add_Buttton = {"container": statusDesktop_mainWindow, "objectName": "addNewAddressBtn", "type": "StatusButton"}
mainWallet_Saved_Addreses_List = {"container": statusDesktop_mainWindow, "objectName": "SavedAddressesView_savedAddresses", "type": "StatusListView"}
mainWallet_Saved_Addreses_More_Edit = {"container": statusDesktop_mainWindow, "objectName": "editroot", "type": "StatusMenuItem"}
mainWallet_Saved_Addreses_More_Delete = {"container": statusDesktop_mainWindow, "objectName": "deleteSavedAddress", "type": "StatusMenuItem"}
mainWallet_Saved_Addreses_More_Confirm_Delete = {"container": statusDesktop_mainWindow, "objectName": "confirmDeleteSavedAddress", "type": "StatusButton"}

# saved address add popup
mainWallet_Saved_Addreses_Popup_Name_Input = {"container": statusDesktop_mainWindow, "objectName": "savedAddressNameInput", "type": "TextEdit"}
mainWallet_Saved_Addreses_Popup_Address_Input = {"container": statusDesktop_mainWindow, "objectName": "savedAddressAddressInput", "type": "StatusInput"}
mainWallet_Saved_Addreses_Popup_Address_Input_Edit = {"container": statusDesktop_mainWindow, "objectName": "savedAddressAddressInputEdit", "type": "TextEdit"}
mainWallet_Saved_Addreses_Popup_Address_Add_Button = {"container": statusDesktop_mainWindow, "objectName": "addSavedAddress", "type": "StatusButton"}

# Collectibles view
mainWallet_Collections_Repeater = {"container": statusDesktop_mainWindow, "objectName": "collectionsRepeater", "type": "Repeater"}
mainWallet_Collectibles_Repeater = {"container": statusDesktop_mainWindow, "objectName": "collectiblesRepeater", "type": "Repeater"}

# Shared Popup
sharedPopup_Popup_Content = {"container": statusDesktop_mainWindow, "objectName": "KeycardSharedPopupContent", "type": "Item"}
sharedPopup_Password_Input = {"container": sharedPopup_Popup_Content, "objectName": "keycardPasswordInput", "type": "TextField"}
sharedPopup_Primary_Button = {"container": statusDesktop_mainWindow, "objectName": "PrimaryButton", "type": "StatusButton"}

# Transactions view
mainWallet_Transactions_List = {"container": statusDesktop_mainWindow, "objectName": "walletAccountTransactionList", "type": "StatusListView"}
mainWallet_Transactions_Detail_View_Header = {"container": statusDesktop_mainWindow, "objectName": "transactionDetailHeader", "type": "TransactionDelegate"}
