# encoding: UTF-8

from objectmaphelper import *

statusDesktop_mainWindow = {"name": "mainWindow", "type": "StatusWindow", "visible": True}
mainWindow_dropRectangle_Rectangle = {"container": statusDesktop_mainWindow, "id": "dropRectangle", "type": "Rectangle", "unnamed": 1, "visible": True}
loginView_passwordInput = {"container": statusDesktop_mainWindow, "echoMode": 2, "id": "inputValue", "passwordCharacter": "•", "type": "StyledTextField", "unnamed": 1, "visible": True}
loginView_changeAccountBtn = {"container": statusDesktop_mainWindow, "id": "changeAccountBtn", "type": "Rectangle", "unnamed": 1, "visible": True}
loginView_submitBtn = {"container": statusDesktop_mainWindow, "type": "StatusRoundButton", "visible": True}
loginView_main = {"container": statusDesktop_mainWindow, "type": "LoginView", "visible": True}
loginView_errMsgLabel = {"container": statusDesktop_mainWindow, "id": "errMsg", "type": "StyledText", "visible": True}
statusDesktop_mainWindow_overlay = {"container": statusDesktop_mainWindow, "type": "Overlay", "unnamed": 1, "visible": True}
accountsView_accountListPanel = {"container": statusDesktop_mainWindow_overlay, "type": "AccountListPanel", "visible": True}
acknowledge_checkbox = {"checkable": True, "container": statusDesktop_mainWindow_overlay, "objectName": "acknowledgeCheckBox", "type": "StatusCheckBox", "visible": True}
termsOfUseCheckBox_StatusCheckBox = {"checkable": True, "container": statusDesktop_mainWindow_overlay, "id":"termsOfUse", "type": "StatusCheckBox", "visible": True}
getStartedStatusButton_StatusButton = {"container": statusDesktop_mainWindow_overlay, "objectName": "getStartedStatusButton", "type": "StatusButton", "visible": True}
mainWindow_I_am_new_to_Status_StatusBaseText = {"container": statusDesktop_mainWindow, "text": "I am new to Status", "type": "StatusBaseText", "unnamed": 1, "visible": True}
mainWindow_Generate_new_keys_StatusBaseText = {"container": statusDesktop_mainWindow, "text": "Generate new keys", "type": "StatusBaseText", "unnamed": 1, "visible": True}
get_Started_StatusBaseText = {"container": statusDesktop_mainWindow_overlay, "text": "Get Started", "type": "StatusBaseText", "unnamed": 1, "visible": True}
i_accept_Status_StatusBaseText = {"container": statusDesktop_mainWindow_overlay, "text": "I accept Status", "type": "StatusBaseText", "unnamed": 1, "visible": True}
termsOfUseLink_StatusBaseText = {"container": statusDesktop_mainWindow_overlay, "objectName": "termsOfUseLink", "type": "StatusBaseText", "visible": True}
mainWindow_edit_TextEdit = {"container": statusDesktop_mainWindow, "id": "edit", "type": "TextEdit", "unnamed": 1, "visible": True}
mainWindow_Next_StatusBaseText = {"container": statusDesktop_mainWindow, "text": "Next", "type": "StatusBaseText", "unnamed": 1, "visible": True}
mainWindow_Confirm_password_PlaceholderText = {"container": statusDesktop_mainWindow, "text": "Confirm password", "type": "PlaceholderText", "unnamed": 1, "visible": True}
mainWindow_Display_name_StatusBaseText = {"container": statusDesktop_mainWindow, "text": "Display name", "type": "StatusBaseText", "unnamed": 1, "visible": True}
mainWindow_nextBtn_StatusButton = {"container": statusDesktop_mainWindow, "id": "nextBtn", "type": "StatusButton", "unnamed": 1, "visible": True}
mainWindow_New_password_PlaceholderText = {"container": statusDesktop_mainWindow, "text": "New password", "type": "PlaceholderText", "unnamed": 1, "visible": True}
mainWindow_inputValue_StyledTextField = {"container": statusDesktop_mainWindow, "echoMode": 2, "id": "inputValue", "occurrence": 2, "passwordCharacter": "•", "type": "StyledTextField", "unnamed": 1, "visible": True}
mainWindow_Rectangle = {"container": statusDesktop_mainWindow, "occurrence": 11, "type": "Rectangle", "unnamed": 1, "visible": True}
mainWindow_Create_password_StatusBaseText = {"container": statusDesktop_mainWindow, "text": "Create password", "type": "StatusBaseText", "unnamed": 1, "visible": True}
mainWindow_Confirm_you_password_again_PlaceholderText = {"container": statusDesktop_mainWindow, "text": "Confirm you password (again)", "type": "PlaceholderText", "unnamed": 1, "visible": True}
mainWindow_Finalise_Status_Password_Creation_StatusBaseText = {"container": statusDesktop_mainWindow, "text": "Finalise Status Password Creation", "type": "StatusBaseText", "unnamed": 1, "visible": True}
mainWindow_I_prefer_to_use_my_password_StatusBaseText = {"container": statusDesktop_mainWindow, "text": "I prefer to use my password", "type": "StatusBaseText", "unnamed": 1, "visible": True}
