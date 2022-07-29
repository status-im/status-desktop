
from sections.global_names import *

# Main:
mainWindow_Welcome_to_Status_StyledText = {"container": statusDesktop_mainWindow, "text": "Welcome to Status", "type": "StyledText", "unnamed": 1, "visible": True}
onboarding_newPsw_Input = {"container": statusDesktop_mainWindow, "text": "New password", "type": "PlaceholderText"}
onboarding_confirmPsw_Input = {"container": statusDesktop_mainWindow, "text": "Confirm password", "type": "PlaceholderText"}
onboarding_create_password_button = {"container": statusDesktop_mainWindow, "objectName": "onboardingCreatePasswordButton", "type": "StatusButton"}
onboarding_confirmPswAgain_Input = {"container": statusDesktop_mainWindow, "text": "Confirm your password (again)", "type": "PlaceholderText"}
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

# Seed phrase form:
import_a_seed_phrase_StatusBaseText = {"container": statusDesktop_mainWindow, "text": "Import a seed phrase", "type": "StatusBaseText", "unnamed": 1, "visible": True}
mainWindow_switchTabBar_StatusSwitchTabBar = {"container": statusDesktop_mainWindow, "id": "switchTabBar", "type": "StatusSwitchTabBar", "unnamed": 1, "visible": True}
switchTabBar_12_words_StatusBaseText = {"container": mainWindow_switchTabBar_StatusSwitchTabBar, "text": "12 words", "type": "StatusBaseText", "unnamed": 1, "visible": True}
switchTabBar_18_words_StatusBaseText = {"container": mainWindow_switchTabBar_StatusSwitchTabBar, "text": "18 words", "type": "StatusBaseText", "unnamed": 1, "visible": True}
switchTabBar_24_words_StatusBaseText = {"container": mainWindow_switchTabBar_StatusSwitchTabBar, "text": "24 words", "type": "StatusBaseText", "unnamed": 1, "visible": True}
mainWindow_placeholder_StatusBaseText = {"container": statusDesktop_mainWindow, "id": "placeholder", "type": "StatusBaseText", "unnamed": 1, "visible": True}
seedPhraseView_Submit_Button = {"container": statusDesktop_mainWindow, "objectName": "seedPhraseViewSubmitButton", "type": "StatusButton"}

