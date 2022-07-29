
from sections.global_names import *

# Main:
navBarListView_Wallet_navbar_StatusNavBarTabButton = {"checkable": True, "container": mainWindow_navBarListView_ListView, "objectName": "Wallet-navbar", "type": "StatusNavBarTabButton", "visible": True}
wallet_navbar_wallet_icon_StatusIcon = {"container": navBarListView_Wallet_navbar_StatusNavBarTabButton, "objectName": "wallet-icon", "type": "StatusIcon", "visible": True}
mainWallet_Account_Name = {"container": statusDesktop_mainWindow, "objectName": "accountName", "type": "StatusBaseText", "visible": True}
mainWallet_Add_Account = {"container": statusDesktop_mainWindow, "text": "Add account", "type": "StatusBaseText", "unnamed": 1, "visible": True}
signPhrase_Ok_Button = {"container": statusDesktop_mainWindow, "type": "StatusFlatButton", "objectName": "signPhraseModalOkButton", "visible": True}

# Send popup:
mainWallet_Footer_Send_Button = {"container": statusDesktop_mainWindow, "objectName": "walletFooterSendButton", "type": "StatusFlatButton"}
mainWallet_Send_Popup_Main = {"container": statusDesktop_mainWindow, "objectName": "sendModalScroll", "type": "StatusScrollView"}
mainWallet_Send_Popup_Amount_Input = {"container": statusDesktop_mainWindow, "objectName": "amountInput", "type": "TextEdit"}
mainWallet_Send_Popup_My_Accounts_Tab = {"container": statusDesktop_mainWindow, "objectName": "myAccountsTab", "type": "StatusTabButton"}
mainWallet_Send_Popup_My_Accounts_List = {"container": statusDesktop_mainWindow, "objectName": "myAccountsList", "type": "StatusListView"}
mainWallet_Send_Popup_Header_Accounts = {"container": statusDesktop_mainWindow, "objectName": "accountsListFloatingHeader", "type": "Repeater"}
mainWallet_Send_Popup_Networks_List = {"container": statusDesktop_mainWindow, "objectName": "networksList", "type": "Repeater"}
mainWallet_Send_Popup_Send_Button = {"container": statusDesktop_mainWindow, "objectName": "sendModalFooterSendButton", "type": "StatusFlatButton"}
mainWallet_Send_Popup_Password_Input = {"container": statusDesktop_mainWindow, "objectName": "transactionSignerPasswordInput", "type": "StyledTextField"}

# Add account popup:
mainWallet_Add_Account_Popup_Main = {"container": statusDesktop_mainWindow, "objectName": "AddAccountModalContent", "type": "StatusScrollView", "visible": True}
mainWallet_Add_Account_Popup_Password = {"container": mainWallet_Add_Account_Popup_Main, "text": "Enter your password...", "type": "PlaceholderText", "unnamed": 1, "visible": True}
mainWallet_Add_Account_Popup_Advanced = {"container": mainWallet_Add_Account_Popup_Main, "text": "Advanced", "type": "StatusBaseText", "unnamed": 1, "visible": True}
mainWallet_Add_Account_Popup_Type_Selector = {"container": mainWallet_Add_Account_Popup_Main, "text": "Default", "type": "StatusBaseText", "unnamed": 1, "visible": True}
mainWallet_Add_Account_Popup_Type_Watch_Only = {"container": statusDesktop_mainWindow, "text": "Add a watch-only address", "type": "StatusBaseText", "unnamed": 1, "visible": True}
mainWallet_Add_Account_Popup_Type_Private_Key = {"container": statusDesktop_mainWindow, "text": "Generate from Private key", "type": "StatusBaseText", "unnamed": 1, "visible": True}
mainWallet_Add_Account_Popup_Type_Seed_Phrase = {"container": statusDesktop_mainWindow, "text": "Import new Seed Phrase", "type": "StatusBaseText", "unnamed": 1, "visible": True}
mainWallet_Add_Account_Popup_Account_Name = {"container": mainWallet_Add_Account_Popup_Main, "text": "Enter an account name...", "type": "StatusBaseText", "unnamed": 1, "visible": True}
mainWallet_Add_Account_Popup_Watch_Only_Address = {"container": mainWallet_Add_Account_Popup_Main, "text": "Enter address...", "type": "StatusBaseText", "unnamed": 1, "visible": True}
mainWallet_Add_Account_Popup_Private_Key = {"container": mainWallet_Add_Account_Popup_Main, "text": "Paste the contents of your private key", "type": "StatusBaseText", "unnamed": 1, "visible": True}
mainWindow_Add_Account_Popup_Seed_Phrase_0 = {"container": mainWallet_Add_Account_Popup_Main, "type": "StatusBaseText", "objectName": "seedPhraseInputPlaceholder0", "visible": True}
mainWindow_Add_Account_Popup_Seed_Phrase_1 = {"container": mainWallet_Add_Account_Popup_Main, "type": "StatusBaseText", "objectName": "seedPhraseInputPlaceholder1", "visible": True}
mainWindow_Add_Account_Popup_Seed_Phrase_2 = {"container": mainWallet_Add_Account_Popup_Main, "type": "StatusBaseText", "objectName": "seedPhraseInputPlaceholder2", "visible": True}
mainWindow_Add_Account_Popup_Seed_Phrase_3 = {"container": mainWallet_Add_Account_Popup_Main, "type": "StatusBaseText", "objectName": "seedPhraseInputPlaceholder3", "visible": True}
mainWindow_Add_Account_Popup_Seed_Phrase_4 = {"container": mainWallet_Add_Account_Popup_Main, "type": "StatusBaseText", "objectName": "seedPhraseInputPlaceholder4", "visible": True}
mainWindow_Add_Account_Popup_Seed_Phrase_5 = {"container": mainWallet_Add_Account_Popup_Main, "type": "StatusBaseText", "objectName": "seedPhraseInputPlaceholder5", "visible": True}
mainWindow_Add_Account_Popup_Seed_Phrase_6 = {"container": mainWallet_Add_Account_Popup_Main, "type": "StatusBaseText", "objectName": "seedPhraseInputPlaceholder6", "visible": True}
mainWindow_Add_Account_Popup_Seed_Phrase_7 = {"container": mainWallet_Add_Account_Popup_Main, "type": "StatusBaseText", "objectName": "seedPhraseInputPlaceholder7", "visible": True}
mainWindow_Add_Account_Popup_Seed_Phrase_8 = {"container": mainWallet_Add_Account_Popup_Main, "type": "StatusBaseText", "objectName": "seedPhraseInputPlaceholder8", "visible": True}
mainWindow_Add_Account_Popup_Seed_Phrase_9 = {"container": mainWallet_Add_Account_Popup_Main, "type": "StatusBaseText", "objectName": "seedPhraseInputPlaceholder9", "visible": True}
mainWindow_Add_Account_Popup_Seed_Phrase_10 = {"container": mainWallet_Add_Account_Popup_Main, "type": "StatusBaseText", "objectName": "seedPhraseInputPlaceholder10", "visible": True}
mainWindow_Add_Account_Popup_Seed_Phrase_11 = {"container": mainWallet_Add_Account_Popup_Main, "type": "StatusBaseText", "objectName": "seedPhraseInputPlaceholder11", "visible": True}

mainWallet_Add_Account_Popup_Footer = {"container": statusDesktop_mainWindow, "type": "StatusModalFooter", "unnamed": 1, "visible": True}
mainWallet_Add_Account_Popup_Footer_Add_Account = {"container": mainWallet_Add_Account_Popup_Footer, "text": "Add account", "type": "StatusBaseText", "unnamed": 1, "visible": True}
