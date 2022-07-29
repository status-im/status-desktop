
from sections.global_names import *

# Main:
mainWindow_communityColumnView_CommunityColumnView = {"container": statusDesktop_mainWindow, "objectName": "communityColumnView", "type": "CommunityColumnView"}
mainWindow_communityHeader_StatusChatInfoButton = {"container": statusDesktop_mainWindow, "objectName": "communityHeaderButton", "type": "StatusChatInfoButton", "visible": True}
community_ChatInfo_Name_Text = {"container": mainWindow_communityHeader_StatusChatInfoButton, "objectName": "statusChatInfoButtonNameText", "type": "StatusBaseText", "visible": True}
mainWindow_createChannelOrCategoryBtn_StatusBaseText = {"container": statusDesktop_mainWindow, "objectName": "createChannelOrCategoryBtn", "type": "StatusBaseText", "visible": True}
create_channel_StatusMenuItemDelegate = {"checkable": False, "container": statusDesktop_mainWindow_overlay, "enabled": True, "objectName": "createCommunityChannelBtn", "type": "StatusMenuItemDelegate", "visible": True}
create_category_StatusMenuItemDelegate = {"checkable": False, "container": statusDesktop_mainWindow_overlay, "enabled": True, "objectName": "createCommunityCategoryBtn", "type": "StatusMenuItemDelegate", "visible": True}
chat_moreOptions_menuButton = {"container": statusDesktop_mainWindow, "objectName": "chatToolbarMoreOptionsButton", "type": "StatusFlatRoundButton", "visible": True}
edit_Channel_StatusMenuItemDelegate = {"checkable": False, "container": statusDesktop_mainWindow_overlay, "enabled": True, "objectName": "editChannelMenuItem", "type": "StatusMenuItemDelegate", "visible": True}
msgDelegate_channelIdentifierNameText_StyledText = {"container": chatMessageListView_msgDelegate_MessageView, "objectName": "channelIdentifierNameText", "type": "StyledText", "visible": True}

# Community channel popup:
createOrEditCommunityChannelNameInput_TextEdit = {"container": statusDesktop_mainWindow_overlay, "objectName": "createOrEditCommunityChannelNameInput", "type": "TextEdit", "visible": True}
createOrEditCommunityChannelDescriptionInput_TextEdit = {"container": statusDesktop_mainWindow_overlay, "objectName": "createOrEditCommunityChannelDescriptionInput", "type": "TextEdit", "visible": True}
createOrEditCommunityChannelBtn_StatusButton = {"container": statusDesktop_mainWindow_overlay, "objectName": "createOrEditCommunityChannelBtn", "type": "StatusButton", "visible": True}
