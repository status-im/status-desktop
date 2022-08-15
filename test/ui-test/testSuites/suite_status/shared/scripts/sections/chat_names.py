
from sections.global_names import *

# Main Window - chat related:
mainWindow_public_chat_icon_StatusIcon = {"container": statusDesktop_mainWindow, "objectName": "public-chat-icon", "source": "qrc:/StatusQ/src/assets/img/icons/public-chat.svg", "type": "StatusIcon", "visible": True}
chatList_Repeater = {"container": statusDesktop_mainWindow, "objectName": "chatListItems", "type": "Repeater"}
mainWindow_startChat = {"checkable": True, "container": statusDesktop_mainWindow, "objectName": "startChatButton", "type": "StatusIconTabButton"}
join_public_chat_StatusMenuItemDelegate = {"checkable": False, "container": statusDesktop_mainWindow_overlay, "enabled": True, "text": "Join public chat", "type": "StatusMenuItemDelegate", "unnamed": 1, "visible": True}
mainWindow_statusIcon_StatusIcon_2 = {"container": statusDesktop_mainWindow, "id": "statusIcon", "source": "qrc:/StatusQ/src/assets/img/icons/public-chat.svg", "type": "StatusIcon", "unnamed": 1, "visible": True}

# Chat view:
chatView_StatusChatInfoButton = {"container": statusDesktop_mainWindow, "objectName": "chatInfoBtnInHeader", "type": "StatusChatInfoButton"}
mainWindow_scrollView_ScrollView = {"container": statusDesktop_mainWindow, "id": "scrollView", "type": "StatusScrollView", "unnamed": 1, "visible": True}
chatView_messageInput = {"container": statusDesktop_mainWindow, "objectName": "messageInputField", "type": "TextArea", "visible": True}
chatView_chatLogView_lastMsg_MessageView = {"container": chatView_log, "index": 0, "type": "MessageView"}
chatView_lastChatText_Text = {"container": chatView_chatLogView_lastMsg_MessageView, "objectName": "chatText", "type": "StyledTextEdit"}
chatView_replyToMessageButton = {"container": chatView_log, "objectName": "replyToMessageButton", "type": "StatusFlatRoundButton"}
chatView_DeleteMessageButton = {"container": chatView_log, "objectName": "chatDeleteMessageButton", "type": "StatusFlatRoundButton"}
chatButtonsPanelConfirmDeleteMessageButton_StatusButton = {"container": statusDesktop_mainWindow_overlay, "objectName": "chatButtonsPanelConfirmDeleteMessageButton", "type": "StatusButton"}
mark_as_Read_StatusMenuItemDelegate = {"container": statusDesktop_mainWindow_overlay, "objectName": "chatMarkAsReadMenuItem", "type": "StatusMenuItemDelegate", "visible": True}
chatView_SuggestionBoxPanel ={"container": statusDesktop_mainWindow, "objectName": "suggestionsBox", "type": "SuggestionBoxPanel"}
chatView_suggestion_ListView ={"container": chatView_SuggestionBoxPanel, "objectName": "suggestionBoxList", "type": "StatusListView"}
chatView_userMentioned_ProfileView ={"container": statusDesktop_mainWindow_overlay, "objectName": "profileView", "type": "ProfileView"}
# This will conflict with Jo's PR. Resolve it  on rebase.
emojiPopup_Emoji_Button_Placeholder = {"container": statusDesktop_mainWindow, "objectName": "statusEmoji_%NAME%", "type": "StatusEmoji", "visible": True}

# Join chat popup:
startChat_Btn = {"container": statusDesktop_mainWindow_overlay, "objectName": "startChatButton", "type": "StatusButton"}
joinPublicChat_input = {"container": statusDesktop_mainWindow_overlay, "objectName": "joinPublicChannelInput", "type": "TextEdit", "visible": True}
chat_name_PlaceholderText = {"container": statusDesktop_mainWindow_overlay, "text": "chat-name", "type": "PlaceholderText", "unnamed": 1, "visible": True}

# Create chat view:
createChatView_contactsList = {"container": statusDesktop_mainWindow, "objectName": "tagSelectorUserList", "type": "ListView"}
createChatView_confirmBtn = {"container": statusDesktop_mainWindow, "objectName": "createChatConfirmButton", "type": "StatusButton"}

## Members panel:
chatView_chatMembers_ListView = {"container": statusDesktop_mainWindow, "objectName": "userListPanel", "type": "ListView"}
