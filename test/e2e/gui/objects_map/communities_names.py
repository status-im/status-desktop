from gui.objects_map.names import statusDesktop_mainWindow, statusDesktop_mainWindow_overlay, mainWindow_StatusWindow

# Map for communities screens, views locators

# Community Portal
mainWindow_communitiesPortalLayout_CommunitiesPortalLayout = {"container": statusDesktop_mainWindow, "objectName": "communitiesPortalLayout", "type": "CommunitiesPortalLayout", "visible": True}
mainWindow_Create_New_Community_StatusButton = {"checkable": False, "container": mainWindow_communitiesPortalLayout_CommunitiesPortalLayout, "objectName": "createCommunityButton", "type": "StatusButton", "visible": True}

# Community View
mainWindow_communityLoader_Loader = {"container": statusDesktop_mainWindow, "objectName": "StatusSectionLayout", "type": "ContentItem", "visible": True}
# Left Panel
mainWindow_communityColumnView_CommunityColumnView = {"container": mainWindow_communityLoader_Loader, "objectName": "communityColumnView", "type": "CommunityColumnView", "visible": True}
mainWindow_communityHeaderButton_StatusChatInfoButton = {"checkable": False, "container": mainWindow_communityColumnView_CommunityColumnView, "objectName": "communityHeaderButton", "type": "StatusChatInfoButton", "visible": True}
mainWindow_identicon_StatusSmartIdenticon = {"container": mainWindow_communityHeaderButton_StatusChatInfoButton, "id": "identicon", "type": "StatusSmartIdenticon", "unnamed": 1, "visible": True}
mainWindow_statusChatInfoButtonNameText_TruncatedTextWithTooltip = {"container": mainWindow_communityHeaderButton_StatusChatInfoButton, "objectName": "statusChatInfoButtonNameText", "type": "TruncatedTextWithTooltip", "visible": True}
mainWindow_Members_TruncatedTextWithTooltip = {"container": mainWindow_communityHeaderButton_StatusChatInfoButton, "type": "TruncatedTextWithTooltip", "unnamed": 1, "visible": True}
mainWindow_startChatButton_StatusIconTabButton = {"checkable": True, "container": mainWindow_communityColumnView_CommunityColumnView, "objectName": "startChatButton", "type": "StatusIconTabButton", "visible": True}
mainWindow_createChatOrCommunity_Loader = {"container": mainWindow_communityColumnView_CommunityColumnView, "id": "createChatOrCommunity", "type": "Loader", "unnamed": 1, "visible": True}
mainWindow_scrollView_StatusScrollView = {"container": mainWindow_communityColumnView_CommunityColumnView, "id": "scrollView", "type": "StatusScrollView", "unnamed": 1, "visible": True}
scrollView_Flickable = {"container": mainWindow_scrollView_StatusScrollView, "type": "Flickable", "unnamed": 1, "visible": True}
scrollView_chatListItems_StatusListView = {"container": scrollView_Flickable, "objectName": "chatListItems", "type": "StatusListView", "visible": True}
channel_listItem = {"container": scrollView_chatListItems_StatusListView, "id": "chatListDelegate", "type": "DropArea", "isCategory": False, "visible": True}
channel_identicon_StatusSmartIdenticon = {"container": None, "id": "identicon", "type": "StatusSmartIdenticon", "unnamed": 1, "visible": True}
channel_name_StatusBaseText = {"container": None, "type": "StatusBaseText", "unnamed": 1, "visible": True}
mainWindow_createChannelOrCategoryBtn_StatusBaseText = {"container": mainWindow_communityColumnView_CommunityColumnView, "objectName": "createChannelOrCategoryBtn", "type": "StatusBaseText", "visible": True}
create_channel_StatusMenuItem = {"container": statusDesktop_mainWindow_overlay, "enabled": True, "objectName": "createCommunityChannelBtn", "type": "StatusMenuItem", "visible": True}
mainWindow_Join_Community_StatusButton = {"checkable": False, "container": mainWindow_StatusWindow, "type": "StatusButton", "unnamed": 1, "visible": True}
add_categories_StatusFlatButton = {"checkable": False, "container": mainWindow_scrollView_StatusScrollView, "id": "manageBtn", "type": "StatusFlatButton", "visible": True}
categoryItem_StatusChatListCategoryItem = {"container": mainWindow_scrollView_StatusScrollView, "objectName": "categoryItem", "type": "StatusChatListCategoryItem", "visible": True}
delete_Category_StatusMenuItem = {"checkable": False, "container": statusDesktop_mainWindow_overlay, "enabled": True, "objectName": "deleteCategoryMenuItem", "type": "StatusMenuItem", "visible": True}
create_category_StatusMenuItem = {"checkable": False, "container": statusDesktop_mainWindow_overlay, "enabled": True, "objectName": "createCommunityCategoryBtn", "type": "StatusMenuItem", "visible": True}
edit_Category_StatusMenuItem = {"checkable": False, "container": statusDesktop_mainWindow_overlay, "enabled": True, "objectName": "editCategoryMenuItem", "type": "StatusMenuItem", "visible": True}
scrollView_menuButton_StatusChatListCategoryItemButton = {"container": mainWindow_scrollView_StatusScrollView, "id": "menuButton", "type": "StatusChatListCategoryItemButton", "unnamed": 1, "visible": True}
scrollView_toggleButton_StatusChatListCategoryItemButton = {"container": mainWindow_scrollView_StatusScrollView, "id": "toggleButton", "type": "StatusChatListCategoryItemButton", "unnamed": 1, "visible": True}
scrollView_addButton_StatusChatListCategoryItemButton = {"container": mainWindow_scrollView_StatusScrollView, "id": "addButton", "type": "StatusChatListCategoryItemButton", "unnamed": 1, "visible": True}
add_channels_StatusButton = {"checkable": False, "container": mainWindow_scrollView_StatusScrollView, "id": "addMembersBtn", "type": "StatusButton", "unnamed": 1, "visible": True}
scrollView_general_StatusChatListItem = {"container": mainWindow_scrollView_StatusScrollView, "objectName": "general", "type": "StatusChatListItem", "visible": True}
invite_People_StatusMenuItem = {"checkable": False, "container": statusDesktop_mainWindow_overlay, "enabled": True, "objectName": "invitePeople", "type": "StatusMenuItem", "visible": True}
mute_Community_StatusMenuItem = {"checkable": False, "container": statusDesktop_mainWindow_overlay, "enabled": True, "objectName": "StatusMenuItemDelegate", "type": "StatusMenuItem", "visible": True}

# Tool Bar
mainWindow_statusToolBar_StatusToolBar = {"container": mainWindow_StatusWindow, "objectName": "statusToolBar", "type": "StatusToolBar", "visible": True}
statusToolBar_chatToolbarMoreOptionsButton = {"container": mainWindow_statusToolBar_StatusToolBar, "objectName": "chatToolbarMoreOptionsButton", "type": "StatusFlatRoundButton", "visible": True}
delete_Channel_StatusMenuItem = {"checkable": False, "container": statusDesktop_mainWindow_overlay, "enabled": True, "objectName": "deleteOrLeaveMenuItem", "type": "StatusMenuItem", "visible": True}
edit_Channel_StatusMenuItem = {"checkable": False, "container": statusDesktop_mainWindow_overlay, "enabled": True, "objectName": "editChannelMenuItem", "type": "StatusMenuItem", "visible": True}
statusToolBar_statusSmartIdenticonLetter_StatusLetterIdenticon = {"container": mainWindow_statusToolBar_StatusToolBar, "objectName": "statusSmartIdenticonLetter", "type": "StatusLetterIdenticon", "visible": True}
statusToolBar_statusChatInfoButtonNameText_TruncatedTextWithTooltip = {"container": mainWindow_statusToolBar_StatusToolBar, "objectName": "statusChatInfoButtonNameText", "type": "TruncatedTextWithTooltip", "visible": True}
statusToolBar_TruncatedTextWithTooltip = {"container": mainWindow_statusToolBar_StatusToolBar, "type": "TruncatedTextWithTooltip", "unnamed": 1, "visible": True}
statusToolBar_chatInfoBtnInHeader_StatusChatInfoButton = {"checkable": False, "container": mainWindow_statusToolBar_StatusToolBar, "objectName": "chatInfoBtnInHeader", "type": "StatusChatInfoButton",  "visible": True}
statusToolBar_StatusChatInfo_pinText_TruncatedTextWithTooltip = {"container": mainWindow_statusToolBar_StatusToolBar, "objectName": "StatusChatInfo_pinText", "type": "TruncatedTextWithTooltip", "visible": True}

# Chat
mainWindow_ChatMessagesView = {"container": mainWindow_StatusWindow, "type": "ChatMessagesView", "unnamed": 1, "visible": True}
mainWindow_ChatColumnView = {"container": mainWindow_communityLoader_Loader, "type": "ChatColumnView", "unnamed": 1, "visible": True}
chatMessageViewDelegate_channelIdentifierNameText_StyledText = {"container": mainWindow_ChatColumnView, "objectName": "channelIdentifierNameText", "type": "StyledText", "visible": True}
chatMessageViewDelegate_Welcome = {"container": mainWindow_ChatColumnView, "type": "StatusBaseText", "unnamed": 1, "visible": True}
chatMessageViewDelegate_channelIdentifierSmartIdenticon_StatusSmartIdenticon = {"container": mainWindow_ChatMessagesView, "objectName": "channelIdentifierSmartIdenticon", "type": "StatusSmartIdenticon", "visible": True}
mainWindow_chatLogView_StatusListView = {"container": mainWindow_StatusWindow, "objectName": "chatLogView", "type": "StatusListView", "visible": True}
chatLogView_chatMessageViewDelegate_MessageView = {"container": mainWindow_chatLogView_StatusListView, "index": 0, "objectName": "chatMessageViewDelegate", "type": "MessageView", "visible": True}

# Community Settings
mainWindow_communitySettingsBackToCommunityButton_StatusBaseText = {"container": mainWindow_communityLoader_Loader, "objectName": "communitySettingsBackToCommunityButton", "type": "StatusBaseText", "visible": True}
mainWindow_listView_StatusListView = {"container": mainWindow_communityLoader_Loader, "id": "listView", "type": "StatusListView", "unnamed": 1, "visible": True}
overview_StatusNavigationListItem = {"container": mainWindow_listView_StatusListView, "objectName": "CommunitySettingsView_NavigationListItem_Overview", "type": "StatusNavigationListItem", "visible": True}
members_StatusNavigationListItem = {"container": mainWindow_listView_StatusListView, "index": 1, "objectName": "CommunitySettingsView_NavigationListItem_Members", "type": "StatusNavigationListItem", "visible": True}
permissions_StatusNavigationListItem = {"container": mainWindow_listView_StatusListView, "index": 2, "objectName": "CommunitySettingsView_NavigationListItem_Permissions", "type": "StatusNavigationListItem", "visible": True}
tokens_StatusNavigationListItem = {"container": mainWindow_listView_StatusListView, "index": 3, "objectName": "CommunitySettingsView_NavigationListItem_Tokens", "type": "StatusNavigationListItem", "visible": True}
airdrops_StatusNavigationListItem = {"container": mainWindow_listView_StatusListView, "index": 4, "objectName": "CommunitySettingsView_NavigationListItem_Airdrops", "type": "StatusNavigationListItem", "visible": True}

# Overview Settings View
mainWindow_OverviewSettingsPanel = {"container": mainWindow_communityLoader_Loader, "type": "OverviewSettingsPanel", "unnamed": 1, "visible": True}
communityOverviewSettingsCommunityName_StatusBaseText = {"container": mainWindow_OverviewSettingsPanel, "objectName": "communityOverviewSettingsCommunityName", "type": "StatusBaseText", "visible": True}
communityOverviewSettingsCommunityDescription_StatusBaseText = {"container": mainWindow_OverviewSettingsPanel,  "objectName": "communityOverviewSettingsCommunityDescription", "type": "StatusBaseText", "visible": True}
mainWindow_Edit_Community_StatusButton = {"container": statusDesktop_mainWindow, "objectName": "communityOverviewSettingsEditCommunityButton", "type": "StatusButton", "visible": True}
# Members Settings View
mainWindow_MembersSettingsPanel = {"container": mainWindow_communityLoader_Loader, "type": "MembersSettingsPanel", "unnamed": 1, "visible": True}
membersListViews_ListView = {"container": mainWindow_MembersSettingsPanel, "objectName": "CommunityMembersTabPanel_MembersListViews", "type": "ListView", "visible": True}
memberItem_StatusMemberListItem = {"container": membersListViews_ListView, "id": "memberItem", "type": "StatusMemberListItem", "unnamed": 1, "visible": True}
communitySettings_MembersTab_Member_Kick_Button = {"container": membersListViews_ListView, "objectName": "MemberListItem_KickButton", "type": "StatusButton", "visible": True}

# Tokens View
mainWindow_mintPanel_MintTokensSettingsPanel = {"container": mainWindow_StatusWindow, "id": "mintPanel", "type": "MintTokensSettingsPanel", "unnamed": 1, "visible": True}
mainWindow_MintedTokensView = {"container": mainWindow_StatusWindow, "type": "MintedTokensView", "unnamed": 1, "visible": True}
mainWindow_Mint_token_StatusButton = {"checkable": False, "container": mainWindow_StatusWindow, "objectName": "addNewItemButton", "type": "StatusButton", "visible": True}
welcomeSettingsTokens_Image = {"container": mainWindow_MintedTokensView, "objectName": "welcomeSettingsImage", "type": "Image", "visible": True}
welcomeSettingsTokens_Title = {"container": mainWindow_MintedTokensView, "objectName": "welcomeSettingsTitle", "type": "StatusBaseText", "visible": True}
welcomeSettingsTokensSubtitle = {"container": mainWindow_MintedTokensView, "objectName": "welcomeSettingsSubtitle", "type": "StatusBaseText", "visible": True}
checkListText_0_Tokens = {"container": mainWindow_MintedTokensView, "objectName": "checkListText_0", "type": "StatusBaseText", "visible": True}
checkListText_1_Tokens = {"container": mainWindow_MintedTokensView, "objectName": "checkListText_1", "type": "StatusBaseText", "visible": True}
checkListText_2_Tokens = {"container": mainWindow_MintedTokensView, "objectName": "checkListText_2", "type": "StatusBaseText", "visible": True}
mint_Owner_Tokens_InfoBoxPanel = {"container": mainWindow_MintedTokensView, "type": "StatusInfoBoxPanel", "unnamed": 1, "visible": True}
mint_Owner_Tokens_StatusButton = {"checkable": False, "container": mainWindow_MintedTokensView, "id": "button", "type": "StatusButton", "unnamed": 1, "visible": True}

# Owner Token settings view
mainWindow_ownerTokenPage_SettingsPage = {"container": mainWindow_StatusWindow, "id": "ownerTokenPage", "type": "SettingsPage", "unnamed": 1, "visible": True}
mainWindow_OwnerTokenWelcomeView = {"container": mainWindow_StatusWindow, "type": "OwnerTokenWelcomeView", "unnamed": 1, "visible": True}
ownerToken_InfoPanel = {"container": mainWindow_OwnerTokenWelcomeView, "type": "InfoPanel", "unnamed": 1, "visible": True}
tokenMasterToken_InfoPanel = {"container": mainWindow_OwnerTokenWelcomeView, "occurrence": 2, "type": "InfoPanel", "unnamed": 1, "visible": True}
next_StatusButton = {"checkable": False, "container": mainWindow_OwnerTokenWelcomeView, "type": "StatusButton", "unnamed": 1, "visible": True}
owner_token_StatusBaseText = {"container": ownerToken_InfoPanel, "type": "StatusBaseText", "unnamed": 1, "visible": True}
token_master_StatusBaseText = {"container": tokenMasterToken_InfoPanel, "type": "StatusBaseText", "unnamed": 1, "visible": True}
o_Flickable = {"container": mainWindow_OwnerTokenWelcomeView, "type": "Flickable", "unnamed": 1, "visible": True}

# Edit owner token view
mainWindow_editOwnerTokenView_EditOwnerTokenView = {"container": mainWindow_StatusWindow, "id": "editOwnerTokenView", "type": "EditOwnerTokenView", "unnamed": 1, "visible": True}
editOwnerTokenView_Flickable = {"container": mainWindow_editOwnerTokenView_EditOwnerTokenView, "type": "Flickable", "unnamed": 1, "visible": True}
editOwnerTokenView_CustomComboItem = {"checkable": False, "container": mainWindow_editOwnerTokenView_EditOwnerTokenView, "type": "CustomComboItem", "unnamed": 1, "visible": True}
editOwnerTokenView_netFilter_NetworkFilter = {"container": mainWindow_editOwnerTokenView_EditOwnerTokenView, "objectName": "netFilter", "type": "NetworkFilter", "visible": True}
editOwnerTokenView_comboBox_ComboBox = {"container": editOwnerTokenView_netFilter_NetworkFilter, "id": "comboBox", "occurrence": 2, "type": "ComboBox", "unnamed": 1, "visible": True}
mainnet_NetworkSelectItemDelegate = {"container": statusDesktop_mainWindow_overlay, "index": 0, "objectName": "Mainnet", "type": "NetworkSelectItemDelegate", "visible": True}
optimism_NetworkSelectItemDelegate = {"container": statusDesktop_mainWindow_overlay, "index": 1, "objectName": "Optimism", "type": "NetworkSelectItemDelegate", "visible": True}
arbitrum_NetworkSelectItemDelegate = {"container": statusDesktop_mainWindow_overlay, "index": 2, "objectName": "Arbitrum", "type": "NetworkSelectItemDelegate", "visible": True}
editOwnerTokenView_Mint_StatusButton = {"checkable": False, "container": mainWindow_editOwnerTokenView_EditOwnerTokenView, "objectName": "mintButton", "type": "StatusButton", "visible": True}
editOwnerTokenView_FeeRow = {"container": mainWindow_editOwnerTokenView_EditOwnerTokenView, "type": "FeeRow", "unnamed": 1, "visible": True}
editOwnerTokenView_fees_StatusBaseText = {"container": editOwnerTokenView_FeeRow, "type": "StatusBaseText", "unnamed": 1, "visible": True}

editOwnerTokenView_Owner_StatusBaseText = {"container": mainWindow_editOwnerTokenView_EditOwnerTokenView, "type": "StatusBaseText", "unnamed": 1, "visible": True}
editOwnerTokenView_crown_icon_StatusIcon = {"container": mainWindow_editOwnerTokenView_EditOwnerTokenView, "objectName": "crown-icon", "type": "StatusIcon", "visible": True}
editOwnerTokenView_symbolBox = {"container": mainWindow_editOwnerTokenView_EditOwnerTokenView, "objectName": "symbolBox", "type": "CustomPreviewBox", "visible": True}
editOwnerTokenView_totalBox = {"container": mainWindow_editOwnerTokenView_EditOwnerTokenView, "objectName": "totalBox", "type": "CustomPreviewBox", "visible": True}
editOwnerTokenView_remainingBox = {"container": mainWindow_editOwnerTokenView_EditOwnerTokenView, "objectName": "remainingBox", "type": "CustomPreviewBox", "visible": True}
editOwnerTokenView_transferableBox = {"container": mainWindow_editOwnerTokenView_EditOwnerTokenView, "objectName": "transferableBox", "type": "CustomPreviewBox", "visible": True}
editOwnerTokenView_destructibleBox = {"container": mainWindow_editOwnerTokenView_EditOwnerTokenView, "objectName": "destructibleBox", "type": "CustomPreviewBox", "visible": True}
editOwnerTokenView_token_sale_icon_StatusIcon = {"container": mainWindow_editOwnerTokenView_EditOwnerTokenView, "objectName": "token-sale-icon", "type": "StatusIcon", "visible": True}

# Minted tokens view
mainWindow_MintedTokensView = {"container": mainWindow_StatusWindow, "type": "MintedTokensView", "unnamed": 1, "visible": True}
specialCollectible_PrivilegedTokenArtworkPanel = {"container": mainWindow_MintedTokensView, "id": "specialCollectible", "type": "PrivilegedTokenArtworkPanel", "unnamed": 1, "visible": True}
specialCollectible_PrivilegedTokenArtworkPanel_2 = {"container": mainWindow_MintedTokensView, "id": "specialCollectible", "occurrence": 2, "type": "PrivilegedTokenArtworkPanel", "unnamed": 1, "visible": True}
o_CollectibleView_2 = {"container": mainWindow_MintedTokensView, "index": 1, "type": "CollectibleView", "unnamed": 1, "visible": True}
o_CollectibleView = {"container": mainWindow_MintedTokensView, "index": 0, "type": "CollectibleView", "unnamed": 1, "visible": True}
token_sale_icon_StatusIcon = {"container": mainWindow_MintedTokensView, "objectName": "token-sale-icon", "type": "StatusIcon", "visible": True}
crown_icon_StatusIcon = {"container": mainWindow_MintedTokensView, "objectName": "crown-icon", "type": "StatusIcon", "visible": True}

# Airdrops View
mainWindow_airdropPanel_AirdropsSettingsPanel = {"container": mainWindow_StatusWindow, "id": "airdropPanel", "type": "AirdropsSettingsPanel", "unnamed": 1, "visible": True}
mainWindow_WelcomeSettingsView = {"container": mainWindow_StatusWindow, "type": "WelcomeSettingsView", "unnamed": 1, "visible": True}
mainWindow_New_Airdrop_StatusButton = {"checkable": False, "container": mainWindow_StatusWindow, "objectName": "addNewItemButton", "type": "StatusButton", "visible": True}
welcomeSettingsAirdrops_Image = {"container": mainWindow_WelcomeSettingsView, "objectName": "welcomeSettingsImage", "type": "Image", "visible": True}
welcomeSettingsAirdrops_Title = {"container": mainWindow_WelcomeSettingsView, "objectName": "welcomeSettingsTitle", "type": "StatusBaseText", "visible": True}
welcomeSettingsAirdrops_Subtitle = {"container": mainWindow_WelcomeSettingsView, "objectName": "welcomeSettingsSubtitle", "type": "StatusBaseText", "visible": True}
checkListText_0_Airdrops = {"container": mainWindow_WelcomeSettingsView, "objectName": "checkListText_0", "type": "StatusBaseText", "visible": True}
checkListText_1_Airdrops = {"container": mainWindow_WelcomeSettingsView, "objectName": "checkListText_1", "type": "StatusBaseText", "visible": True}
checkListText_2_Airdrops = {"container": mainWindow_WelcomeSettingsView, "objectName": "checkListText_2", "type": "StatusBaseText", "visible": True}
infoBox_StatusInfoBoxPanel = {"container": mainWindow_WelcomeSettingsView, "id": "infoBox", "type": "StatusInfoBoxPanel", "unnamed": 1, "visible": True}
mint_Owner_token_Airdrops_StatusButton = {"checkable": False, "container": mainWindow_WelcomeSettingsView, "id": "button", "type": "StatusButton", "unnamed": 1, "visible": True}

# Permissions Intro View
community_welcome_screen_image = {"container": statusDesktop_mainWindow, "objectName": "welcomeSettingsImage", "type": "Image", "visible": True}
community_welcome_screen_title = {"container": statusDesktop_mainWindow, "objectName": "welcomeSettingsTitle", "type": "StatusBaseText", "visible": True}
community_welcome_screen_subtitle = {"container": statusDesktop_mainWindow, "objectName": "welcomeSettingsSubtitle", "type": "StatusBaseText", "visible": True}
community_welcome_screen_checkList_element1 = {"container": statusDesktop_mainWindow, "objectName": "checkListText_0", "type": "StatusBaseText", "visible": True}
community_welcome_screen_checkList_element2 = {"container": statusDesktop_mainWindow, "objectName": "checkListText_1", "type": "StatusBaseText", "visible": True}
community_welcome_screen_checkList_element3 = {"container": statusDesktop_mainWindow, "objectName": "checkListText_2", "type": "StatusBaseText", "visible": True}
add_new_permission_button = {"container": statusDesktop_mainWindow, "objectName": "addNewItemButton", "type": "StatusButton", "visible": True}

# Permissions Settings View
mainWindow_editPermissionView_EditPermissionView = {"container": statusDesktop_mainWindow, "id": "editPermissionView", "type": "EditPermissionView", "unnamed": 1, "visible": True}
editPermissionView_Who_holds_StatusItemSelector = {"container": mainWindow_editPermissionView_EditPermissionView, "id": "tokensSelector", "type": "StatusItemSelector", "unnamed": 1, "visible": True}
editPermissionView_Is_allowed_to_StatusFlowSelector = {"container": mainWindow_editPermissionView_EditPermissionView, "id": "permissionsSelector", "type": "StatusFlowSelector", "unnamed": 1, "visible": True}
editPermissionView_In_StatusItemSelector = {"container": mainWindow_editPermissionView_EditPermissionView, "id": "inSelector", "type": "StatusItemSelector", "unnamed": 1, "visible": True}
editPermissionView_whoHoldsSwitch_StatusSwitch = {"checkable": True, "container": mainWindow_editPermissionView_EditPermissionView, "id": "whoHoldsSwitch", "type": "StatusSwitch", "unnamed": 1, "visible": True}
edit_TextEdit = {"container": statusDesktop_mainWindow_overlay, "type": "TextEdit", "unnamed": 1, "visible": True}
inputValue_StyledTextField = {"container": statusDesktop_mainWindow_overlay, "id": "inputValue", "type": "StyledTextField", "unnamed": 1, "visible": True}
o_TokenItem = {"container": statusDesktop_mainWindow_overlay, "index": 0, "type": "TokenItem", "unnamed": 1, "visible": True}
add_StatusButton = {"checkable": False, "container": statusDesktop_mainWindow_overlay, "type": "StatusButton", "unnamed": 1, "visible": True}
customPermissionListItem = {"container": statusDesktop_mainWindow_overlay, "objectName": "becomeAdmin", "type": "CustomPermissionListItem", "visible": True}
checkBox_StatusCheckBox = {"checkable": True, "container": statusDesktop_mainWindow_overlay, "id": "checkBox", "type": "StatusCheckBox", "unnamed": 1, "visible": True}
editPermissionView_switchItem_StatusSwitch = {"checkable": True, "container": mainWindow_editPermissionView_EditPermissionView, "objectName": "switchItem", "type": "StatusSwitch", "visible": True}
editPermissionView_Create_permission_StatusButton = {"checkable": False, "container": mainWindow_editPermissionView_EditPermissionView, "text": "Create permission", "type": "StatusButton", "unnamed": 1, "visible": True}
mainWindow_PermissionsView = {"container": statusDesktop_mainWindow, "type": "PermissionsView", "unnamed": 1, "visible": True}
o_StatusListItemTag = {"container": mainWindow_PermissionsView, "type": "StatusListItemTag", "visible": True}
o_IntroPanel = {"container": mainWindow_PermissionsView, "type": "IntroPanel", "unnamed": 1, "visible": True}
mainWindow_PermissionsSettingsPanel = {"container": statusDesktop_mainWindow, "type": "PermissionsSettingsPanel", "unnamed": 1, "visible": True}
whoHoldsTagListItem = {"container": mainWindow_PermissionsView, "objectName": "whoHoldsStatusListItem", "type": "StatusListItemTag", "visible": True}
isAllowedTagListItem = {"container": mainWindow_PermissionsView, "objectName": "isAllowedStatusListItem", "type": "StatusListItemTag", "visible": True}
inCommunityTagListItem = {"container": mainWindow_PermissionsView, "objectName": "inCommunityStatusListItem", "type": "StatusListItemTag", "visible": True}
edit_pencil_icon_StatusIcon = {"container": mainWindow_PermissionsView, "objectName": "edit_pencil-icon", "type": "StatusIcon", "visible": True}
delete_icon_StatusIcon = {"container": mainWindow_PermissionsView, "objectName": "delete-icon", "type": "StatusIcon", "visible": True}
hide_icon_StatusIcon = {"container": mainWindow_PermissionsView, "objectName": "hide-icon", "type": "StatusIcon", "visible": True}
editPermissionView_settingsDirtyToastMessage_SettingsDirtyToastMessage = {"container": mainWindow_editPermissionView_EditPermissionView, "id": "settingsDirtyToastMessage", "type": "SettingsDirtyToastMessage", "unnamed": 1, "visible": True}
update_StatusButton = {"checkable": False, "container": statusDesktop_mainWindow_overlay, "type": "StatusButton", "unnamed": 1, "visible": True}
isAllowedToEditPermissionView_StatusListItemTag = {"container": mainWindow_editPermissionView_EditPermissionView, "type": "StatusListItemTag", "unnamed": 1, "visible": True}
memberRoleLimitWarning = {"container": mainWindow_editPermissionView_EditPermissionView, "id": "duplicationPanel", "type": "WarningPanel", "unnamed": 1, "visible": True}

# Edit Community
mainWindow_communityEditPanelScrollView_EditSettingsPanel = {"container": statusDesktop_mainWindow, "objectName": "communityEditPanelScrollView", "type": "EditSettingsPanel", "visible": True}
communityEditPanelScrollView_Flickable = {"container": mainWindow_communityEditPanelScrollView_EditSettingsPanel, "type": "Flickable", "unnamed": 1, "visible": True}
communityEditPanelScrollView_communityNameInput_TextEdit = {"container": mainWindow_communityEditPanelScrollView_EditSettingsPanel, "objectName": "communityNameInput", "type": "TextEdit", "visible": True}
communityEditPanelScrollView_communityDescriptionInput_TextEdit = {"container": mainWindow_communityEditPanelScrollView_EditSettingsPanel, "objectName": "communityDescriptionInput", "type": "TextEdit", "visible": True}
communityEditPanelScrollView_communityLogoPicker_LogoPicker = {"container": mainWindow_communityEditPanelScrollView_EditSettingsPanel, "objectName": "communityLogoPicker", "type": "LogoPicker", "visible": True}
communityEditPanelScrollView_image_StatusImage = {"container": communityEditPanelScrollView_communityLogoPicker_LogoPicker, "id": "image", "type": "StatusImage", "unnamed": 1, "visible": True}
communityEditPanelScrollView_editButton_StatusRoundButton = {"container": communityEditPanelScrollView_communityLogoPicker_LogoPicker, "id": "editButton", "type": "StatusRoundButton", "unnamed": 1, "visible": True}
communityEditPanelScrollView_communityBannerPicker_BannerPicker = {"container": mainWindow_communityEditPanelScrollView_EditSettingsPanel, "objectName": "communityBannerPicker", "type": "BannerPicker", "visible": True}
communityEditPanelScrollView_image_StatusImage_2 = {"container": communityEditPanelScrollView_communityBannerPicker_BannerPicker, "id": "image", "type": "StatusImage", "unnamed": 1, "visible": True}
communityEditPanelScrollView_editButton_StatusRoundButton_2 = {"container": communityEditPanelScrollView_communityBannerPicker_BannerPicker, "id": "editButton", "type": "StatusRoundButton", "unnamed": 1, "visible": True}
communityEditPanelScrollView_StatusPickerButton = {"checkable": False, "container": mainWindow_communityEditPanelScrollView_EditSettingsPanel, "type": "StatusPickerButton", "unnamed": 1, "visible": True}
communityEditPanelScrollView_communityTagsPicker_TagsPicker = {"container": mainWindow_communityEditPanelScrollView_EditSettingsPanel, "objectName": "communityTagsPicker", "type": "TagsPicker", "visible": True}
communityEditPanelScrollView_flow_Flow = {"container": communityEditPanelScrollView_communityTagsPicker_TagsPicker, "id": "flow", "type": "Flow", "unnamed": 1, "visible": True}
communityEditPanelScrollView_StatusCommunityTag = {"container": communityEditPanelScrollView_communityTagsPicker_TagsPicker, "type": "StatusCommunityTag", "unnamed": 1, "visible": True}
communityEditPanelScrollView_Choose_StatusPickerButton = {"checkable": False, "container": communityEditPanelScrollView_communityTagsPicker_TagsPicker, "type": "StatusPickerButton", "unnamed": 1, "visible": True}
communityEditPanelScrollView_archiveSupportToggle_StatusCheckBox = {"checkable": True, "container": mainWindow_communityEditPanelScrollView_EditSettingsPanel, "id": "archiveSupportToggle", "type": "StatusCheckBox", "unnamed": 1, "visible": True}
communityEditPanelScrollView_requestToJoinToggle_StatusCheckBox = {"checkable": True, "container": mainWindow_communityEditPanelScrollView_EditSettingsPanel, "id": "requestToJoinToggle", "type": "StatusCheckBox", "unnamed": 1, "visible": True}
communityEditPanelScrollView_pinMessagesToggle_StatusCheckBox = {"checkable": True, "container": mainWindow_communityEditPanelScrollView_EditSettingsPanel, "id": "pinMessagesToggle", "type": "StatusCheckBox", "unnamed": 1, "visible": True}
communityEditPanelScrollView_editCommunityIntroInput_TextEdit = {"container": mainWindow_communityEditPanelScrollView_EditSettingsPanel, "objectName": "editCommunityIntroInput", "type": "TextEdit", "visible": True}
communityEditPanelScrollView_editCommunityOutroInput_TextEdit = {"container": mainWindow_communityEditPanelScrollView_EditSettingsPanel, "objectName": "editCommunityOutroInput", "type": "TextEdit", "visible": True}
editPermissionView_Update_permission_StatusButton = {"checkable": False, "container": mainWindow_editPermissionView_EditPermissionView, "objectName": "settingsDirtyToastMessageSaveButton", "type": "StatusButton", "visible": True}
croppedImageEditLogo = {"container": mainWindow_communityEditPanelScrollView_EditSettingsPanel, "objectName": "editCroppedImageItem_Community logo", "type": "EditCroppedImagePanel", "visible": True}
croppedImageEditBanner = {"container": mainWindow_communityEditPanelScrollView_EditSettingsPanel, "objectName": "editCroppedImageItem_Community banner", "type": "EditCroppedImagePanel", "visible": True}

# User List Panel
mainWindow_userListPanel_StatusListView = {"container": statusDesktop_mainWindow, "objectName": "userListPanel", "type": "StatusListView", "visible": True}
userListPanel_StatusMemberListItem = {"container": mainWindow_userListPanel_StatusListView, "type": "StatusMemberListItem", "unnamed": 1, "visible": True}
statusBadge_StatusBadge = {"container": userListPanel_StatusMemberListItem, "id": "statusBadge", "type": "StatusBadge", "unnamed": 1, "visible": True}
