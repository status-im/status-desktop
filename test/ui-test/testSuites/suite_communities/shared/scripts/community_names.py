from scripts.global_names import *

# Main:
mainWindow_communityColumnView_CommunityColumnView = {"container": statusDesktop_mainWindow, "objectName": "communityColumnView", "type": "CommunityColumnView"}
mainWindow_communityHeader_StatusChatInfoButton = {"container": statusDesktop_mainWindow, "objectName": "communityHeaderButton", "type": "StatusChatInfoButton", "visible": True}
community_ChatInfo_Name_Text = {"container": mainWindow_communityHeader_StatusChatInfoButton, "objectName": "statusChatInfoButtonNameText", "type": "StatusBaseText", "visible": True}
mainWindow_createChannelOrCategoryBtn_StatusBaseText = {"container": statusDesktop_mainWindow, "objectName": "createChannelOrCategoryBtn", "type": "StatusBaseText", "visible": True}
create_channel_StatusMenuItemDelegate = {"container": statusDesktop_mainWindow_overlay, "enabled": True, "objectName": "createCommunityChannelBtn", "type": "StatusMenuItemDelegate", "visible": True}
create_category_StatusMenuItemDelegate = {"container": statusDesktop_mainWindow_overlay, "enabled": True, "objectName": "createCommunityCategoryBtn", "type": "StatusMenuItemDelegate", "visible": True}
edit_сategory_StatusMenuItemDelegate = {"container": statusDesktop_mainWindow_overlay, "enabled": True, "objectName": "editCategoryMenuItem", "type": "StatusMenuItemDelegate", "visible": True}
delete_сategory_StatusMenuItemDelegate = {"container": statusDesktop_mainWindow_overlay, "enabled": True, "objectName": "deleteCategoryMenuItem", "type": "StatusMenuItemDelegate", "visible": True}
confirmDeleteCategoryButton_StatusButton = {"container": statusDesktop_mainWindow, "objectName": "confirmDeleteCategoryButton", "type": "StatusButton"}
chat_moreOptions_menuButton = {"container": statusDesktop_mainWindow, "objectName": "chatToolbarMoreOptionsButton", "type": "StatusFlatRoundButton", "visible": True}
edit_Channel_StatusMenuItemDelegate = {"container": statusDesktop_mainWindow_overlay, "enabled": True, "objectName": "editChannelMenuItem", "type": "StatusMenuItemDelegate", "visible": True}
msgDelegate_channelIdentifierNameText_StyledText = {"container": chatMessageListView_msgDelegate_MessageView, "objectName": "channelIdentifierNameText", "type": "StyledText", "visible": True}
delete_Channel_StatusMenuItemDelegate = {"container": statusDesktop_mainWindow_overlay, "enabled": True, "objectName": "deleteOrLeaveMenuItem", "type": "StatusMenuItemDelegate", "visible": True}
mainWindow_communityColumnView_statusChatList = {"container": mainWindow_communityColumnView_CommunityColumnView, "objectName": "statusChatListAndCategoriesChatList", "type": "StatusChatList"}
delete_Channel_ConfirmationDialog_DeleteButton = {"container": statusDesktop_mainWindow_overlay, "objectName": "deleteChatConfirmationDialogDeleteButton", "type": "StatusButton"}
mainWindow_chatInfoBtnInHeader_StatusChatInfoButton = {"container": statusDesktop_mainWindow, "objectName": "chatInfoBtnInHeader", "type": "StatusChatInfoButton", "visible": True}
communityChatListCategories_Repeater = {"container": statusDesktop_mainWindow, "objectName": "communityChatListCategories", "type": "Repeater"}
chatInput_Root = {"container": statusDesktop_mainWindow, "objectName": "statusChatInput", "type": "Rectangle", "visible": True}

# Community channel popup:
createOrEditCommunityChannelNameInput_TextEdit = {"container": statusDesktop_mainWindow_overlay, "objectName": "createOrEditCommunityChannelNameInput", "type": "TextEdit", "visible": True}
createOrEditCommunityChannelDescriptionInput_TextEdit = {"container": statusDesktop_mainWindow_overlay, "objectName": "createOrEditCommunityChannelDescriptionInput", "type": "TextEdit", "visible": True}
createOrEditCommunityChannelBtn_StatusButton = {"container": statusDesktop_mainWindow_overlay, "objectName": "createOrEditCommunityChannelBtn", "type": "StatusButton", "visible": True}
createOrEditCommunityChannel_EmojiButton = {"container": statusDesktop_mainWindow_overlay, "objectName": "StatusChannelPopup_emojiButton", "type": "StatusRoundButton", "visible": True}

# Community category popup:
createOrEditCommunityCategoryNameInput_TextEdit = {"container": statusDesktop_mainWindow_overlay, "objectName": "createOrEditCommunityCategoryNameInput", "type": "TextEdit", "visible": True}
createOrEditCommunityCategoryChannelList_ListView = {"container": statusDesktop_mainWindow_overlay, "objectName": "createOrEditCommunityCategoryChannelList", "type": "StatusListView", "visible": True}
createOrEditCommunityCategoryBtn_StatusButton = {"container": statusDesktop_mainWindow_overlay, "objectName": "createOrEditCommunityCategoryBtn", "type": "StatusButton", "visible": True}

# Community settings
communitySettings_EditCommunity_Button = {"container": statusDesktop_mainWindow, "objectName": "communityOverviewSettingsEditCommunityButton", "type": "StatusButton"}
communitySettings_BackToCommunity_Button = {"container": statusDesktop_mainWindow, "objectName": "communitySettingsBackToCommunityButton", "type": "StatusBaseText", "visible": True}
communitySettings_CommunityName_Text = {"container": statusDesktop_mainWindow, "objectName": "communityOverviewSettingsCommunityName", "type": "StatusBaseText", "visible": True}
communitySettings_CommunityDescription_Text = {"container": statusDesktop_mainWindow, "objectName": "communityOverviewSettingsCommunityDescription", "type": "StatusBaseText", "visible": True}
communitySettings_Community_Identicon = {"container": statusDesktop_mainWindow, "objectName": "communityOverviewSettingsPanelIdenticon", "type": "StatusSmartIdenticon", "visible": True}
communitySettings_Community_LetterIdenticon = {"container": communitySettings_Community_Identicon, "objectName": "statusSmartIdenticonLetter", "type": "StatusLetterIdenticon", "visible": True}

# Community Edit:
communitySettings_EditCommunity_ScrollView = {"container": statusDesktop_mainWindow, "objectName": "communityEditPanelScrollView", "type": "StatusScrollView", "visible": True}
communitySettings_EditCommunity_Name_Input = {"container": communitySettings_EditCommunity_ScrollView, "objectName": "editCommunityNameInput", "type": "TextEdit"}
communitySettings_EditCommunity_Description_Input = {"container": communitySettings_EditCommunity_ScrollView, "objectName": "editCommunityDescriptionInput", "type": "TextEdit"}
communitySettings_EditCommunity_ColorPicker_Button = {"container": communitySettings_EditCommunity_ScrollView, "objectName": "editCommunityColorPicker", "type": "CommunityColorPicker"}

# Community color popup:
communitySettings_ColorPanel_HexColor_Input = {"container": statusDesktop_mainWindow_overlay, "objectName": "communityColorPanelHexInput", "type": "TextEdit"}
communitySettings_SaveColor_Button = {"container": statusDesktop_mainWindow_overlay, "objectName": "communityColorPanelSelectColorButton", "type": "StatusButton", "visible": True}
