# encoding: UTF-8

from objectmaphelper import *

statusDesktop_mainWindow = {"name": "mainWindow", "type": "StatusWindow", "visible": True}

loginView_passwordInput = {"container": statusDesktop_mainWindow, "echoMode": 2, "id": "inputValue", "passwordCharacter": "•", "type": "StyledTextField", "unnamed": 1, "visible": True}
loginView_changeAccountBtn = {"container": statusDesktop_mainWindow, "id": "changeAccountBtn", "type": "Rectangle", "unnamed": 1, "visible": True}
loginView_submitBtn = {"container": statusDesktop_mainWindow, "type": "StatusRoundButton", "visible": True}
loginView_main = {"container": statusDesktop_mainWindow, "type": "LoginView", "visible": True}
loginView_errMsgLabel = {"container": statusDesktop_mainWindow, "id": "errMsg", "type": "StyledText", "visible": True}

mainWindow_I_am_new_to_Status_StatusBaseText = {"container": statusDesktop_mainWindow, "text": "I am new to Status", "type": "StatusBaseText", "unnamed": 1, "visible": True}
mainWindow_Generate_new_keys_StatusBaseText = {"container": statusDesktop_mainWindow, "text": "Generate new keys", "type": "StatusBaseText", "unnamed": 1, "visible": True}

mainWindow_edit_TextEdit = {"container": statusDesktop_mainWindow, "id": "edit", "type": "TextEdit", "unnamed": 1, "visible": True}
mainWindow_Next_StatusBaseText = {"container": statusDesktop_mainWindow, "text": "Next", "type": "StatusBaseText", "unnamed": 1, "visible": True}
mainWindow_nextBtn_StatusButton = {"container": statusDesktop_mainWindow, "id": "nextBtn", "type": "StatusButton", "unnamed": 1, "visible": True}
mainWindow_New_password_PlaceholderText = {"container": statusDesktop_mainWindow, "text": "New password", "type": "PlaceholderText", "unnamed": 1, "visible": True}
mainWindow_Password_textField = {"container": statusDesktop_mainWindow, "echoMode": 2, "id": "inputValue", "occurrence": 2, "passwordCharacter": "•", "type": "StyledTextField", "unnamed": 1, "visible": True}
mainWindow_Ok_got_it_StatusBaseText = {"container": statusDesktop_mainWindow, "text": "Ok, got it", "type": "StatusBaseText", "unnamed": 1, "visible": True}

mainWindow_Create_password_StatusBaseText = {"container": statusDesktop_mainWindow, "text": "Create password", "type": "StatusBaseText", "unnamed": 1, "visible": True}
mainWindow_Finalise_Status_Password_Creation_StatusBaseText = {"container": statusDesktop_mainWindow, "text": "Finalise Status Password Creation", "type": "StatusBaseText", "unnamed": 1, "visible": True}
mainWindow_I_prefer_to_use_my_password_StatusBaseText = {"container": statusDesktop_mainWindow, "text": "I prefer to use my password", "type": "StatusBaseText", "unnamed": 1, "visible": True}
mainWindow_button_StatusButton = {"container": statusDesktop_mainWindow, "id": "button", "type": "StatusButton", "unnamed": 1, "visible": True}
username_must_be_at_least_5_characters_error_message = {"container": statusDesktop_mainWindow, "text": "Username must be at least 5 characters", "type": "StatusBaseText", "unnamed": 1, "visible": True}

mainWindow_Welcome_to_Status_StyledText = {"container": statusDesktop_mainWindow, "text": "Welcome to Status", "type": "StyledText", "unnamed": 1, "visible": True}
mainWindow_Enter_a_seed_phrase_StatusBaseText = {"container": statusDesktop_mainWindow, "text": "Enter a seed phrase", "type": "StatusBaseText", "unnamed": 1, "visible": True}

import_a_seed_phrase_StatusBaseText = {"container": statusDesktop_mainWindow, "text": "Import a seed phrase", "type": "StatusBaseText", "unnamed": 1, "visible": True}
mainWindow_placeholder_StatusBaseText = {"container": statusDesktop_mainWindow, "id": "placeholder", "type": "StatusBaseText", "unnamed": 1, "visible": True}

mainWindow_submitButton_StatusButton = {"container": statusDesktop_mainWindow, "id": "submitButton", "type": "StatusButton", "unnamed": 1, "visible": True}

mainWindow_Confirm_your_password_again_PlaceholderText = {"container": statusDesktop_mainWindow, "text": "Confirm your password (again)", "type": "PlaceholderText", "unnamed": 1, "visible": True}
only_letters_numbers_underscores_and_hyphens_allowed_error_message = {"container": statusDesktop_mainWindow, "text": "Only letters, numbers, underscores and hyphens allowed", "type": "StatusBaseText", "unnamed": 1, "visible": True}
twentyfour_character_username_limit_error_message = {"container": statusDesktop_mainWindow, "text": "24 character username limit", "type": "StatusBaseText", "unnamed": 1, "visible": True}
i_already_use_status_button_StatusFlatButton = {"container": statusDesktop_mainWindow, "objectName": "i_already_use_status_button", "type": "StatusFlatButton", "visible": True}


statusDesktop_mainWindow_overlay = {"container": statusDesktop_mainWindow, "type": "Overlay", "unnamed": 1, "visible": True}


accountsView_accountListPanel = {"container": statusDesktop_mainWindow_overlay, "type": "AccountListPanel", "visible": True}
acknowledge_checkbox = {"checkable": True, "container": statusDesktop_mainWindow_overlay, "objectName": "acknowledgeCheckBox", "type": "StatusCheckBox", "visible": True}
termsOfUseCheckBox_StatusCheckBox = {"checkable": True, "container": statusDesktop_mainWindow_overlay, "id":"termsOfUse", "type": "StatusCheckBox", "visible": True}
getStartedStatusButton_StatusButton = {"container": statusDesktop_mainWindow_overlay, "objectName": "getStartedStatusButton", "type": "StatusButton", "visible": True}
get_Started_StatusBaseText = {"container": statusDesktop_mainWindow_overlay, "text": "Get Started", "type": "StatusBaseText", "unnamed": 1, "visible": True}
edit_TextEdit = {"container": statusDesktop_mainWindow_overlay, "id": "edit", "type": "TextEdit", "unnamed": 1, "visible": True}
inputValue_StyledTextField = {"container": statusDesktop_mainWindow_overlay, "echoMode": 0, "id": "inputValue", "type": "StyledTextField", "unnamed": 1, "visible": True}
start_chat_StatusBaseText = {"container": statusDesktop_mainWindow_overlay, "text": "Start chat", "type": "StatusBaseText", "unnamed": 1, "visible": True}
i_understand_StatusBaseText = {"container": statusDesktop_mainWindow_overlay, "text": "I understand", "type": "StatusBaseText", "unnamed": 1, "visible": True}

mainWindow_scrollView_ScrollView = {"container": statusDesktop_mainWindow, "id": "scrollView", "type": "ScrollView", "unnamed": 1, "visible": True}
scrollView_messageInputField_TextArea = {"container": mainWindow_scrollView_ScrollView, "id": "messageInputField", "type": "TextArea", "unnamed": 1, "visible": True}
scrollView_Type_a_message_PlaceholderText = {"container": mainWindow_scrollView_ScrollView, "text": "Type a message.", "type": "PlaceholderText", "unnamed": 1, "visible": True}

mainWindow_switchTabBar_StatusSwitchTabBar = {"container": statusDesktop_mainWindow, "id": "switchTabBar", "type": "StatusSwitchTabBar", "unnamed": 1, "visible": True}
switchTabBar_18_words_StatusBaseText = {"container": mainWindow_switchTabBar_StatusSwitchTabBar, "text": "18 words", "type": "StatusBaseText", "unnamed": 1, "visible": True}
switchTabBar_24_words_StatusBaseText = {"container": mainWindow_switchTabBar_StatusSwitchTabBar, "text": "24 words", "type": "StatusBaseText", "unnamed": 1, "visible": True}
switchTabBar_12_words_StatusBaseText = {"container": mainWindow_switchTabBar_StatusSwitchTabBar, "text": "12 words", "type": "StatusBaseText", "unnamed": 1, "visible": True}


mainWindow_navBarListView_ListView = {"container": statusDesktop_mainWindow, "id": "navBarListView", "type": "ListView", "unnamed": 1, "visible": True}

mainWindow_ScrollView = {"container": statusDesktop_mainWindow, "type": "ScrollView", "unnamed": 1, "visible": True}
wallet_AppMenu_StatusNavigationListItem = {"container": mainWindow_ScrollView, "objectName": "Wallet-AppMenu", "type": "StatusNavigationListItem", "visible": True}

advanced_StatusBaseText = {"container": mainWindow_ScrollView, "text": "Advanced", "type": "StatusBaseText", "unnamed": 1, "visible": True}

mainWindow_ScrollView_2 = {"container": statusDesktop_mainWindow, "occurrence": 2, "type": "ScrollView", "unnamed": 1, "visible": True}

twelve_seed_phrase_address = {"container": mainWindow_ScrollView_2, "text": "0x8285cb9bf17b23d64a489a8dad29163dd227d0fd", "type": "StatusBaseText", "unnamed": 1, "visible": True}
eighteen_seed_phrase_address = {"container": mainWindow_ScrollView_2, "text": "0xba1d0d6ef35df8751df5faf55ebd885ad0e877b0", "type": "StatusBaseText", "unnamed": 1, "visible": True}
twenty_four_seed_phrase_address = {"container": mainWindow_ScrollView_2, "text": "0x28cf6770664821a51984daf5b9fb1b52e6538e4b", "type": "StatusBaseText", "unnamed": 1, "visible": True}
walletSettingsLineButton = {"container": mainWindow_ScrollView_2, "objectName": "WalletSettingsLineButton", "type": "StatusSettingsLineButton", "visible": True}

o_ScrollBar = {"container": mainWindow_ScrollView, "type": "ScrollBar", "unnamed": 1, "visible": True}
mainWindow_public_chat_icon_StatusIcon = {"container": statusDesktop_mainWindow, "objectName": "public-chat-icon", "source": "qrc:/StatusQ/src/assets/img/icons/public-chat.svg", "type": "StatusIcon", "visible": True}

navBarListView_Settings_navbar_StatusNavBarTabButton = {"checkable": True, "container": mainWindow_navBarListView_ListView, "objectName": "Settings-navbar", "type": "StatusNavBarTabButton", "visible": True}
settings_navbar_settings_icon_StatusIcon = {"container": navBarListView_Settings_navbar_StatusNavBarTabButton, "objectName": "settings-icon", "source": "qrc:/StatusQ/src/assets/img/icons/settings.svg", "type": "StatusIcon", "visible": True}
