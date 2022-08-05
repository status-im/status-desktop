
statusDesktop_mainWindow = {"name": "mainWindow", "type": "StatusWindow", "visible": True}
statusDesktop_mainWindow_overlay = {"container": statusDesktop_mainWindow, "type": "Overlay", "unnamed": 1, "visible": True}
mainWindow_navBarListView_ListView = {"container": statusDesktop_mainWindow, "type": "ListView", "unnamed": 1, "visible": True}
chatView_log = {"container": statusDesktop_mainWindow, "objectName": "chatLogView", "type": "StatusListView", "visible": True}
chatMessageListView_msgDelegate_MessageView = {"container": chatView_log, "objectName": "chatMessageViewDelegate", "index": 1, "type": "MessageView", "visible": True}
moduleWarning_Banner = {"container": statusDesktop_mainWindow, "objectName": "moduleWarningBanner", "type": "Rectangle", "visible": True}

