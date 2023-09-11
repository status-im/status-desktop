from .main_names import statusDesktop_mainWindow

mainWindow_chatView_ChatView = {"container": statusDesktop_mainWindow, "id": "chatView", "type": "ChatView", "unnamed": 1, "visible": True}

# Left Panel
mainWindow_contactColumnLoader_Loader = {"container": mainWindow_chatView_ChatView, "id": "contactColumnLoader", "type": "Loader", "unnamed": 1, "visible": True}
mainWindow_startChatButton_StatusIconTabButton = {"checkable": True, "container": mainWindow_contactColumnLoader_Loader, "objectName": "startChatButton", "type": "StatusIconTabButton", "visible": True}
mainWindow_search_edit_TextEdit = {"container": mainWindow_contactColumnLoader_Loader, "id": "edit", "type": "TextEdit", "unnamed": 1, "visible": True}
mainWindow_scrollView_StatusScrollView = {"container": mainWindow_contactColumnLoader_Loader, "id": "scrollView", "type": "StatusScrollView", "unnamed": 1, "visible": True}
scrollView_Flickable = {"container": mainWindow_scrollView_StatusScrollView, "type": "Flickable", "unnamed": 1, "visible": True}
scrollView_ContactsColumnView_chatList_StatusChatList = {"container": mainWindow_scrollView_StatusScrollView, "objectName": "ContactsColumnView_chatList", "type": "StatusChatList", "visible": True}
chatList_ListView = {"container": statusDesktop_mainWindow, "objectName": "chatListItems", "type": "StatusListView", "visible": True}
# Tool Bar
mainWindow_statusToolBar_StatusToolBar = {"container": mainWindow_chatView_ChatView, "objectName": "statusToolBar", "type": "StatusToolBar", "visible": True}

# Chat View
mainWindow_ChatColumnView = {"container": mainWindow_chatView_ChatView, "type": "ChatColumnView", "unnamed": 1, "visible": True}
mainWindow_chatLogView_StatusListView = {"container": mainWindow_ChatColumnView, "objectName": "chatLogView", "type": "StatusListView", "visible": True}
chatLogView_chatMessageViewDelegate_MessageView = {"container": mainWindow_chatLogView_StatusListView, "objectName": "chatMessageViewDelegate", "type": "MessageView", "visible": True, "enabled": True}

# User List Panel
mainWindow_UserListPanel = {"container": mainWindow_chatView_ChatView, "type": "UserListPanel", "unnamed": 1, "visible": True}
userListPanel_StatusMemberListItem = {"container": mainWindow_UserListPanel, "type": "StatusMemberListItem", "unnamed": 1, "visible": True}
