from . main_names import *

mainWindow_onboardingBackButton_StatusRoundButton = {"container": statusDesktop_mainWindow, "objectName": "onboardingBackButton", "type": "StatusRoundButton", "visible": True}

# Allow Notification View
mainWindow_AllowNotificationsView = {"container": statusDesktop_mainWindow, "type": "AllowNotificationsView", "unnamed": 1, "visible": True}
mainWindow_allowNotificationsOnboardingOkButton = {"container": mainWindow_AllowNotificationsView, "objectName": "allowNotificationsOnboardingOkButton", "type": "StatusButton", "visible": True}

# Welcome View
mainWindow_WelcomeView = {"container": statusDesktop_mainWindow, "type": "WelcomeView", "unnamed": 1, "visible": True}
mainWindow_I_am_new_to_Status_StatusBaseText = {"container": mainWindow_WelcomeView, "objectName": "welcomeViewIAmNewToStatusButton", "type": "StatusButton"}
mainWindow_I_already_use_Status_StatusBaseText = {"container": mainWindow_WelcomeView, "objectName": "welcomeViewIAlreadyUseStatusButton", "type": "StatusFlatButton", "visible": True}

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

# Seed Phrase Input View
mainWindow_SeedPhraseInputView = {"container": statusDesktop_mainWindow, "type": "SeedPhraseInputView", "unnamed": 1,
                                  "visible": True}
switchTabBar_12_words_Button = {"container": mainWindow_SeedPhraseInputView, "objectName": "12SeedButton",
                                "type": "StatusSwitchTabButton"}
switchTabBar_18_words_Button = {"container": mainWindow_SeedPhraseInputView, "objectName": "18SeedButton",
                                "type": "StatusSwitchTabButton"}
switchTabBar_24_words_Button = {"container": mainWindow_SeedPhraseInputView, "objectName": "24SeedButton",
                                "type": "StatusSwitchTabButton"}
mainWindow_statusSeedPhraseInputField_TextEdit = {"container": mainWindow_SeedPhraseInputView,
                                                  "objectName": "statusSeedPhraseInputField", "type": "TextEdit",
                                                  "visible": True}
mainWindow_Import_StatusButton = {"checkable": False, "container": mainWindow_SeedPhraseInputView,
                                  "objectName": "seedPhraseViewSubmitButton", "text": "Import", "type": "StatusButton",
                                  "visible": True}

# Keycard Init View
mainWindow_KeycardInitView = {"container": statusDesktop_mainWindow, "type": "KeycardInitView", "unnamed": 1,
                              "visible": True}
mainWindow_Plug_in_Keycard_reader_StatusBaseText = {"container": mainWindow_KeycardInitView, "type": "StatusBaseText",
                                                    "unnamed": 1, "visible": True}

# Your Profile View
mainWindow_InsertDetailsView = {"container": statusDesktop_mainWindow, "type": "InsertDetailsView", "unnamed": 1, "visible": True}
updatePicButton_StatusRoundButton = {"container": mainWindow_InsertDetailsView, "id": "updatePicButton", "type": "StatusRoundButton", "unnamed": 1, "visible": True}
mainWindow_CanvasItem = {"container": mainWindow_InsertDetailsView, "type": "CanvasItem", "unnamed": 1, "visible": True}
mainWindow_Next_StatusButton = {"container": statusDesktop_mainWindow, "objectName": "onboardingDetailsViewNextButton", "type": "StatusButton", "visible": True, "enabled": True}
mainWindow_inputLayout_ColumnLayout = {"container": statusDesktop_mainWindow, "id": "inputLayout", "type": "ColumnLayout", "unnamed": 1, "visible": True}
mainWindow_statusBaseInput_StatusBaseInput = {"container": mainWindow_inputLayout_ColumnLayout, "objectName": "onboardingDisplayNameInput", "type": "TextEdit", "visible": True}
mainWindow_errorMessage_StatusBaseText = {"container": mainWindow_inputLayout_ColumnLayout, "type": "StatusBaseText", "unnamed": 1, "visible": True}

# Your emojihash and identicon ring
mainWindow_welcomeScreenUserProfileImage_StatusSmartIdenticon = {"container": mainWindow_InsertDetailsView, "objectName": "welcomeScreenUserProfileImage", "type": "StatusSmartIdenticon", "visible": True}
mainWindow_insertDetailsViewChatKeyTxt_StyledText = {"container": mainWindow_InsertDetailsView, "objectName": "insertDetailsViewChatKeyTxt", "type": "StyledText", "visible": True}
mainWindow_EmojiHash = {"container": mainWindow_InsertDetailsView, "type": "EmojiHash", "unnamed": 1, "visible": True}
mainWindow_userImageCopy_StatusSmartIdenticon = {"container": mainWindow_InsertDetailsView, "id": "userImageCopy", "type": "StatusSmartIdenticon", "unnamed": 1, "visible": True}


# Create Password View
mainWindow_CreatePasswordView = {"container": statusDesktop_mainWindow, "type": "CreatePasswordView", "unnamed": 1, "visible": True}
mainWindow_passwordViewNewPassword = {"container": mainWindow_CreatePasswordView, "echoMode": 2, "objectName": "passwordViewNewPassword", "type": "StatusPasswordInput", "visible": True}
mainWindow_passwordViewNewPasswordConfirm = {"container": mainWindow_CreatePasswordView, "echoMode": 2, "objectName": "passwordViewNewPasswordConfirm", "type": "StatusPasswordInput", "visible": True}
mainWindow_Create_password_StatusButton = {"checkable": False, "container": mainWindow_CreatePasswordView, "objectName": "onboardingCreatePasswordButton", "type": "StatusButton", "visible": True, "enabled": True}

# Confirm Password View
mainWindow_ConfirmPasswordView = {"container": statusDesktop_mainWindow, "type": "ConfirmPasswordView", "unnamed": 1,"visible": True}
mainWindow_confirmAgainPasswordInput = {"container": mainWindow_ConfirmPasswordView, "objectName": "confirmAgainPasswordInput", "type": "StatusPasswordInput", "visible": True}
mainWindow_Finalise_Status_Password_Creation_StatusButton = {"checkable": False, "container": mainWindow_ConfirmPasswordView, "objectName": "confirmPswSubmitBtn", "type": "StatusButton", "visible": True}

# Login View
mainWindow_LoginView = {"container": statusDesktop_mainWindow, "type": "LoginView", "unnamed": 1, "visible": True}
loginView_submitBtn = {"container": mainWindow_LoginView, "type": "StatusRoundButton", "visible": True}
loginView_passwordInput = {"container": mainWindow_LoginView, "objectName": "loginPasswordInput", "type": "StyledTextField"}
loginView_currentUserNameLabel = {"container": mainWindow_LoginView, "objectName": "currentUserNameLabel", "type": "StatusBaseText"}
loginView_changeAccountBtn = {"container": mainWindow_LoginView, "objectName": "loginChangeAccountButton", "type": "StatusFlatRoundButton"}
accountsView_accountListPanel = {"container": statusDesktop_mainWindow, "objectName": "LoginView_AccountsRepeater", "type": "Repeater", "visible": True}


# Touch ID Auth View
mainWindow_TouchIDAuthView = {"container": statusDesktop_mainWindow, "type": "TouchIDAuthView", "unnamed": 1, "visible": True}
mainWindow_touchIdIPreferToUseMyPasswordText = {"container": statusDesktop_mainWindow, "objectName": "touchIdIPreferToUseMyPasswordText", "type": "StatusBaseText"}
