from gui.objects_map.names import statusDesktop_mainWindow

# Map for messaging screens, views locators

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
statusToolBar_Confirm_StatusButton = {"checkable": False, "container": mainWindow_statusToolBar_StatusToolBar, "objectName": "inlineSelectorConfirmButton", "type": "StatusButton", "visible": True}
statusToolBar_Cancel_StatusButton = {"checkable": False, "container": mainWindow_statusToolBar_StatusToolBar, "type": "StatusButton", "unnamed": 1, "visible": True}
statusToolBar_StatusTagItem = {"container": mainWindow_statusToolBar_StatusToolBar, "type": "StatusTagItem", "visible": True}

# Chat View
mainWindow_ChatColumnView = {"container": mainWindow_chatView_ChatView, "type": "ChatColumnView", "unnamed": 1, "visible": True}
mainWindow_chatLogView_StatusListView = {"container": mainWindow_ChatColumnView, "objectName": "chatLogView", "type": "StatusListView", "visible": True}
chatLogView_chatMessageViewDelegate_MessageView = {"container": mainWindow_chatLogView_StatusListView, "objectName": "chatMessageViewDelegate", "type": "MessageView", "visible": True, "enabled": True}

# Create Chat View
mainWindow_CreateChatView = {"container": statusDesktop_mainWindow, "type": "CreateChatView", "unnamed": 1, "visible": True}
createChatView_confirmBtn = {"container": statusDesktop_mainWindow, "objectName": "inlineSelectorConfirmButton", "type": "StatusButton"}
createChatView_contactsList = {"container": statusDesktop_mainWindow, "objectName": "createChatContactsList", "type": "StatusListView", "visible": True}
mainWindow_Cancel_StatusButton = {"checkable": False, "container": statusDesktop_mainWindow, "text": "Cancel", "type": "StatusButton", "unnamed": 1, "visible": True}

# Chat Messages View
mainWindow_ChatMessagesView = {"container": statusDesktop_mainWindow, "type": "ChatMessagesView", "unnamed": 1, "visible": True}
chatView_log = {"container": statusDesktop_mainWindow, "objectName": "chatLogView", "type": "StatusListView", "visible": True}
groupchatLogView_chatMessageViewDelegate_MessageView = {"container": chatView_log, "objectName": "chatMessageViewDelegate", "type": "MessageView", "visible": True}
groupMessagesItem = {"container": groupchatLogView_chatMessageViewDelegate_MessageView, "type": "StatusBaseText", "unnamed": 1, "visible": True}
chatMessageViewDelegate_ChannelIdentifierView = {"container": chatLogView_chatMessageViewDelegate_MessageView, "type": "ChannelIdentifierView", "unnamed": 1, "visible": True}
chatLogView_Item = {"container": chatView_log, "type": "Item", "unnamed": 1, "visible": True}
statusChatInfoButton = {"container": mainWindow_statusToolBar_StatusToolBar, "objectName": "statusChatInfoButtonNameText", "type": "TruncatedTextWithTooltip", "visible": True}
moreOptionsButton_StatusFlatRoundButton = {"container": mainWindow_statusToolBar_StatusToolBar, "objectName": "chatToolbarMoreOptionsButton", "type": "StatusFlatRoundButton", "visible": True}
mainWindow_Overlay = {"container": statusDesktop_mainWindow, "type": "Overlay", "unnamed": 1, "visible": True}
edit_name_and_image_StatusMenuItem = {"checkable": False, "container": mainWindow_Overlay, "enabled": True, "objectName": "editNameAndImageMenuItem", "text": "Edit name and image", "type": "StatusMenuItem", "visible": True}
leave_group_StatusMenuItem = {"checkable": False, "container": mainWindow_Overlay, "enabled": True, "objectName": "deleteOrLeaveMenuItem", "text": "Leave group", "type": "StatusMenuItem", "visible": True}
mainWindow_inputScrollView_StatusScrollView = {"container": statusDesktop_mainWindow, "id": "inputScrollView", "type": "StatusScrollView", "unnamed": 1, "visible": True}
inputScrollView_Message_PlaceholderText = {"container": mainWindow_inputScrollView_StatusScrollView, "text": "Message", "type": "PlaceholderText", "unnamed": 1, "visible": True}
mainWindow_scrollView_StatusScrollView = {"container": statusDesktop_mainWindow, "id": "scrollView", "type": "StatusScrollView", "unnamed": 1, "visible": True}
scrollView_StatusChatListItem = {"container": mainWindow_scrollView_StatusScrollView, "type": "StatusChatListItem", "visible": True}
tiny_pin_icon_StatusIcon = {"container": chatLogView_chatMessageViewDelegate_MessageView, "objectName": "tiny/pin-icon", "type": "StatusIcon"}
add_remove_from_group_StatusMenuItem = {"checkable": False, "container": mainWindow_Overlay, "enabled": True, "type": "StatusMenuItem", "unnamed": 1, "visible": True}
mainWindow_inputScrollView_StatusScrollView = {"container": statusDesktop_mainWindow, "id": "inputScrollView", "type": "StatusScrollView", "unnamed": 1, "visible": True}
inputScrollView_messageInputField_TextArea = {"container": mainWindow_inputScrollView_StatusScrollView, "objectName": "messageInputField", "type": "TextArea", "visible": True}

# User List Panel
mainWindow_UserListPanel = {"container": mainWindow_chatView_ChatView, "type": "UserListPanel", "unnamed": 1, "visible": True}
userListPanel_StatusMemberListItem = {"container": mainWindow_UserListPanel, "type": "StatusMemberListItem", "unnamed": 1, "visible": True}

# Group chat users list panel
mainWindow_userListPanel_StatusListView = {"container": statusDesktop_mainWindow, "objectName": "userListPanel", "type": "StatusListView", "visible": True}
groupUserListPanel_StatusMemberListItem = {"container": mainWindow_userListPanel_StatusListView, "type": "StatusMemberListItem", "unnamed": 1, "visible": True}

# Message quick actions
mainWindow_chatLogView_StatusListView = {"container":  statusDesktop_mainWindow, "objectName": "chatLogView", "type": "StatusListView", "visible": True}
chatLogView_chatMessageViewDelegate_MessageView = {"container": mainWindow_chatLogView_StatusListView, "index": 0, "objectName": "chatMessageViewDelegate", "type": "MessageView", "visible": True}
chatMessageViewDelegate_StatusMessageQuickActions = {"container": chatLogView_chatMessageViewDelegate_MessageView, "type": "StatusMessageQuickActions", "unnamed": 1, "visible": True}
chatMessageViewDelegate_MessageView_toggleMessagePin_StatusFlatRoundButton = {"container": chatLogView_chatMessageViewDelegate_MessageView, "objectName": "MessageView_toggleMessagePin", "type": "StatusFlatRoundButton", "visible": True}
chatMessageViewDelegate_replyToMessageButton_StatusFlatRoundButton = {"container": chatLogView_chatMessageViewDelegate_MessageView, "objectName": "replyToMessageButton", "type": "StatusFlatRoundButton", "visible": True}
chatMessageViewDelegate_editMessageButton_StatusFlatRoundButton = {"container": chatLogView_chatMessageViewDelegate_MessageView, "objectName": "editMessageButton", "type": "StatusFlatRoundButton", "visible": True}
chatMessageViewDelegate_markAsUnreadButton_StatusFlatRoundButton = {"container": chatLogView_chatMessageViewDelegate_MessageView, "objectName": "markAsUnreadButton", "type": "StatusFlatRoundButton", "visible": True}
chatMessageViewDelegate_chatDeleteMessageButton_StatusFlatRoundButton = {"container": chatLogView_chatMessageViewDelegate_MessageView, "objectName": "chatDeleteMessageButton", "type": "StatusFlatRoundButton", "visible": True}
