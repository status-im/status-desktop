from scripts.global_names import *

# Chat view:
navBarListView_Chat_navbar_StatusNavBarTabButton = {"checkable": True, "container": mainWindow_navBarListView_ListView, "objectName": "Chat-navbar", "type": "StatusNavBarTabButton", "visible": True}
chatView_StatusChatInfoButton = {"container": statusDesktop_mainWindow, "objectName": "chatInfoBtnInHeader", "type": "StatusChatInfoButton", "visible": True}
mainWindow_scrollView_ScrollView = {"container": statusDesktop_mainWindow, "id": "scrollView", "type": "StatusScrollView", "unnamed": 1, "visible": True}
chatView_messageInput = {"container": statusDesktop_mainWindow, "objectName": "messageInputField", "type": "TextArea", "visible": True}
chatView_chatLogView_lastMsg_MessageView = {"container": chatView_log, "index": 0, "type": "MessageView"}
chatView_lastChatText_Text = {"container": chatView_chatLogView_lastMsg_MessageView, "type": "TextEdit", "objectName": "StatusTextMessage_chatText", "visible": True}
chatView_replyToMessageButton = {"container": chatView_log, "objectName": "replyToMessageButton", "type": "StatusFlatRoundButton"}
chatView_editMessageButton = {"container": chatView_log, "objectName": "editMessageButton", "type": "StatusFlatRoundButton"}
chatView_editMessageInputComponent = {"container": statusDesktop_mainWindow, "objectName": "editMessageInput", "type": "StatusChatInput", "visible": True}
chatView_editMessageInputTextArea = {"container": chatView_editMessageInputComponent, "objectName": "messageInputField", "type": "TextArea", "visible": True}
chatView_DeleteMessageButton = {"container": chatView_log, "objectName": "chatDeleteMessageButton", "type": "StatusFlatRoundButton"}
chatButtonsPanelConfirmDeleteMessageButton_StatusButton = {"container": statusDesktop_mainWindow_overlay, "objectName": "chatButtonsPanelConfirmDeleteMessageButton", "type": "StatusButton"}
mark_as_Read_StatusMenuItemDelegate = {"container": statusDesktop_mainWindow_overlay, "objectName": "chatMarkAsReadMenuItem", "type": "StatusMenuItemDelegate", "visible": True}
chatView_SuggestionBoxPanel ={"container": statusDesktop_mainWindow, "objectName": "suggestionsBox", "type": "SuggestionBoxPanel"}
chatView_suggestion_ListView ={"container": chatView_SuggestionBoxPanel, "objectName": "suggestionBoxList", "type": "StatusListView"}
chatView_userMentioned_ProfileView ={"container": statusDesktop_mainWindow_overlay, "objectName": "profileView", "type": "ProfileView"}
emojiSuggestions_first_inputListRectangle ={"container": statusDesktop_mainWindow_overlay, "objectName": "inputListRectangle_0", "type": "Rectangle"}
emojiPopup_Emoji_Button_Placeholder = {"container": statusDesktop_mainWindow, "objectName": "statusEmoji_%NAME%", "type": "StatusEmoji", "visible": True}
chatInput_Emoji_Button = {"container": statusDesktop_mainWindow, "objectName": "statusChatInputEmojiButton", "type": "StatusFlatRoundButton", "visible": True}
chatView_ChatToolbarMoreOptionsButton = {"container": statusDesktop_mainWindow, "objectName": "chatToolbarMoreOptionsButton", "type": "StatusFlatRoundButton"}
chatInput_Root = {"container": statusDesktop_mainWindow, "objectName": "statusChatInput", "type": "Rectangle", "visible": True}
chatView_gifPopupButton = {"container": statusDesktop_mainWindow, "objectName": "gifPopupButton", "type": "StatusFlatRoundButton", "visible": True}

# More options menu
clearHistoryMenuItem = {"container": statusDesktop_mainWindow_overlay, "objectName": "clearHistoryMenuItem", "type": "StatusMenuItemDelegate", "visible": True}

# Gif popup:
gifPopup_enableGifButton = {"container": statusDesktop_mainWindow_overlay, "objectName": "enableGifsButton", "type": "StatusButton"}
gifPopup_gifMouseArea = {"container": statusDesktop_mainWindow_overlay, "objectName": "gifMouseArea_1", "type": "MouseArea"}

# Join chat popup:
startChat_Btn = {"container": statusDesktop_mainWindow_overlay, "objectName": "startChatButton", "type": "StatusButton"}
joinPublicChat_input = {"container": statusDesktop_mainWindow_overlay, "objectName": "joinPublicChannelInput", "type": "TextEdit", "visible": True}
chat_name_PlaceholderText = {"container": statusDesktop_mainWindow_overlay, "text": "chat-name", "type": "PlaceholderText", "unnamed": 1, "visible": True}

# Create chat view:
createChatView_contactsList = {"container": statusDesktop_mainWindow, "objectName": "tagSelectorUserList", "type": "ListView"}
createChatView_confirmBtn = {"container": statusDesktop_mainWindow, "objectName": "createChatConfirmButton", "type": "StatusButton"}

## Members panel:
chatView_chatMembers_ListView = {"container": statusDesktop_mainWindow, "objectName": "userListPanel", "type": "ListView"}
