statusDesktop_mainWindow = {"name": "mainWindow", "type": "StatusWindow", "visible": True}
statusDesktop_mainWindow_overlay = {"container": statusDesktop_mainWindow, "type": "Overlay", "unnamed": 1, "visible": True}
splashScreen = {"container": statusDesktop_mainWindow, "objectName": "splashScreen", "type": "DidYouKnowSplashScreen"}

# Navigation Panel
mainWindow_StatusAppNavBar = {"container": statusDesktop_mainWindow, "type": "StatusAppNavBar", "unnamed": 1, "visible": True}
messages_navbar_StatusNavBarTabButton = {"checkable": True, "container": mainWindow_StatusAppNavBar, "objectName": "Messages-navbar", "type": "StatusNavBarTabButton", "visible": True}
communities_Portal_navbar_StatusNavBarTabButton = {"checkable": True, "container": mainWindow_StatusAppNavBar, "objectName": "Communities Portal-navbar", "type": "StatusNavBarTabButton", "visible": True}
wallet_navbar_StatusNavBarTabButton = {"checkable": True, "container": mainWindow_StatusAppNavBar, "objectName": "Wallet-navbar", "type": "StatusNavBarTabButton", "visible": True}
settings_navbar_StatusNavBarTabButton = {"checkable": True, "container": mainWindow_StatusAppNavBar, "objectName": "Settings-navbar", "type": "StatusNavBarTabButton", "visible": True}
mainWindow_ProfileNavBarButton = {"container": statusDesktop_mainWindow, "objectName": "statusProfileNavBarTabButton", "type": "StatusNavBarTabButton", "visible": True}

# Banners
secureYourSeedPhraseBanner_ModuleWarning = {"container": statusDesktop_mainWindow, "objectName": "secureYourSeedPhraseBanner", "type": "ModuleWarning", "visible": True}
