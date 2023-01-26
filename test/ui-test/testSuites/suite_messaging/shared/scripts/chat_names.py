from scripts.global_names import *

# Chat view:
mainWindow_scrollView_ScrollView = {"container": statusDesktop_mainWindow, "id": "scrollView", "type": "StatusScrollView", "unnamed": 1, "visible": True}
mark_as_Read_StatusMenuItem = {"container": statusDesktop_mainWindow_overlay, "objectName": "chatMarkAsReadMenuItem", "type": "StatusMenuItem", "visible": True}
chatView_unfurledLinkComponent_linkImage = {"container": chatView_log, "objectName": "LinksMessageView_unfurledLinkComponent_linkImage", "type": "StatusChatImageLoader", "visible": True}
chatView_LinksMessageView_enableBtn = {"container": chatView_log, "objectName": "LinksMessageView_enableBtn", "type": "StatusFlatButton", "visible": True}

# More options menu
editNameAndImageMenuItem = {"container": statusDesktop_mainWindow_overlay, "objectName": "editNameAndImageMenuItem", "type": "StatusMenuItem", "visible": True}
leaveChatMenuItem = {"container": statusDesktop_mainWindow_overlay, "enabled": True, "objectName": "deleteOrLeaveMenuItem", "type": "StatusMenuItem", "visible": True}

# group chat edit popup
groupChatEdit_main = {"container": statusDesktop_mainWindow_overlay, "objectName": "groupChatEdit_main", "type": "StatusDialog", "visible": True}
groupChatEdit_name = {"container": statusDesktop_mainWindow_overlay, "objectName": "groupChatEdit_name", "type": "TextEdit", "visible": True}
groupChatEdit_save= {"container": statusDesktop_mainWindow_overlay, "objectName": "groupChatEdit_save", "type": "StatusButton", "visible": True}
groupChatEdit_colorRepeater = {"container": statusDesktop_mainWindow, "type": "Repeater", "objectName": "statusColorRepeater", "visible": True}
groupChatEdit_workflowItem= {"container": statusDesktop_mainWindow, "type": "Item", "objectName": "imageCropWorkflow"}
groupChatEdit_cropperAcceptButton = {"container": statusDesktop_mainWindow, "type": "StatusButton", "objectName": "imageCropperAcceptButton"}
groupChatEdit_image = {"container": statusDesktop_mainWindow_overlay, "objectName": "groupChatEdit_image", "type": "EditCroppedImagePanel"}

# Join chat popup:
chat_name_PlaceholderText = {"container": statusDesktop_mainWindow_overlay, "text": "chat-name", "type": "PlaceholderText", "unnamed": 1, "visible": True}

# Create chat view:
createChatView_contactsList = {"container": statusDesktop_mainWindow, "objectName": "createChatContactsList", "type": "StatusListView"}
createChatView_confirmBtn = {"container": statusDesktop_mainWindow, "objectName": "inlineSelectorConfirmButton", "type": "StatusButton"}

# Members panel:
chatView_chatMembers_ListView = {"container": statusDesktop_mainWindow, "objectName": "userListPanel", "type": "ListView"}
