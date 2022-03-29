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
