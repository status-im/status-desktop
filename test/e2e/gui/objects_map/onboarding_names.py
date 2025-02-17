from gui.objects_map.names import statusDesktop_mainWindow, statusDesktop_mainWindow_overlay

# Map for onboarding locators

mainWindow_onboardingBackButton_StatusRoundButton = {"container": statusDesktop_mainWindow, "objectName": "onboardingBackButton", "type": "StatusRoundButton", "visible": True}

# Allow Notification View
mainWindow_AllowNotificationsView = {"container": statusDesktop_mainWindow, "type": "AllowNotificationsView", "unnamed": 1, "visible": True}
mainWindow_Start_using_Status_StatusButton = {"checkable": False, "container": statusDesktop_mainWindow, "objectName": "allowNotificationsOnboardingOkButton", "type": "StatusButton", "visible": True}

# Welcome View
mainWindow_WelcomeView = {"container": statusDesktop_mainWindow, "type": "WelcomeView", "unnamed": 1, "visible": True}
mainWindow_I_am_new_to_Status_StatusBaseText = {"container": mainWindow_WelcomeView, "objectName": "welcomeViewIAmNewToStatusButton", "type": "StatusButton"}
mainWindow_I_already_use_Status_StatusFlatButton = {"checkable": False, "container": statusDesktop_mainWindow, "id": "btnExistingUser", "type": "StatusFlatButton", "visible": True}

# Get Keys View
mainWindow_KeysMainView = {"container": statusDesktop_mainWindow, "type": "KeysMainView", "unnamed": 1, "visible": True}
mainWindow_Generate_new_keys_StatusButton = {"checkable": False, "container": mainWindow_KeysMainView, "objectName": "keysMainViewPrimaryActionButton", "type": "StatusButton", "visible": True}
mainWindow_Generate_keys_for_new_Keycard_StatusBaseText = {"container": mainWindow_KeysMainView, "id": "button2",
                                                           "type": "StatusBaseText", "unnamed": 1, "visible": True}
mainWindow_Import_seed_phrase = {"container": mainWindow_KeysMainView, "id": "button3", "type": "Row", "unnamed": 1,
                                 "visible": True}

# Import Seed Phrase View
keysMainView_PrimaryAction_Button = {"container": statusDesktop_mainWindow,
                                     "objectName": "keysMainViewPrimaryActionButton", "type": "StatusButton"}
mainWindow_iDontHaveOtherDeviceButton_StatusBaseText = {"container": statusDesktop_mainWindow, "objectName": "iDontHaveOtherDeviceButton", "type": "StatusBaseText", "visible": True}

# Seed Phrase Input View
mainWindow_SeedPhraseInputView = {"container": statusDesktop_mainWindow, "type": "SeedPhraseInputView", "unnamed": 1,
                                  "visible": True}
switchTabBar_12_words_Button = {"container": mainWindow_SeedPhraseInputView, "objectName": "12SeedButton",
                                "type": "StatusSwitchTabButton"}
switchTabBar_18_words_Button = {"container": mainWindow_SeedPhraseInputView, "objectName": "18SeedButton",
                                "type": "StatusSwitchTabButton"}
switchTabBar_24_words_Button = {"container": mainWindow_SeedPhraseInputView, "objectName": "24SeedButton",
                                "type": "StatusSwitchTabButton"}
mainWindow_statusSeedPhraseInputField_TextEdit = {"container": statusDesktop_mainWindow, "objectName": "enterSeedPhraseInputField", "type": "TextEdit", "visible": True}

mainWindow_Import_StatusButton = {"checkable": False, "container": mainWindow_SeedPhraseInputView,
                                  "objectName": "seedPhraseViewSubmitButton", "type": "StatusButton",
                                  "visible": True}

# SyncCode View
mainWindow_SyncCodeView = {"container": statusDesktop_mainWindow, "type": "SyncCodeView", "unnamed": 1, "visible": True}
mainWindow_switchTabBar_StatusSwitchTabBar_2 = {"container": statusDesktop_mainWindow, "id": "switchTabBar", "type": "StatusSwitchTabBar", "unnamed": 1, "visible": True}
switchTabBar_Enter_sync_code_StatusSwitchTabButton = {"checkable": True, "container": mainWindow_switchTabBar_StatusSwitchTabBar_2, "objectName": "secondTab_StatusSwitchTabButton", "type": "StatusSwitchTabButton", "visible": True}
mainWindow_statusBaseInput_StatusBaseInput = {"container": statusDesktop_mainWindow, "id": "statusBaseInput", "type": "StatusBaseInput", "unnamed": 1, "visible": True}
mainWindow_Paste_StatusButton = {"container": statusDesktop_mainWindow, "objectName": "syncCodePasteButton", "type": "StatusButton", "visible": True}
mainWindow_syncingEnterCode_SyncingEnterCode = {"container": statusDesktop_mainWindow, "objectName": "syncingEnterCode", "type": "SyncingEnterCode", "visible": True}
mainWindow_nameInput_syncingEnterCode_Continue = {"checkable": False, "container": statusDesktop_mainWindow, "objectName": "continue_StatusButton", "type": "StatusButton", "visible": True}

# SyncDevice View
mainWindow_SyncingDeviceView_found = {"container": statusDesktop_mainWindow, "type": "SyncingDeviceView", "unnamed": 1, "visible": True}
mainWindow_SyncingDeviceView_synced = {"container": statusDesktop_mainWindow, "type": "SyncingDeviceView", "unnamed": 1, "visible": True}
mainWindow_SyncDeviceResult = {"container": statusDesktop_mainWindow, "type": "SyncDeviceResult", "unnamed": 1, "visible": True}
synced_StatusBaseText = {"container": statusDesktop_mainWindow, "type": "StatusBaseText", "unnamed": 1, "visible": True}
mainWindow_Sign_in_StatusButton = {"checkable": False, "container": statusDesktop_mainWindow, "text": "Sign in", "type": "StatusButton", "unnamed": 1, "visible": True}
sync_text_item = {"container": statusDesktop_mainWindow, "type": "StatusBaseText", "unnamed": 1, "visible": True}

# Keycard Init View
mainWindow_KeycardInitView = {"container": statusDesktop_mainWindow, "type": "KeycardInitView", "unnamed": 1,
                              "visible": True}
mainWindow_Plug_in_Keycard_reader_StatusBaseText = {"container": mainWindow_KeycardInitView, "type": "StatusBaseText",
                                                    "unnamed": 1, "visible": True}

# Your Profile View
mainWindow_InsertDetailsView = {"container": statusDesktop_mainWindow, "objectName": "onboardingInsertDetailsView", "type": "InsertDetailsView", "visible": True}
updatePicButton_StatusRoundButton = {"container": mainWindow_InsertDetailsView, "id": "updatePicButton", "type": "StatusRoundButton", "unnamed": 1, "visible": True}
mainWindow_statusRoundImage_StatusRoundedImage = {"container": statusDesktop_mainWindow, "objectName": "statusRoundImage", "type": "StatusRoundedImage", "visible": True}
mainWindow_IdenticonRing = {"container": statusDesktop_mainWindow, "type": "StatusIdenticonRing", "unnamed": 1, "visible": True}
mainWindow_Next_StatusButton = {"checkable": False, "container": statusDesktop_mainWindow, "objectName": "onboardingDetailsViewNextButton", "type": "StatusButton", "visible": True}
mainWindow_inputLayout_ColumnLayout = {"container": statusDesktop_mainWindow, "id": "inputLayout", "type": "ColumnLayout", "unnamed": 1, "visible": True}
mainWindow_statusBaseInput_StatusBaseInput = {"container": mainWindow_inputLayout_ColumnLayout, "objectName": "onboardingDisplayNameInput", "type": "TextEdit", "visible": True}
mainWindow_errorMessage_StatusBaseText = {"container": mainWindow_inputLayout_ColumnLayout, "type": "StatusBaseText", "unnamed": 1, "visible": True}
mainWindow_nameInput_StatusInput = {"container": statusDesktop_mainWindow, "id": "nameInput", "type": "StatusInput", "unnamed": 1, "visible": True}
mainWindow_clear_icon_StatusIcon = {"container": statusDesktop_mainWindow, "objectName": "clear-icon", "type": "StatusIcon"}

# Your emojihash and identicon ring
mainWindow_welcomeScreenUserProfileImage_StatusSmartIdenticon = {"container": mainWindow_InsertDetailsView, "objectName": "welcomeScreenUserProfileImage", "type": "StatusSmartIdenticon", "visible": True}
mainWindow_insertDetailsViewChatKeyTxt_StyledText = {"container": statusDesktop_mainWindow, "objectName": "profileChatKeyViewChatKeyTxt", "type": "StyledText", "visible": True}
mainWindow_EmojiHash = {"container": statusDesktop_mainWindow, "objectName": "publicKeyEmojiHash", "type": "EmojiHash", "visible": True}
mainWindow_Header_Title = {"container": statusDesktop_mainWindow, "objectName": "onboardingHeaderText", "type": "StyledText", "visible": True}
mainWindow_userImageCopy_StatusSmartIdenticon = {"container": statusDesktop_mainWindow, "id": "userImageCopy", "type": "StatusSmartIdenticon", "unnamed": 1, "visible": True}
profileImageCropper = {"container": statusDesktop_mainWindow, "objectName": "imageCropWorkflow", "type": "ImageCropWorkflow", "visible": True}

# Create Password View
mainWindow_CreatePasswordView = {"container": statusDesktop_mainWindow, "type": "CreatePasswordView", "unnamed": 1, "visible": True}
mainWindow_passwordViewNewPassword = {"container": mainWindow_CreatePasswordView, "objectName": "passwordViewNewPassword", "type": "StatusPasswordInput", "visible": True}
mainWindow_passwordViewNewPasswordConfirm = {"container": mainWindow_CreatePasswordView, "objectName": "passwordViewNewPasswordConfirm", "type": "StatusPasswordInput", "visible": True}
mainWindow_Create_password_StatusButton = {"checkable": False, "container": mainWindow_CreatePasswordView, "objectName": "onboardingCreatePasswordButton", "type": "StatusButton", "visible": True}
mainWindow_view_PasswordView = {"container": statusDesktop_mainWindow, "id": "view", "type": "PasswordView", "unnamed": 1, "visible": True}
mainWindow_RowLayout = {"container": statusDesktop_mainWindow, "type": "PassIncludesIndicator", "unnamed": 1, "visible": True}
mainWindow_ComponentIndicator = {"container": statusDesktop_mainWindow, "type": "PasswordComponentIndicator", "unnamed": 1, "visible": True}
mainWindow_strengthInditactor_StatusPasswordStrengthIndicator = {"container": mainWindow_CreatePasswordView, "type": "StatusPasswordStrengthIndicator", "unnamed": 1, "visible": True}
mainWindow_show_icon_StatusIcon = {"container": statusDesktop_mainWindow, "objectName": "show-icon", "type": "StatusIcon", "visible": True}
mainWindow_hide_icon_StatusIcon = {"container": statusDesktop_mainWindow, "objectName": "hide-icon", "type": "StatusIcon", "visible": True}

# Confirm Password View
mainWindow_ConfirmPasswordView = {"container": statusDesktop_mainWindow, "type": "ConfirmPasswordView", "unnamed": 1,"visible": True}
mainWindow_confirmAgainPasswordInput = {"container": mainWindow_ConfirmPasswordView, "objectName": "confirmAgainPasswordInput", "type": "StatusPasswordInput", "visible": True}
mainWindow_Finalise_Status_Password_Creation_StatusButton = {"checkable": False, "container": mainWindow_ConfirmPasswordView, "objectName": "confirmPswSubmitBtn", "type": "StatusButton", "visible": True}
mainWindow_passwordView_PasswordConfirmationView = {"container": statusDesktop_mainWindow, "id": "passwordView", "type": "PasswordConfirmationView", "unnamed": 1, "visible": True}

# Login View
mainWindow_LoginView = {"container": statusDesktop_mainWindow, "type": "LoginView", "unnamed": 1, "visible": True}
loginView_submitBtn = {"container": mainWindow_LoginView, "type": "StatusRoundButton", "visible": True}
loginView_passwordInput = {"container": mainWindow_LoginView, "objectName": "loginPasswordInput", "type": "StatusTextField"}
loginView_currentUserNameLabel = {"container": mainWindow_LoginView, "objectName": "currentUserNameLabel", "type": "StatusBaseText"}
loginView_changeAccountBtn = {"container": mainWindow_LoginView, "objectName": "loginChangeAccountButton", "type": "StatusFlatRoundButton"}
accountsView_accountListPanel = {"container": statusDesktop_mainWindow, "objectName": "LoginView_AccountsRepeater", "type": "Repeater", "visible": True}
mainWindow_txtPassword_Input = {"container": statusDesktop_mainWindow, "id": "txtPassword", "type": "Input", "unnamed": 1, "visible": True}
loginView_addNewUserItem_AccountMenuItemPanel = {"container": statusDesktop_mainWindow_overlay, "index": 0, "objectName": "LoginView_addNewUserItem", "type": "AccountMenuItemPanel", "visible": True}
loginView_addExistingUserItem_AccountMenuItemPanel = {"container": statusDesktop_mainWindow_overlay, "objectName": "LoginView_addExistingUserItem", "type": "AccountMenuItemPanel", "visible": True}
mainWindowUsePasswordInsteadStatusBaseText = {"container": statusDesktop_mainWindow, "text": "Use password instead", "type": "StatusBaseText", "unnamed": 1, "visible": True}

# Touch ID Auth View
mainWindow_TouchIDAuthView = {"container": statusDesktop_mainWindow, "type": "TouchIDAuthView", "unnamed": 1, "visible": True}
mainWindow_touchIdYesUseTouchIDButton = {"container": statusDesktop_mainWindow, "objectName": "touchIdYesUseTouchIDButton", "type": "StatusButton", "visible": True}
mainWindow_touchIdIPreferToUseMyPasswordText = {"container": statusDesktop_mainWindow, "objectName": "touchIdIPreferToUseMyPasswordText", "type": "StatusBaseText"}
