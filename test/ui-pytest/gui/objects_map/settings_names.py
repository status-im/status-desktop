from gui.objects_map.main_names import statusDesktop_mainWindow

mainWindow_ProfileLayout = {"container": statusDesktop_mainWindow, "type": "ProfileLayout", "unnamed": 1, "visible": True}
mainWindow_StatusSectionLayout_ContentItem = {"container": mainWindow_ProfileLayout, "objectName": "StatusSectionLayout", "type": "ContentItem", "visible": True}
settingsContentBase_ScrollView = {"container": statusDesktop_mainWindow, "objectName": "settingsContentBaseScrollView", "type": "StatusScrollView", "visible": True}
settingsContentBaseScrollView_Flickable = {"container": settingsContentBase_ScrollView, "type": "Flickable", "unnamed": 1, "visible": True}

# Left Panel
mainWindow_LeftTabView = {"container": mainWindow_StatusSectionLayout_ContentItem, "type": "LeftTabView", "unnamed": 1, "visible": True}
mainWindow_Settings_StatusNavigationPanelHeadline = {"container": mainWindow_LeftTabView, "type": "StatusNavigationPanelHeadline", "unnamed": 1, "visible": True}
mainWindow_scrollView_StatusScrollView = {"container": mainWindow_LeftTabView, "id": "scrollView", "type": "StatusScrollView", "unnamed": 1, "visible": True}
scrollView_AppMenuItem_StatusNavigationListItem = {"container": mainWindow_scrollView_StatusScrollView, "type": "StatusNavigationListItem", "visible": True}

# Communities View
mainWindow_CommunitiesView = {"container": statusDesktop_mainWindow, "type": "CommunitiesView", "unnamed": 1, "visible": True}
mainWindow_settingsContentBaseScrollView_StatusScrollView = {"container": mainWindow_CommunitiesView, "objectName": "settingsContentBaseScrollView", "type": "StatusScrollView", "visible": True}
settingsContentBaseScrollView_listItem_StatusListItem = {"container": mainWindow_settingsContentBaseScrollView_StatusScrollView, "id": "listItem", "type": "StatusListItem", "unnamed": 1, "visible": True}

settings_iconOrImage_StatusSmartIdenticon = {"id": "iconOrImage", "type": "StatusSmartIdenticon", "unnamed": 1, "visible": True}
settings_Name_StatusTextWithLoadingState = {"type": "StatusTextWithLoadingState", "unnamed": 1, "visible": True}
settings_statusListItemSubTitle = {"objectName": "statusListItemSubTitle", "type": "StatusTextWithLoadingState", "visible": True}
settings_member_StatusTextWithLoadingState = {"text": "1 member", "type": "StatusTextWithLoadingState", "unnamed": 1, "visible": True}
settings_StatusFlatButton = {"type": "StatusFlatButton", "unnamed": 1, "visible": True}

# Keycard Settings View
mainWindow_KeycardView = {"container": statusDesktop_mainWindow, "type": "KeycardView", "unnamed": 1, "visible": True}
settingsContentBaseScrollView_setupFromExistingKeycardAccount_StatusListItem = {"container": settingsContentBase_ScrollView, "objectName": "setupFromExistingKeycardAccount", "type": "StatusListItem", "visible": True}
settingsContentBaseScrollView_createNewKeycardAccount_StatusListItem = {"container": settingsContentBase_ScrollView, "objectName": "createNewKeycardAccount", "type": "StatusListItem", "visible": True}
settingsContentBaseScrollView_importRestoreKeycard_StatusListItem = {"container": settingsContentBase_ScrollView, "objectName": "importRestoreKeycard", "type": "StatusListItem", "visible": True}
settingsContentBaseScrollView_importFromKeycard_StatusListItem = {"container": settingsContentBase_ScrollView, "objectName": "importFromKeycard", "type": "StatusListItem", "visible": True}
settingsContentBaseScrollView_checkWhatsNewKeycard_StatusListItem = {"container": settingsContentBase_ScrollView, "objectName": "checkWhatsNewKeycard", "type": "StatusListItem", "visible": True}
settingsContentBaseScrollView_factoryResetKeycard_StatusListItem = {"container": settingsContentBase_ScrollView, "objectName": "factoryResetKeycard", "type": "StatusListItem", "visible": True}

