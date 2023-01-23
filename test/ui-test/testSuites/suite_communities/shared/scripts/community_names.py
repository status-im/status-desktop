from scripts.global_names import *

# Main:
mainWindow_communityColumnView_CommunityColumnView = {"container": statusDesktop_mainWindow, "objectName": "communityColumnView", "type": "CommunityColumnView"}
mainWindow_communityHeader_StatusChatInfoButton = {"container": statusDesktop_mainWindow, "objectName": "communityHeaderButton", "type": "StatusChatInfoButton", "visible": True}
community_ChatInfo_Name_Text = {"container": mainWindow_communityHeader_StatusChatInfoButton, "objectName": "statusChatInfoButtonNameText", "type": "StatusBaseText", "visible": True}
mainWindow_createChannelOrCategoryBtn_StatusBaseText = {"container": statusDesktop_mainWindow, "objectName": "createChannelOrCategoryBtn", "type": "StatusBaseText", "visible": True}
create_channel_StatusMenuItem = {"container": statusDesktop_mainWindow_overlay, "enabled": True, "objectName": "createCommunityChannelBtn", "type": "StatusMenuItem", "visible": True}
create_category_StatusMenuItem = {"container": statusDesktop_mainWindow_overlay, "enabled": True, "objectName": "createCommunityCategoryBtn", "type": "StatusMenuItem", "visible": True}
edit_сategory_StatusMenuItem = {"container": statusDesktop_mainWindow_overlay, "enabled": True, "objectName": "editCategoryMenuItem", "type": "StatusMenuItem", "visible": True}
delete_сategory_StatusMenuItem = {"container": statusDesktop_mainWindow_overlay, "enabled": True, "objectName": "deleteCategoryMenuItem", "type": "StatusMenuItem", "visible": True}
confirmDeleteCategoryButton_StatusButton = {"container": statusDesktop_mainWindow, "objectName": "confirmDeleteCategoryButton", "type": "StatusButton"}
chat_moreOptions_menuButton = {"container": statusDesktop_mainWindow, "objectName": "chatToolbarMoreOptionsButton", "type": "StatusFlatRoundButton", "visible": True}
edit_Channel_StatusMenuItem = {"container": statusDesktop_mainWindow_overlay, "enabled": True, "objectName": "editChannelMenuItem", "type": "StatusMenuItem", "visible": True}
delete_Channel_StatusMenuItem = {"container": statusDesktop_mainWindow_overlay, "enabled": True, "objectName": "deleteOrLeaveMenuItem", "type": "StatusMenuItem", "visible": True}
mainWindow_communityColumnView_statusChatList = {"container": mainWindow_communityColumnView_CommunityColumnView, "objectName": "statusChatListAndCategoriesChatList", "type": "StatusChatList"}
mainWindow_chatInfoBtnInHeader_StatusChatInfoButton = {"container": statusDesktop_mainWindow, "objectName": "chatInfoBtnInHeader", "type": "StatusChatInfoButton", "visible": True}
communityChatListCategories_Repeater = {"container": statusDesktop_mainWindow, "objectName": "communityChatListCategories", "type": "Repeater"}
chatInput_Root = {"container": statusDesktop_mainWindow, "objectName": "statusChatInput", "type": "Rectangle", "visible": True}
emojiPopup_Emoji_Button_Placeholder = {"container": statusDesktop_mainWindow, "objectName": "statusEmoji_%NAME%", "type": "StatusEmoji", "visible": True}
community_AddMembers_Button = {"container": statusDesktop_mainWindow, "objectName": "CommunityWelcomeBannerPanel_AddMembersButton", "type": "StatusButton", "visible": True}
community_InviteFirends_Popup_InvitePanel = {"container": statusDesktop_mainWindow_overlay, "objectName": "CommunityProfilePopupInviteFrindsPanel_ColumnLayout", "type": "ColumnLayout", "visible": True}
community_InviteFirends_Popup_ExistinContacts_ListView = {"container": community_InviteFirends_Popup_InvitePanel, "objectName": "ExistingContacts_ListView", "type": "StatusListView", "visible": True}
community_InviteFriendsToCommunityPopup_NextButton = {"container": statusDesktop_mainWindow_overlay, "objectName": "InviteFriendsToCommunityPopup_NextButton", "type": "StatusButton", "visible": True}
community_InviteFriends_Popup_MessagePanel = {"container": statusDesktop_mainWindow_overlay, "objectName": "CommunityProfilePopupInviteMessagePanel_ColumnLayout", "type": "ColumnLayout", "visible": True}
community_ProfilePopupInviteMessagePanel_MessageInput = {"container": community_InviteFriends_Popup_MessagePanel, "objectName": "CommunityProfilePopupInviteMessagePanel_MessageInput", "type": "TextEdit", "visible": True}
community_InviteFriend_SendButton = {"container": statusDesktop_mainWindow_overlay, "objectName": "InviteFriendsToCommunityPopup_SendButton", "type": "StatusButton", "visible": True}
communitySettings_Members_NavigationListItem = {"container": statusDesktop_mainWindow, "objectName": "CommunitySettingsView_NavigationListItem_Members", "type": "StatusNavigationListItem", "visible": True}
communitySettings_MembersTab_Members_ListView = {"container": statusDesktop_mainWindow, "objectName": "CommunityMembersTabPanel_MembersListViews", "type": "ListView", "visible": True}
communitySettings_MembersTab_Member_Kick_Button = {"container": communitySettings_MembersTab_Members_ListView, "objectName": "MemberListIten_KickButton", "type": "StatusButton", "visible": True}
communitySettings_KickModal_Kick_Button = {"container": statusDesktop_mainWindow_overlay, "objectName": "CommunityMembers_KickModal_KickButton", "type": "StatusButton", "visible": True}

# Chat components
chatView_TogglePinMessageButton = {"container": chatView_log, "objectName": "MessageView_toggleMessagePin", "type": "StatusFlatRoundButton", "visible": True}
chatView_ReplyToMessageButton = {"container": chatView_log, "objectName": "replyToMessageButton", "type": "StatusFlatRoundButton", "visible": True}
chatView_editMessageInputComponent = {"container": statusDesktop_mainWindow, "objectName": "editMessageInput", "type": "StatusChatInput", "visible": True}
chatView_editMessageInputTextArea = {"container": chatView_editMessageInputComponent, "objectName": "messageInputField", "type": "TextArea", "visible": True}
clearHistoryMenuItem = {"container": statusDesktop_mainWindow_overlay, "objectName": "clearHistoryMenuItem", "type": "StatusMenuItem", "visible": True}
chatView_unfurledImageComponent_linkImage = {"container": chatView_log, "objectName": "LinksMessageView_unfurledImageComponent_linkImage", "type": "StatusChatImageLoader",  "visible": True}
emojiSuggestions_first_inputListRectangle ={"container": statusDesktop_mainWindow_overlay, "objectName": "inputListRectangle_0", "type": "Rectangle"}

# Community channel popup:
createOrEditCommunityChannelNameInput_TextEdit = {"container": statusDesktop_mainWindow_overlay, "objectName": "createOrEditCommunityChannelNameInput", "type": "TextEdit", "visible": True}
createOrEditCommunityChannelDescriptionInput_TextEdit = {"container": statusDesktop_mainWindow_overlay, "objectName": "createOrEditCommunityChannelDescriptionInput", "type": "TextEdit", "visible": True}
createOrEditCommunityChannelBtn_StatusButton = {"container": statusDesktop_mainWindow_overlay, "objectName": "createOrEditCommunityChannelBtn", "type": "StatusButton", "visible": True}
createOrEditCommunityChannel_EmojiButton = {"container": statusDesktop_mainWindow_overlay, "objectName": "StatusChannelPopup_emojiButton", "type": "StatusRoundButton", "visible": True}
createOrEditCommunityChannel_Emoji_Button_Placeholder = {"container": statusDesktop_mainWindow, "objectName": "statusEmoji_%NAME%", "type": "StatusEmoji", "visible": True}

# Community category popup:
createOrEditCommunityCategoryNameInput_TextEdit = {"container": statusDesktop_mainWindow_overlay, "objectName": "createOrEditCommunityCategoryNameInput", "type": "TextEdit", "visible": True}
createOrEditCommunityCategoryChannelList_ListView = {"container": statusDesktop_mainWindow_overlay, "objectName": "createOrEditCommunityCategoryChannelList", "type": "StatusListView", "visible": True}
createOrEditCommunityCategoryChannelList_ListItem_Placeholder = {"container": createOrEditCommunityCategoryChannelList_ListView, "objectName": "%NAME%", "type": "StatusListItem", "visible": True}
createOrEditCommunityCategoryBtn_StatusButton = {"container": statusDesktop_mainWindow_overlay, "objectName": "createOrEditCommunityCategoryBtn", "type": "StatusButton", "visible": True}

# Community settings
communitySettings_EditCommunity_Button = {"container": statusDesktop_mainWindow, "objectName": "communityOverviewSettingsEditCommunityButton", "type": "StatusButton", "visible": True}
communitySettings_BackToCommunity_Button = {"container": statusDesktop_mainWindow, "objectName": "communitySettingsBackToCommunityButton", "type": "StatusBaseText", "visible": True}
communitySettings_CommunityName_Text = {"container": statusDesktop_mainWindow, "objectName": "communityOverviewSettingsCommunityName", "type": "StatusBaseText", "visible": True}
communitySettings_CommunityDescription_Text = {"container": statusDesktop_mainWindow, "objectName": "communityOverviewSettingsCommunityDescription", "type": "StatusBaseText", "visible": True}
communitySettings_Community_Identicon = {"container": statusDesktop_mainWindow, "objectName": "communityOverviewSettingsPanelIdenticon", "type": "StatusSmartIdenticon", "visible": True}
communitySettings_Community_LetterIdenticon = {"container": communitySettings_Community_Identicon, "objectName": "statusSmartIdenticonLetter", "type": "StatusLetterIdenticon", "visible": True}

# Community Edit:
communitySettings_EditCommunity_ScrollView = {"container": statusDesktop_mainWindow, "objectName": "communityEditPanelScrollView", "type": "StatusScrollView", "visible": True}
communitySettings_EditCommunity_Name_Input = {"container": communitySettings_EditCommunity_ScrollView, "objectName": "editCommunityNameInput", "type": "TextEdit",  "visible": True}
communitySettings_EditCommunity_Description_Input = {"container": communitySettings_EditCommunity_ScrollView, "objectName": "editCommunityDescriptionInput", "type": "TextEdit",  "visible": True}
communitySettings_EditCommunity_ColorPicker_Button = {"container": communitySettings_EditCommunity_ScrollView, "objectName": "editCommunityColorPicker", "type": "CommunityColorPicker", "visible": True}

# Community color popup:
communitySettings_ColorPanel_HexColor_Input = {"container": statusDesktop_mainWindow_overlay, "objectName": "communityColorPanelHexInput", "type": "TextEdit",  "visible": True}
communitySettings_SaveColor_Button = {"container": statusDesktop_mainWindow_overlay, "objectName": "communityColorPanelSelectColorButton", "type": "StatusButton", "visible": True}
