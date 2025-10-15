from scripts.global_names import *

# Main:
mainWindow_Welcome_to_Status_StyledText = {"container": statusDesktop_mainWindow, "text": "Welcome to Status", "type": "StyledText", "unnamed": 1, "visible": True}
mainWindow_startupOnboarding_OnboardingLayout = {"container": statusDesktop_mainWindow, "objectName": "startupOnboardingLayout", "type": "OnboardingLayout", "visible": True}

# Create Password View
mainWindow_CreatePasswordView = {"container": statusDesktop_mainWindow, "type": "CreatePasswordView", "unnamed": 1, "visible": True}
onboarding_newPsw_Input = {"container": mainWindow_CreatePasswordView, "objectName": "passwordViewNewPassword", "type": "StatusPasswordInput", "visible": True}
onboarding_confirmPsw_Input = {"container": mainWindow_CreatePasswordView, "objectName": "passwordViewNewPasswordConfirm", "type": "StatusPasswordInput", "visible": True}
onboarding_create_password_button = {"container": mainWindow_CreatePasswordView, "objectName": "onboardingCreatePasswordButton", "type": "StatusButton"}
onboarding_strengthInditactor = {"container": mainWindow_CreatePasswordView, "type": "StatusPasswordStrengthIndicator", "unnamed": 1, "visible": True}

onboarding_confirmPswAgain_Input = {"container": statusDesktop_mainWindow, "objectName": "confirmAgainPasswordInput", "type": "StatusPasswordInput", "visible": True}
onboarding_finalise_password_button = {"container": statusDesktop_mainWindow, "objectName": "confirmPswSubmitBtn", "type": "StatusButton"}
acknowledge_checkbox = {"checkable": True, "container": statusDesktop_mainWindow_overlay, "objectName": "acknowledgeCheckBox", "type": "StatusCheckBox", "visible": True}
termsOfUseCheckBox_StatusCheckBox = {"checkable": True, "container": statusDesktop_mainWindow_overlay, "objectName":"termsOfUseCheckBox", "type": "StatusCheckBox", "visible": True}
getStartedStatusButton_StatusButton = {"container": statusDesktop_mainWindow_overlay, "objectName": "getStartedStatusButton", "type": "StatusButton", "visible": True}
mainWindow_I_am_new_to_Status_StatusBaseText = {"container": statusDesktop_mainWindow, "objectName": "welcomeViewIAmNewToStatusButton", "type": "StatusButton"}
keysMainView_PrimaryAction_Button = {"container": statusDesktop_mainWindow, "objectName": "keysMainViewPrimaryActionButton", "type": "StatusButton"}
onboarding_DiplayName_Input = {"container": statusDesktop_mainWindow, "objectName": "onboardingDisplayNameInput", "type": "TextEdit"}
onboarding_DetailsView_NextButton = {"container": statusDesktop_mainWindow, "objectName": "onboardingDetailsViewNextButton", "type": "StatusButton"}
mainWindow_I_prefer_to_use_my_password_StatusBaseText = {"container": statusDesktop_mainWindow, "objectName": "touchIdIPreferToUseMyPasswordText", "type": "StatusBaseText"}
mainWindow_Ok_got_it_StatusBaseText = {"container": statusDesktop_mainWindow, "type": "StatusButton", "objectName": "allowNotificationsOnboardingOkButton", "visible": True}
mainWindow_WelcomeScreen_User_Profile_Image = {"container": statusDesktop_mainWindow, "type": "StatusSmartIdenticon", "objectName": "welcomeScreenUserProfileImage"}
mainWindow_WelcomeScreen_ChatKeyText = {"container": statusDesktop_mainWindow, "type": "StyledText", "objectName": "insertDetailsViewChatKeyTxt"}
mainWindow_WelcomeScreen_Image_Crop_Workflow_Item= {"container": statusDesktop_mainWindow, "type": "Item", "objectName": "imageCropWorkflow"}
mainWindow_WelcomeScreen_Image_Cropper_Accept_Button= {"container": statusDesktop_mainWindow, "type": "StatusButton", "objectName": "imageCropperAcceptButton"}
onboarding_back_button = {"container": statusDesktop_mainWindow, "objectName": "onboardingBackButton", "type": "StatusRoundButton", "visible": True}

# Seed phrase form:
import_a_seed_phrase_StatusBaseText = {"container": statusDesktop_mainWindow, "text": "Import a seed phrase", "type": "StatusBaseText", "unnamed": 1, "visible": True}
mainWindow_switchTabBar_StatusSwitchTabBar = {"container": statusDesktop_mainWindow, "objectName": "enterSeedPhraseSwitchBar", "type": "StatusSwitchTabBar"}
switchTabBar_12_words_Button = {"container": mainWindow_switchTabBar_StatusSwitchTabBar, "objectName": "12SeedButton", "type": "StatusSwitchTabButton"}
switchTabBar_18_words_Button = {"container": mainWindow_switchTabBar_StatusSwitchTabBar, "objectName": "18SeedButton", "type": "StatusSwitchTabButton"}
switchTabBar_24_words_Button = {"container": mainWindow_switchTabBar_StatusSwitchTabBar, "objectName": "24SeedButton", "type": "StatusSwitchTabButton"}
seedPhraseView_Submit_Button = {"container": statusDesktop_mainWindow, "objectName": "seedPhraseViewSubmitButton", "type": "StatusButton"}
onboarding_InvalidSeed_Text = {"container": statusDesktop_mainWindow, "objectName": "onboardingInvalidSeedText", "type": "StatusBaseText"}

onboarding_SeedPhrase_Input_TextField_1 = {"container": statusDesktop_mainWindow, "type": "TextField", "objectName": "enterSeedPhraseInputField1"}
onboarding_SeedPhrase_Input_TextField_2 = {"container": statusDesktop_mainWindow, "type": "TextField", "objectName": "enterSeedPhraseInputField2"}
onboarding_SeedPhrase_Input_TextField_3 = {"container": statusDesktop_mainWindow, "type": "TextField", "objectName": "enterSeedPhraseInputField3"}
onboarding_SeedPhrase_Input_TextField_4 = {"container": statusDesktop_mainWindow, "type": "TextField", "objectName": "enterSeedPhraseInputField4"}
onboarding_SeedPhrase_Input_TextField_5 = {"container": statusDesktop_mainWindow, "type": "TextField", "objectName": "enterSeedPhraseInputField5"}
onboarding_SeedPhrase_Input_TextField_6 = {"container": statusDesktop_mainWindow, "type": "TextField", "objectName": "enterSeedPhraseInputField6"}
onboarding_SeedPhrase_Input_TextField_7 = {"container": statusDesktop_mainWindow, "type": "TextField", "objectName": "enterSeedPhraseInputField7"}
onboarding_SeedPhrase_Input_TextField_8 = {"container": statusDesktop_mainWindow, "type": "TextField", "objectName": "enterSeedPhraseInputField8"}
onboarding_SeedPhrase_Input_TextField_9 = {"container": statusDesktop_mainWindow, "type": "TextField", "objectName": "enterSeedPhraseInputField9"}
onboarding_SeedPhrase_Input_TextField_10 = {"container": statusDesktop_mainWindow, "type": "TextField", "objectName": "enterSeedPhraseInputField10"}
onboarding_SeedPhrase_Input_TextField_11 = {"container": statusDesktop_mainWindow, "type": "TextField", "objectName": "enterSeedPhraseInputField11"}
onboarding_SeedPhrase_Input_TextField_12 = {"container": statusDesktop_mainWindow, "type": "TextField", "objectName": "enterSeedPhraseInputField12"}
onboarding_SeedPhrase_Input_TextField_13 = {"container": statusDesktop_mainWindow, "type": "TextField", "objectName": "enterSeedPhraseInputField13"}
onboarding_SeedPhrase_Input_TextField_14 = {"container": statusDesktop_mainWindow, "type": "TextField", "objectName": "enterSeedPhraseInputField14"}
onboarding_SeedPhrase_Input_TextField_15 = {"container": statusDesktop_mainWindow, "type": "TextField", "objectName": "enterSeedPhraseInputField15"}
onboarding_SeedPhrase_Input_TextField_16 = {"container": statusDesktop_mainWindow, "type": "TextField", "objectName": "enterSeedPhraseInputField16"}
onboarding_SeedPhrase_Input_TextField_17 = {"container": statusDesktop_mainWindow, "type": "TextField", "objectName": "enterSeedPhraseInputField17"}
onboarding_SeedPhrase_Input_TextField_18 = {"container": statusDesktop_mainWindow, "type": "TextField", "objectName": "enterSeedPhraseInputField18"}
onboarding_SeedPhrase_Input_TextField_19 = {"container": statusDesktop_mainWindow, "type": "TextField", "objectName": "enterSeedPhraseInputField19"}
onboarding_SeedPhrase_Input_TextField_20 = {"container": statusDesktop_mainWindow, "type": "TextField", "objectName": "enterSeedPhraseInputField20"}
onboarding_SeedPhrase_Input_TextField_21 = {"container": statusDesktop_mainWindow, "type": "TextField", "objectName": "enterSeedPhraseInputField21"}
onboarding_SeedPhrase_Input_TextField_22 = {"container": statusDesktop_mainWindow, "type": "TextField", "objectName": "enterSeedPhraseInputField22"}
onboarding_SeedPhrase_Input_TextField_23 = {"container": statusDesktop_mainWindow, "type": "TextField", "objectName": "enterSeedPhraseInputField23"}
onboarding_SeedPhrase_Input_TextField_24 = {"container": statusDesktop_mainWindow, "type": "TextField", "objectName": "enterSeedPhraseInputField24"}
