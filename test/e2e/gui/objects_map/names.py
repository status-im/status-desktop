from objectmaphelper import *

# MAIN NAMES

statusDesktop_mainWindow = {"name": "mainWindow", "type": "StatusWindow"}
mainWindow_StatusWindow = {"name": "mainWindow", "type": "StatusWindow", "visible": True}
statusDesktop_mainWindow_overlay = {"container": statusDesktop_mainWindow, "type": "Overlay", "unnamed": 1, "visible": True}
statusDesktop_mainWindow_overlay_popup2 = {"container": statusDesktop_mainWindow_overlay, "occurrence": 2, "type": "PopupItem", "unnamed": 1, "visible": True}
basePopup = {"container": statusDesktop_mainWindow_overlay, "type": "PopupItem", "unnamed": 1, "visible": True}
scrollView_StatusScrollView = {"container": statusDesktop_mainWindow_overlay, "id": "scrollView", "type": "StatusScrollView", "unnamed": 1, "visible": True}
splashScreen = {"container": statusDesktop_mainWindow, "objectName": "splashScreen", "type": "DidYouKnowSplashScreen"}
mainWindow_LoadingAnimation = {"container": statusDesktop_mainWindow, "objectName": "loadingAnimation", "type": "LoadingAnimation", "visible": True}

# Common names
settingsSave_StatusButton = {"container": statusDesktop_mainWindow, "objectName": "settingsDirtyToastMessageSaveButton", "type": "StatusButton", "visible": True}
mainWindow_Save_changes_StatusButton = {"checkable": False, "container": statusDesktop_mainWindow, "objectName": "settingsDirtyToastMessageSaveButton", "type": "StatusButton", "visible": True}
closeCrossPopupButton = {"container": statusDesktop_mainWindow_overlay, "objectName": "headerActionsCloseButton", "type": "StatusFlatRoundButton", "visible": True}

# Main right panel
mainWindow_RighPanel = {"container": statusDesktop_mainWindow, "type": "ColumnLayout", "objectName": "mainRightView", "visible": True}

# Navigation Panel
mainWindow_scrollView_StatusScrollView = {"container": mainWindow_StatusWindow, "id": "scrollView", "type": "StatusScrollView", "unnamed": 1, "visible": True}
mainWindow_StatusAppNavBar = {"container": statusDesktop_mainWindow, "type": "StatusAppNavBar", "unnamed": 1, "visible": True}
messages_navbar_StatusNavBarTabButton = {"checkable": True, "container": mainWindow_StatusAppNavBar, "objectName": "Messages-navbar", "type": "StatusNavBarTabButton", "visible": True}
mainWindow_statusMainNavBarListView_ListView = {"container": statusDesktop_mainWindow, "objectName": "statusMainNavBarListView", "type": "ListView", "visible": True}
communities_Portal_navbar_StatusNavBarTabButton = {"checkable": True, "container": mainWindow_statusMainNavBarListView_ListView, "objectName": "Communities Portal-navbar", "type": "StatusNavBarTabButton", "visible": True}
wallet_navbar_StatusNavBarTabButton = {"checkable": True, "container": mainWindow_StatusAppNavBar, "objectName": "Wallet-navbar", "type": "StatusNavBarTabButton", "visible": True}
settings_navbar_StatusNavBarTabButton = {"checkable": True, "container": mainWindow_StatusAppNavBar, "objectName": "Settings-navbar", "type": "StatusNavBarTabButton", "visible": True}
mainWindow_ProfileNavBarButton = {"container": statusDesktop_mainWindow, "objectName": "statusProfileNavBarTabButton", "type": "StatusNavBarTabButton", "visible": True}
mainWindow_statusCommunityMainNavBarListView_ListView = {"container": statusDesktop_mainWindow, "objectName": "statusCommunityMainNavBarListView", "type": "ListView", "visible": True}
statusCommunityMainNavBarListView_CommunityNavBarButton = {"checkable": True, "container": mainWindow_statusCommunityMainNavBarListView_ListView, "objectName": "CommunityNavBarButton", "type": "StatusNavBarTabButton", "visible": True}
invite_People_StatusMenuItem = {"container": statusDesktop_mainWindow_overlay, "enabled": True, "objectName": "invitePeople", "type": "StatusMenuItem", "visible": True}
scrollView_Add_members_StatusButton = {"checkable": False, "container": mainWindow_scrollView_StatusScrollView, "objectName": "CommunityWelcomeBannerPanel_AddMembersButton", "type": "StatusButton", "visible": True}

# Banners
secureYourSeedPhraseBanner_ModuleWarning = {"container": statusDesktop_mainWindow, "objectName": "secureYourSeedPhraseBanner", "type": "ModuleWarning", "visible": True}

# Scroll
o_Flickable = {"container": statusDesktop_mainWindow_overlay, "type": "Flickable", "unnamed": 1, "visible": True}
generalView_StatusScrollView = {"container": statusDesktop_mainWindow_overlay, "id": "generalView", "type": "StatusScrollView", "unnamed": 1, "visible": True}

# Context Menu
o_StatusListView = {"container": statusDesktop_mainWindow_overlay, "type": "PopupItem", "unnamed": 1, "visible": True}

# COMPONENT NAMES

""" Onboarding """
# Before you get started Popup
acknowledge_checkbox = {"checkable": True, "container": statusDesktop_mainWindow_overlay, "objectName": "acknowledgeCheckBox", "type": "StatusCheckBox", "visible": True}
acknowledgeIndicator = {"container": acknowledge_checkbox, "objectName": "indicator", "type": "Item", "visible": True}
termsOfUseCheckBox_StatusCheckBox = {"checkable": True, "container": statusDesktop_mainWindow_overlay, "objectName":"termsOfUseCheckBox", "type": "StatusCheckBox", "visible": True}
termsOfUseIndicator = {"container": termsOfUseCheckBox_StatusCheckBox, "objectName": "indicator", "type": "Item", "visible": True}
getStartedStatusButton_StatusButton = {"container": statusDesktop_mainWindow_overlay, "objectName": "getStartedStatusButton", "type": "StatusButton", "visible": True}
termsOfUseLink_StatusBaseText = {"container": statusDesktop_mainWindow_overlay, "objectName": "termsOfUseLink", "type": "StatusBaseText", "visible": True}
privacyPolicyLink_StatusBaseText = {"container": statusDesktop_mainWindow_overlay, "objectName": "privacyPolicyLink", "type": "StatusBaseText", "visible": True}

# Back Up Your Seed Phrase Popup
o_PopupItem = {"container": statusDesktop_mainWindow_overlay, "type": "PopupItem", "unnamed": 1, "visible": True}
i_have_a_pen_and_paper_StatusCheckBox = {"checkable": True, "container": statusDesktop_mainWindow_overlay, "objectName": "Acknowledgements_havePen", "type": "StatusCheckBox", "visible": True}
i_know_where_I_ll_store_it_StatusCheckBox = {"checkable": True, "container": statusDesktop_mainWindow_overlay, "objectName": "Acknowledgements_storeIt", "type": "StatusCheckBox", "visible": True}
i_am_ready_to_write_down_StatusCheckBox = {"checkable": True, "container": statusDesktop_mainWindow_overlay, "objectName": "Acknowledgements_writeDown", "type": "StatusCheckBox", "visible": True}
not_Now_StatusButton = {"checkable": False, "container": statusDesktop_mainWindow_overlay, "type": "StatusButton", "unnamed": 1, "visible": True}
confirm_Seed_Phrase_StatusButton = {"checkable": False, "container": statusDesktop_mainWindow_overlay, "objectName": "BackupSeedModal_nextButton", "type": "StatusButton", "visible": True}
backup_seed_phrase_popup_StatusSeedPhraseInput_placeholder = {"container": statusDesktop_mainWindow_overlay, "objectName": "ConfirmSeedPhrasePanel_StatusSeedPhraseInput_%WORD_NO%", "type": "StatusSeedPhraseInput", "visible": True}
reveal_seed_phrase_StatusButton = {"checkable": False, "container": statusDesktop_mainWindow_overlay, "objectName": "ConfirmSeedPhrasePanel_RevealSeedPhraseButton", "type": "StatusButton", "visible": True}
blur_GaussianBlur = {"container": statusDesktop_mainWindow_overlay, "id": "blur", "type": "GaussianBlur", "unnamed": 1, "visible": True}
confirmSeedPhrasePanel_StatusSeedPhraseInput = {"container": statusDesktop_mainWindow_overlay, "type": "StatusSeedPhraseInput", "visible": True}
confirmFirstWord = {"container": statusDesktop_mainWindow_overlay, "objectName": "BackupSeedModal_BackupSeedStepBase_confirmFirstWord", "type": "BackupSeedStepBase", "visible": True}
confirmFirstWord_inputText = {"container": confirmFirstWord, "objectName": "BackupSeedStepBase_inputText", "type": "TextEdit", "visible": True}
continue_StatusButton = {"checkable": False, "container": statusDesktop_mainWindow_overlay, "objectName": "BackupSeedModal_nextButton", "type": "StatusButton", "visible": True}
confirmSecondWord = {"container": statusDesktop_mainWindow_overlay, "objectName": "BackupSeedModal_BackupSeedStepBase_confirmSecondWord", "type": "BackupSeedStepBase", "visible": True}
confirmSecondWord_inputText = {"container": confirmSecondWord, "objectName": "BackupSeedStepBase_inputText", "type": "TextEdit", "visible": True}
i_acknowledge_StatusCheckBox = {"checkable": True, "container": statusDesktop_mainWindow_overlay, "objectName": "ConfirmStoringSeedPhrasePanel_storeCheck", "type": "StatusCheckBox", "visible": True}
completeAndDeleteSeedPhraseButton = {"container": statusDesktop_mainWindow_overlay, "objectName": "BackupSeedModal_completeAndDeleteSeedPhraseButton", "type": "StatusButton", "visible": True}

# Send Contact Request Popup
contactRequest_ChatKey_Input = {"container": statusDesktop_mainWindow_overlay, "objectName": "SendContactRequestModal_ChatKey_Input", "type": "TextEdit"}
contactRequest_SayWhoYouAre_Input = {"container": statusDesktop_mainWindow_overlay, "objectName": "SendContactRequestModal_SayWhoYouAre_Input", "type": "TextEdit"}
contactRequest_Send_Button = {"container": statusDesktop_mainWindow_overlay, "objectName": "SendContactRequestModal_Send_Button", "type": "StatusButton"}

# Change Language Popup
close_the_app_now_StatusButton = {"checkable": False, "container": statusDesktop_mainWindow_overlay, "type": "StatusButton", "unnamed": 1, "visible": True}

# User Status Profile Menu
onlineIdentifierProfileHeader = {"container": statusDesktop_mainWindow_overlay, "objectName": "onlineIdentifierProfileHeader", "type": "ProfileHeader", "visible": True}
userContextmenu_AlwaysActiveButton= {"container": o_StatusListView, "objectName": "userStatusMenuAlwaysOnlineAction", "type": "StatusMenuItem", "visible": True}
userContextmenu_InActiveButton= {"container": o_StatusListView, "objectName": "userStatusMenuInactiveAction", "type": "StatusMenuItem", "visible": True}
userContextmenu_AutomaticButton= {"container": o_StatusListView, "objectName": "userStatusMenuAutomaticAction", "type": "StatusMenuItem", "visible": True}
userContextMenu_ViewMyProfileAction = {"container": o_StatusListView, "objectName": "userStatusViewMyProfileAction", "type": "StatusMenuItem", "visible": True}
userContextMenu_CopyLinkToProfile = {"container": statusDesktop_mainWindow_overlay, "objectName": "userStatusCopyLinkAction", "type": "StatusMenuItem", "visible": True}
userLabel_StyledText = {"container": o_StatusListView, "type": "StyledText", "unnamed": 1, "visible": True}
o_StatusIdenticonRing = {"container": o_StatusListView, "type": "StatusIdenticonRing", "unnamed": 1, "visible": True}

# My Profile Popup (online identifier)
ProfileContentItem = {"container": statusDesktop_mainWindow_overlay, "objectName": "ProfileDialogView", "type": "ContentItem", "visible": True}
ProfileHeader_userImage = {"container": ProfileContentItem, "objectName": "ProfileDialog_userImage", "type": "UserImage", "visible": True}
ProfilePopup_displayName = {"container": ProfileContentItem, "objectName": "ProfileDialog_displayName", "type": "StatusBaseText", "visible": True}
ProfilePopup_editButton = {"container": ProfileContentItem, "objectName": "editProfileButton", "type": "StatusButton", "visible": True}
share_Profile_StatusFlatButton = {"checkable": False, "container": ProfileContentItem, "objectName": "shareProfileButton", "type": "StatusFlatButton", "visible": True}
ProfilePopup_SendContactRequestButton = {"container": ProfileContentItem, "objectName": "profileDialog_sendContactRequestButton", "type": "StatusButton", "visible": True}
profileDialog_userEmojiHash_EmojiHash = {"container": ProfileContentItem, "objectName": "ProfileDialog_userEmojiHash", "type": "EmojiHash", "visible": True}
edit_TextEdit = {"container": ProfileContentItem, "id": "edit", "type": "TextEdit", "unnamed": 1, "visible": True}
https_status_app_StatusBaseText = {"container": edit_TextEdit, "type": "StatusBaseText", "unnamed": 1, "visible": True}
copy_icon_CopyButton = {"container": ProfileContentItem, "objectName": "copy-icon", "type": "CopyButton", "visible": True}
request_ID_verification_StatusFlatButton = {"checkable": False, "container": ProfileContentItem, "objectName": "requestIDVerification_StatusItem", "type": "StatusFlatButton", "visible": True}
send_Message_StatusButton = {"checkable": False, "container": statusDesktop_mainWindow_overlay, "objectName": "sendMessageButton", "type": "StatusButton", "visible": True}
send_contact_request_StatusButton = {"checkable": False, "container": ProfileContentItem, "objectName": "profileDialog_sendContactRequestButton", "type": "StatusButton", "visible": True}
review_contact_request_StatusButton = {"checkable": False, "container": statusDesktop_mainWindow_overlay, "objectName": "profileDialog_reviewContactRequestButton", "type": "StatusButton", "visible": True}
profileDialogView_ContentItem = {"container": statusDesktop_mainWindow_overlay, "objectName": "ProfileDialogView", "type": "ContentItem", "visible": True}
menuButton_StatusFlatButton = {"checkable": False, "container": profileDialogView_ContentItem, "id": "menuButton", "type": "StatusFlatButton", "unnamed": 1, "visible": True}
block_user_StatusMenuItem = {"checkable": False, "container": statusDesktop_mainWindow_overlay, "enabled": True, "objectName": "blockUserStatusAction", "type": "StatusMenuItem", "visible": True}
add_nickname_StatusMenuItem = {"checkable": False, "container": statusDesktop_mainWindow_overlay, "enabled": True, "objectName": "addEditNickNameStatusAction", "type": "StatusMenuItem", "visible": True}
unblock_user_StatusButton = {"checkable": False, "container": statusDesktop_mainWindow_overlay, "objectName": "unblockUserProfileButton", "type": "StatusButton", "visible": True}

# Share profile popup
o_Image = {"container": statusDesktop_mainWindow_overlay, "objectName": "profileQRCodeImage", "type": "Image", "visible": True}
o_copy_icon_CopyButton = {"container": statusDesktop_mainWindow_overlay, "objectName": "copy-icon", "type": "CopyButton", "visible": True}
o_EmojiHash = {"container": statusDesktop_mainWindow_overlay, "type": "EmojiHash", "unnamed": 1, "visible": True}
profileLinkInput_StatusBaseInput = {"container": statusDesktop_mainWindow_overlay, "objectName": "profileLinkInput", "type": "StatusBaseInput", "visible": True}

# Welcome Status Popup
betaConsent_StatusModal = {"container": statusDesktop_mainWindow_overlay, "objectName": "desktopBetaStatusModal", "type": "StatusModal", "visible": True}
agreeToUse_StatusCheckBox = {"checkable": True, "container": statusDesktop_mainWindow_overlay, "objectName": "desktopBetaAgreeCheckBox", "type": "StatusCheckBox", "visible": True}
readyToUse_StatusCheckBox = {"checkable": True, "container": statusDesktop_mainWindow_overlay, "objectName": "desktopBetaReadyCheckBox", "type": "StatusCheckBox", "visible": True}
i_m_ready_to_use_Status_Desktop_Beta_StatusButton = {"container": statusDesktop_mainWindow_overlay, "type": "StatusButton", "objectName": "desktopBetaStatusButton", "visible": True}

# Keys Exist Popup
headline_StatusTitleSubtitle = {"container": statusDesktop_mainWindow_overlay, "id": "headline", "type": "StatusTitleSubtitle", "unnamed": 1, "visible": True}
keys_exist_StatusBaseText = {"container": statusDesktop_mainWindow_overlay, "type": "StatusBaseText", "unnamed": 1, "visible": True}

# Share Usage Data Popup
not_now_StatusButton = {"checkable": False, "container": statusDesktop_mainWindow_overlay, "objectName": "notShareMetricsButton", "type": "StatusFlatButton", "visible": True}
share_usage_data_StatusButton = {"checkable": False, "container": statusDesktop_mainWindow_overlay, "objectName": "shareMetricsButton", "type": "StatusButton", "visible": True}

""" Communities """

# Create Community Banner
create_new_StatusButton = {"checkable": False, "container": statusDesktop_mainWindow_overlay, "objectName": "communityBannerButton", "type": "StatusButton", "visible": True}

# Create Community Popup
createCommunityNameInput_TextEdit = {"container": statusDesktop_mainWindow_overlay, "objectName": "communityNameInput", "type": "TextEdit", "visible": True}
createCommunityDescriptionInput_TextEdit = {"container": statusDesktop_mainWindow_overlay, "objectName": "communityDescriptionInput", "type": "TextEdit", "visible": True}
communityBannerPicker_BannerPicker = {"container": statusDesktop_mainWindow_overlay, "objectName": "communityBannerPicker", "type": "BannerPicker", "visible": True}
addButton_StatusRoundButton = {"container": communityBannerPicker_BannerPicker, "id": "addButton", "type": "StatusRoundButton", "unnamed": 1, "visible": True}
communityLogoPicker_LogoPicker = {"container": statusDesktop_mainWindow_overlay, "objectName": "communityLogoPicker", "type": "LogoPicker", "visible": True}
addButton_StatusRoundButton2 = {"container": communityLogoPicker_LogoPicker, "id": "addButton", "type": "StatusRoundButton", "unnamed": 1, "visible": True}
communityColorPicker_ColorPicker = {"container": statusDesktop_mainWindow_overlay, "objectName": "communityColorPicker", "type": "ColorPicker", "visible": True}
StatusPickerButton = {"checkable": False, "container": communityColorPicker_ColorPicker, "type": "StatusPickerButton", "unnamed": 1, "visible": True}
communityTagsPicker_TagsPicker = {"container": statusDesktop_mainWindow_overlay, "objectName": "communityTagsPicker", "type": "TagsPicker", "visible": True}
choose_tags_StatusPickerButton = {"checkable": False, "container": communityTagsPicker_TagsPicker, "type": "StatusPickerButton", "unnamed": 1, "visible": True}
archiveSupportToggle_StatusCheckBox = {"checkable": True, "container": statusDesktop_mainWindow_overlay, "id": "archiveSupportToggle", "type": "StatusCheckBox", "unnamed": 1, "visible": True}
requestToJoinToggle_StatusCheckBox = {"checkable": True, "container": statusDesktop_mainWindow_overlay, "id": "requestToJoinToggle", "type": "StatusCheckBox", "unnamed": 1, "visible": True}
pinMessagesToggle_StatusCheckBox = {"checkable": True, "container": statusDesktop_mainWindow_overlay, "id": "pinMessagesToggle", "type": "StatusCheckBox", "unnamed": 1, "visible": True}
createCommunityNextBtn_StatusButton = {"container": statusDesktop_mainWindow_overlay, "objectName": "createCommunityNextBtn", "type": "StatusButton", "visible": True}
createCommunityIntroMessageInput_TextEdit = {"container": statusDesktop_mainWindow_overlay, "objectName": "createCommunityIntroMessageInput", "type": "TextEdit", "visible": True}
createCommunityOutroMessageInput_TextEdit = {"container": statusDesktop_mainWindow_overlay, "objectName": "createCommunityOutroMessageInput", "type": "TextEdit", "visible": True}
createCommunityFinalBtn_StatusButton = {"container": statusDesktop_mainWindow_overlay, "objectName": "createCommunityFinalBtn", "type": "StatusButton", "visible": True}
createOrEditCommunityCategoryChannelList_StatusListView = {"container": statusDesktop_mainWindow_overlay, "objectName": "createOrEditCommunityCategoryChannelList", "type": "StatusListView", "visible": True}
croppedImageLogo = {"container": statusDesktop_mainWindow_overlay, "objectName": "editCroppedImageItem_Community logo", "type": "EditCroppedImagePanel", "visible": True}
croppedImageBanner = {"container": statusDesktop_mainWindow_overlay, "objectName": "editCroppedImageItem_Community banner", "type": "EditCroppedImagePanel", "visible": True}

# Community Channel Popup
createOrEditCommunityChannelNameInput_TextEdit = {"container": statusDesktop_mainWindow_overlay, "objectName": "createOrEditCommunityChannelNameInput", "type": "TextEdit", "visible": True}
createOrEditCommunityChannelDescriptionInput_TextEdit = {"container": statusDesktop_mainWindow_overlay, "objectName": "createOrEditCommunityChannelDescriptionInput", "type": "TextEdit", "visible": True}
createOrEditCommunityChannelBtn_StatusButton = {"container": statusDesktop_mainWindow_overlay, "objectName": "createOrEditCommunityChannelBtn", "type": "StatusButton", "visible": True}
createOrEditCommunityChannel_EmojiButton = {"container": statusDesktop_mainWindow_overlay, "objectName": "StatusChannelPopup_emojiButton", "type": "StatusRoundButton", "visible": True}
add_permission_StatusButton = {"checkable": False, "container": statusDesktop_mainWindow_overlay, "objectName": "addPermissionButton", "type": "StatusButton", "visible": True}
hide_channel_checkbox = {"checkable": True, "container": statusDesktop_mainWindow_overlay, "objectName": "hideChannelCheckbox", "type": "StatusCheckBox", "visible": True}

# Community Category Popup
createOrEditCommunityCategoryNameInput_TextEdit = {"container": statusDesktop_mainWindow_overlay, "objectName": "createOrEditCommunityCategoryNameInput", "type": "TextEdit", "visible": True}
category_item_name_general_StatusListItem = {"container": statusDesktop_mainWindow_overlay, "objectName": "category_item_name_general", "type": "StatusListItem", "visible": True}
create_StatusButton = {"checkable": False, "container": statusDesktop_mainWindow_overlay, "objectName": "createOrEditCommunityCategoryBtn", "type": "StatusButton", "visible": True}
channelItemCheckbox_StatusCheckBox = {"checkable": True, "container": statusDesktop_mainWindow_overlay, "id": "channelItemCheckbox", "type": "StatusCheckBox", "unnamed": 1, "visible": True}
delete_Category_StatusButton = {"checkable": False, "container": statusDesktop_mainWindow_overlay, "type": "StatusButton", "unnamed": 1, "visible": True}
save_StatusButton = {"checkable": False, "container": statusDesktop_mainWindow_overlay, "objectName": "createOrEditCommunityCategoryBtn", "type": "StatusButton", "visible": True}

# Invite Contacts Popup
communityProfilePopupInviteFrindsPanel = {"container": statusDesktop_mainWindow_overlay, "objectName": "CommunityProfilePopupInviteFrindsPanel_ColumnLayout", "type": "ProfilePopupInviteFriendsPanel", "visible": True}
communityProfilePopupInviteMessagePanel = {"container": statusDesktop_mainWindow_overlay, "objectName": "CommunityProfilePopupInviteMessagePanel_ColumnLayout", "type": "ProfilePopupInviteMessagePanel", "visible": True}
o_StatusMemberListItem = {"container": communityProfilePopupInviteFrindsPanel, "type": "StatusMemberListItem", "unnamed": 1, "visible": True}
next_StatusButton = {"checkable": False, "container": statusDesktop_mainWindow_overlay, "objectName": "InviteFriendsToCommunityPopup_NextButton", "text": "Next", "type": "StatusButton", "visible": True}
communityProfilePopupInviteMessagePanel_MessageInput_TextEdit = {"container": communityProfilePopupInviteMessagePanel, "objectName": "CommunityProfilePopupInviteMessagePanel_MessageInput", "type": "TextEdit", "visible": True}
send_1_invite_StatusButton = {"checkable": False, "container": statusDesktop_mainWindow_overlay, "objectName": "InviteFriendsToCommunityPopup_SendButton", "text": "Send 1 invite", "type": "StatusButton", "visible": True}
o_StatusMemberListItem_2 = {"container": communityProfilePopupInviteMessagePanel, "type": "StatusMemberListItem", "unnamed": 1, "visible": True}
copy_icon_StatusIcon = {"container": statusDesktop_mainWindow_overlay, "objectName": "copy-icon", "type": "StatusIcon", "visible": True}

# Welcome community
o_ColumnLayout = {"container": statusDesktop_mainWindow_overlay, "type": "ColumnLayout", "unnamed": 1, "visible": True}
headerTitle_StatusBaseText = {"container": statusDesktop_mainWindow_overlay, "objectName": "headerTitle", "type": "StatusBaseText", "visible": True}
image_StatusImage = {"container": statusDesktop_mainWindow_overlay, "id": "image", "type": "StatusImage", "unnamed": 1, "visible": True}
intro_StatusBaseText = {"container": o_ColumnLayout, "type": "StatusBaseText", "unnamed": 1, "visible": True}
select_addresses_to_share_StatusFlatButton = {"container": statusDesktop_mainWindow_overlay, "type": "StatusFlatButton", "unnamed": 1, "visible": True}
join_StatusButton = { "container": statusDesktop_mainWindow_overlay, "type": "StatusButton", "unnamed": 1, "visible": True}
welcome_authenticate_StatusButton = {"container": statusDesktop_mainWindow_overlay, "type": "StatusButton", "unnamed": 1, "visible": True}
share_your_addresses_to_join_StatusButton = {"container": statusDesktop_mainWindow_overlay, "type": "StatusButton", "unnamed": 1, "visible": True}

# Kick member popup
confirm_kick_StatusButton = {"checkable": False, "container": statusDesktop_mainWindow_overlay, "objectName": "CommunityMembers_KickModal_KickButton", "type": "StatusButton", "visible": True}

# Ban member popup
ban_StatusButton = {"checkable": False, "container": statusDesktop_mainWindow_overlay, "objectName": "CommunityMembers_BanModal_BanButton", "type": "StatusButton", "visible": True}

# Pinned messages
unpinButton_StatusFlatRoundButton = {"container": statusDesktop_mainWindow_overlay, "id": "unpinButton", "type": "StatusFlatRoundButton", "unnamed": 1, "visible": True}
headerActionsCloseButton_StatusFlatRoundButton = {"container": statusDesktop_mainWindow_overlay, "objectName": "headerActionsCloseButton", "type": "StatusFlatRoundButton", "visible": True}
o_StatusPinMessageDetails = {"container": statusDesktop_mainWindow_overlay, "type": "StatusPinMessageDetails", "unnamed": 1, "visible": True}

""" Settings """

# Send Contact Request
sendContactRequestModal_ChatKey_Input_TextEdit = {"container": statusDesktop_mainWindow_overlay, "objectName": "SendContactRequestModal_ChatKey_Input", "type": "TextEdit", "visible": True}
sendContactRequestModal_SayWhoYouAre_Input_TextEdit = {"container": statusDesktop_mainWindow_overlay, "objectName": "SendContactRequestModal_SayWhoYouAre_Input", "type": "TextEdit", "visible": True}
send_Contact_Request_StatusButton = {"container": statusDesktop_mainWindow_overlay, "objectName": "SendContactRequestModal_Send_Button", "type": "StatusButton", "visible": True}
send_contact_request_StatusButton_2 = {"checkable": False, "container": statusDesktop_mainWindow_overlay, "objectName": "ProfileSendContactRequestModal_sendContactRequestButton", "type": "StatusButton", "visible": True}
profileSendContactRequestModal_sayWhoYouAreInput_TextEdit = {"container": statusDesktop_mainWindow_overlay, "objectName": "ProfileSendContactRequestModal_sayWhoYouAreInput", "type": "TextEdit", "visible": True}

# Review Contact Request
ignore_StatusFlatButton = {"checkable": False, "container": statusDesktop_mainWindow_overlay, "objectName": "ignoreButton", "type": "StatusFlatButton", "visible": True}
accept_StatusButton = {"checkable": False, "container": statusDesktop_mainWindow_overlay, "objectName": "acceptButton", "type": "StatusButton", "visible": True}

# RemoveContactPopup
remove_contact_StatusButton = {"checkable": False, "container": statusDesktop_mainWindow_overlay, "objectName": "removeContactButton", "type": "StatusButton", "visible": True}

# Kick member popup
confirm_kick_StatusButton = {"checkable": False, "container": statusDesktop_mainWindow_overlay, "objectName": "CommunityMembers_KickModal_KickButton", "type": "StatusButton", "visible": True}

# Block user popup
blockWarningBox_StatusWarningBox = {"container": statusDesktop_mainWindow_overlay, "objectName": "blockWarningBox", "type": "StatusWarningBox", "visible": True}
youWillNotSeeText_StatusBaseText = {"container": statusDesktop_mainWindow_overlay, "objectName": "youWillNotSeeText", "type": "StatusBaseText", "visible": True}
block_StatusButton = {"checkable": False, "container": statusDesktop_mainWindow_overlay, "objectName": "blockButton", "type": "StatusButton", "visible": True}
cancel_StatusFlatButton = {"checkable": False, "container": statusDesktop_mainWindow_overlay, "objectName": "cancelButton", "type": "StatusFlatButton", "visible": True}

# Unblock user popup
unblock_StatusButton = {"checkable": False, "container": statusDesktop_mainWindow_overlay, "objectName": "unblockUserButton", "type": "StatusButton", "visible": True}
unblockingText_StatusBaseText = {"container": statusDesktop_mainWindow_overlay, "objectName": "unblockingText", "type": "StatusBaseText", "visible": True}
cancel_StatusFlatButton_unblock = {"checkable": False, "container": statusDesktop_mainWindow_overlay, "objectName": "cancelButton", "type": "StatusFlatButton", "visible": True}

""" Common """

edit_TextEdit = {"container": statusDesktop_mainWindow_overlay, "type": "TextEdit", "unnamed": 1, "visible": True}

# Select Color Popup
communitySettings_ColorPanel_HexColor_Input = {"container": statusDesktop_mainWindow_overlay, "objectName": "communityColorPanelHexInput", "type": "TextEdit", "visible": True}
communitySettings_SaveColor_Button = {"container": statusDesktop_mainWindow_overlay, "objectName": "communityColorPanelSelectColorButton", "type": "StatusButton", "visible": True}

# Select Tag Popup
o_StatusCommunityTag = {"container": statusDesktop_mainWindow_overlay, "type": "StatusCommunityTag", "unnamed": 1, "visible": True}
confirm_Community_Tags_StatusButton = {"checkable": False, "container": statusDesktop_mainWindow_overlay, "objectName": "confirmCommunityTagsButton", "type": "StatusButton", "visible": True}
tags_edit_TextEdit = {"container": statusDesktop_mainWindow_overlay, "id": "edit", "type": "TextEdit", "unnamed": 1, "visible": True}
selected_tags_text = {"container": statusDesktop_mainWindow_overlay, "type": "StatusBaseText", "unnamed": 1, "visible": True}

# Signing phrase popup
signPhrase_Ok_Button = {"container": statusDesktop_mainWindow, "type": "StatusFlatButton", "objectName": "signPhraseModalOkButton", "visible": True}

# Sign transaction popup
cancel_transaction_StatusButton = {"checkable": False, "container": statusDesktop_mainWindow_overlay, "objectName": "cancelButton", "text": "Cancel", "type": "StatusButton", "visible": True}
sign_transaction_StatusButton = {"checkable": False, "container": statusDesktop_mainWindow_overlay, "objectName": "signTransactionButton", "text": "Sign transaction", "type": "StatusButton", "visible": True}
o_FeeRow = {"container": statusDesktop_mainWindow_overlay, "type": "FeeRow", "unnamed": 1, "visible": True}
feeTotalRow_FeeRow = {"container": statusDesktop_mainWindow_overlay, "id": "feeTotalRow", "type": "FeeRow", "unnamed": 1, "visible": True}

# Remove account popup:
mainWallet_Remove_Account_Popup_Account_Notification = {"container": statusDesktop_mainWindow, "objectName": "RemoveAccountPopup-Notification", "type": "StatusBaseText", "visible": True}
mainWallet_Remove_Account_Popup_Account_Path_Component = {"container": statusDesktop_mainWindow, "objectName": "RemoveAccountPopup-DerivationPath", "type": "StatusInput", "visible": True}
mainWallet_Remove_Account_Popup_Account_Path = {"container": mainWallet_Remove_Account_Popup_Account_Path_Component, "type": "TextEdit", "unnamed": 1, "visible": True}
mainWallet_Remove_Account_Popup_HavePenPaperCheckBox = {"checkable": True, "container": statusDesktop_mainWindow, "objectName": "RemoveAccountPopup-HavePenPaper", "type": "StatusCheckBox", "visible": True}
mainWallet_Remove_Account_Popup_ConfirmButton = {"container": statusDesktop_mainWindow, "objectName": "RemoveAccountPopup-ConfirmButton", "type": "StatusButton", "visible": True}
mainWallet_Remove_Account_Popup_CancelButton = {"container": statusDesktop_mainWindow, "objectName": "RemoveAccountPopup-CancelButton", "type": "StatusFlatButton", "visible": True}

# RPC change restart popup
save_and_restart_later_StatusFlatButton = {"checkable": False, "container": statusDesktop_mainWindow_overlay, "objectName": "laterButton", "type": "StatusFlatButton", "visible": True}
save_and_restart_Status_StatusButton = {"checkable": False, "container": statusDesktop_mainWindow_overlay, "objectName": "saveButton", "type": "StatusButton", "visible": True}
restart_required_StatusBaseText = {"container": statusDesktop_mainWindow_overlay, "objectName": "mustBeRestartedText","type": "StatusBaseText", "visible": True}

# Add saved address popup
mainWallet_Saved_Addreses_Popup_Name_Input = {"container": statusDesktop_mainWindow, "objectName": "savedAddressNameInput", "type": "TextEdit"}
mainWallet_Saved_Addreses_Popup_Address_Input = {"container": statusDesktop_mainWindow, "objectName": "savedAddressAddressInput", "type": "StatusInput"}
mainWallet_Saved_Addreses_Popup_Address_Input_Edit = {"container": statusDesktop_mainWindow, "objectName": "savedAddressAddressInputEdit", "type": "TextEdit"}
mainWallet_Saved_Addreses_Popup_Address_Add_Button = {"container": statusDesktop_mainWindow, "objectName": "addSavedAddress", "type": "StatusButton"}
mainWallet_Saved_Addreses_Popup_Add_Network_Selector = {"container": statusDesktop_mainWindow, "objectName": "addSavedAddressNetworkSelector", "type": "StatusNetworkSelector", "visible": True}
mainWallet_Saved_Addreses_Popup_Add_Network_Button = {"container": statusDesktop_mainWindow_overlay, "objectName": "addNetworkTagItemButton", "type": "StatusRoundButton", "visible": True}
addNetworkTagItemButton_StatusRoundButton = {"container": statusDesktop_mainWindow_overlay, "objectName": "addNetworkTagItemButton", "type": "StatusRoundButton", "visible": True}
networkTagRectangle_Add_networks_Rectangle = {"container": statusDesktop_mainWindow_overlay, "objectName": "networkTagRectangle_Add networks", "type": "Rectangle", "visible": True}
mainWallet_Saved_Addreses_Popup_Add_Network_Selector_Tag = {"container": statusDesktop_mainWindow_overlay, "objectName": "networkSelectorTag", "type": "StatusNetworkListItemTag"}
networkSelectionCheckbox_Ethereum_Mainnet_StatusCheckBox = {"checkable": True, "container": statusDesktop_mainWindow_overlay, "objectName": "networkSelectionCheckbox_Mainnet", "type": "StatusCheckBox", "visible": True}
networkSelectionCheckbox_Optimism_StatusCheckBox = {"checkable": True, "container": statusDesktop_mainWindow_overlay, "objectName": "networkSelectionCheckbox_Optimism", "type": "StatusCheckBox", "visible": True}
networkSelectionCheckbox_Arbitrum_StatusCheckBox = {"checkable": True, "container": statusDesktop_mainWindow_overlay, "objectName": "networkSelectionCheckbox_Arbitrum", "type": "StatusCheckBox", "visible": True}
mainWallet_Saved_Addresses_Popup_Network_Selector_Mainnet_network_tag = {"container": statusDesktop_mainWindow_overlay, "objectName": "networkTagRectangle_eth", "type": "Rectangle", "visible": True}
mainWallet_Saved_Addresses_Popup_Network_Selector_Optimism_network_tag = {"container": statusDesktop_mainWindow_overlay, "objectName": "networkTagRectangle_oeth", "type": "Rectangle", "visible": True}
mainWallet_Saved_Addresses_Popup_Network_Selector_Arbitrum_network_tag = {"container": statusDesktop_mainWindow_overlay, "objectName": "networkTagRectangle_arb1", "type": "Rectangle", "visible": True}

# Context Menu
contextMenu_PopupItem = {"container": statusDesktop_mainWindow_overlay, "type": "PopupItem", "unnamed": 1, "visible": True}
contextMenuItem = {"container": statusDesktop_mainWindow_overlay, "type": "StatusBaseText", "unnamed": 1, "visible": True}
contextMenuItem_AddWatchOnly = {"container": statusDesktop_mainWindow_overlay, "enabled": True, "objectName": RegularExpression("AccountMenu-AddWatchOnlyAccountAction*"), "type": "StatusMenuItem", "visible": True}
contextMenuItem_Delete = {"container": statusDesktop_mainWindow_overlay, "enabled": True, "objectName": RegularExpression("AccountMenu-DeleteAction*"), "type": "StatusMenuItem", "visible": True}
contextMenuItem_Edit = {"container": statusDesktop_mainWindow_overlay, "enabled": True, "objectName": RegularExpression("AccountMenu-EditAction*"), "type": "StatusMenuItem", "visible": True}
contextMenuItem_Copy_Address = {"container": statusDesktop_mainWindow_overlay, "enabled": True, "objectName": RegularExpression("AccountMenu-CopyAddressAction*"), "type": "StatusSuccessAction", "visible": True}
contextMenuItem_HideInclude = {"container": statusDesktop_mainWindow_overlay, "enabled": True, "objectName": RegularExpression("AccountMenu-HideFromTotalBalance*"), "type": "StatusMenuItem", "visible": True}
contextSavedAddressEdit = {"container": statusDesktop_mainWindow, "objectName": "editSavedAddress", "type": "StatusMenuItem", "visible": True}
contextSavedAddressDelete = {"container": statusDesktop_mainWindow, "objectName": "deleteSavedAddress", "type": "StatusMenuItem", "visible": True}

# Confirmation Popup
confirmButton = {"container": statusDesktop_mainWindow_overlay, "objectName": RegularExpression("confirm*"), "type": "StatusButton"}
mainWallet_Saved_Addresses_More_Confirm_Delete = {"container": statusDesktop_mainWindow, "objectName": "RemoveSavedAddressPopup-ConfirmButton", "type": "StatusButton"}
mainWallet_Saved_Addresses_More_Confirm_Cancel = {"container": statusDesktop_mainWindow, "objectName": "RemoveSavedAddressPopup-CancelButton", "type": "StatusFlatButton"}
mainWallet_Saved_Addresses_More_Confirm_Notification = {"container": statusDesktop_mainWindow, "objectName": "RemoveSavedAddressPopup-Notification", "type": "StatusBaseText"}

# Picture Edit Popup
o_StatusSlider = {"container": statusDesktop_mainWindow_overlay, "type": "StatusSlider", "unnamed": 1, "visible": True}
cropSpaceItem_Item = {"container": statusDesktop_mainWindow_overlay, "id": "cropSpaceItem", "type": "Item", "unnamed": 1, "visible": True}
make_picture_StatusButton = {"checkable": False, "container": statusDesktop_mainWindow_overlay, "objectName": "imageCropperAcceptButton", "type": "StatusButton", "visible": True}
o_DropShadow = {"container": statusDesktop_mainWindow_overlay, "type": "DropShadow", "unnamed": 1, "visible": True}

# Emoji Popup
mainWallet_AddEditAccountPopup_AccountEmojiSearchBox = {"container": statusDesktop_mainWindow, "objectName": "StatusEmojiPopup_searchBox", "type": "TextEdit", "visible": True}
mainWallet_AddEditAccountPopup_AccountEmoji = {"container": statusDesktop_mainWindow, "type": "StatusEmoji", "visible": True}

# Delete Popup
o_StatusDialogBackground = {"container": statusDesktop_mainWindow_overlay, "type": "StatusDialogBackground", "unnamed": 1, "visible": True}
delete_StatusButton = {"checkable": False, "container": statusDesktop_mainWindow_overlay, "objectName": "deleteChatConfirmationDialogDeleteButton", "type": "StatusButton", "visible": True}
confirm_StatusButton = {"checkable": False, "container": statusDesktop_mainWindow_overlay, "objectName": "confirmDeleteCategoryButton", "type": "StatusButton", "visible": True}
confirm_permission_delete_StatusButton = {"checkable": False, "container": statusDesktop_mainWindow_overlay, "id": "confirmButton", "type": "StatusButton", "unnamed": 1, "visible": True}
confirm_delete_message_StatusButton = {"checkable": False, "container": statusDesktop_mainWindow_overlay, "objectName": "chatButtonsPanelConfirmDeleteMessageButton", "text": "Confirm", "type": "StatusButton", "visible": True}

# Authenticate Popup
keycardSharedPopupContent_KeycardPopupContent = {"container": statusDesktop_mainWindow_overlay, "objectName": "KeycardSharedPopupContent", "type": "KeycardPopupContent", "visible": True}
password_PlaceholderText = {"container": statusDesktop_mainWindow_overlay, "type": "PlaceholderText", "unnamed": 1, "visible": True}
authenticate_StatusButton = {"container": statusDesktop_mainWindow_overlay, "objectName": "PrimaryButton", "type": "StatusButton", "visible": True}
headerCloseButton_StatusFlatRoundButton = {"container": statusDesktop_mainWindow_overlay, "objectName": "headerCloseButton", "type": "StatusFlatRoundButton", "visible": True}

# Shared Popup
sharedPopup_Popup_Content = {"container": statusDesktop_mainWindow, "objectName": "KeycardSharedPopupContent", "type": "Item"}
sharedPopup_Password_Input = {"container": sharedPopup_Popup_Content, "objectName": "keycardPasswordInput", "type": "TextField"}
sharedPopup_Primary_Button = {"container": statusDesktop_mainWindow, "objectName": "PrimaryButton", "type": "StatusButton", "visible": True, "enabled": True}

# Wallet Account Popup
mainWallet_AddEditAccountPopup_derivationPath = {"container": statusDesktop_mainWindow, "objectName": RegularExpression("AddAccountPopup-PreDefinedDerivationPath*"), "type": "StatusListItem", "visible": True}
mainWallet_Address_Panel = {"container": statusDesktop_mainWindow, "objectName": "addressPanel", "type": "StatusAddressPanel", "visible": True}
addAccountPopup_GeneratedAddress = {"container": statusDesktop_mainWindow_overlay_popup2, "type": "Rectangle", "visible": True}
address_0x_StatusBaseText = {"container": statusDesktop_mainWindow_overlay_popup2, "text": RegularExpression("0x*"), "type": "StatusBaseText", "unnamed": 1, "visible": True}
addAccountPopup_GeneratedAddressesListPageIndicatior_StatusPageIndicator = {"container": statusDesktop_mainWindow_overlay_popup2, "objectName": "AddAccountPopup-GeneratedAddressesListPageIndicatior", "type": "StatusPageIndicator", "visible": True}
page_StatusBaseButton = {"checkable": False, "container": addAccountPopup_GeneratedAddressesListPageIndicatior_StatusPageIndicator, "objectName": RegularExpression("Page-*"), "type": "StatusBaseButton", "visible": True}
mainWindow_DisabledTooltipButton = {"container": statusDesktop_mainWindow, "type": "DisabledTooltipButton", "icon": "send", "visible": True}

# Add/Edit account popup:
grid_Grid = {"container": statusDesktop_mainWindow_overlay, "id": "grid", "type": "Grid", "unnamed": 1, "visible": True}
color_StatusColorRadioButton = {"checkable": True, "container": statusDesktop_mainWindow_overlay, "type": "StatusColorRadioButton", "unnamed": 1, "visible": True}

mainWallet_AddEditAccountPopup_Content = {"container": statusDesktop_mainWindow, "objectName": "AddAccountPopup-Content", "type": "Item", "visible": True}
mainWallet_AddEditAccountPopup_PrimaryButton = {"container": statusDesktop_mainWindow, "objectName": "AddAccountPopup-PrimaryButton", "type": "StatusButton", "visible": True}
mainWallet_AddEditAccountPopup_BackButton = {"container": statusDesktop_mainWindow, "objectName": "AddAccountPopup-BackButton", "type": "StatusBackButton", "visible": True}
mainWallet_AddEditAccountPopup_AccountNameComponent = {"container": mainWallet_AddEditAccountPopup_Content, "objectName": "AddAccountPopup-AccountName", "type": "StatusInput", "visible": True}
mainWallet_AddEditAccountPopup_AccountName = {"container": mainWallet_AddEditAccountPopup_AccountNameComponent, "type": "TextEdit", "unnamed": 1, "visible": True}
mainWallet_AddEditAccountPopup_HeaderTitle = {"container": statusDesktop_mainWindow_overlay, "objectName": "headerTitle", "type": "StatusBaseText", "visible": True}
mainWallet_AddEditAccountPopup_Status_Identicon = {"container": statusDesktop_mainWindow_overlay, "objectName": "statusSmartIdenticonLetter", "type": "StatusLetterIdenticon", "visible": True}
mainWallet_AddEditAccountPopup_HeaderEmoji = {"container": mainWallet_AddEditAccountPopup_Status_Identicon, "type": "StatusEmoji", "unnamed": 1, "visible": True}
mainWallet_AddEditAccountPopup_AccountColorComponent = {"container": mainWallet_AddEditAccountPopup_Content, "objectName": "AddAccountPopup-AccountColor", "type": "StatusColorSelectorGrid", "visible": True}
mainWallet_AddEditAccountPopup_AccountColorSelector = {"container": mainWallet_AddEditAccountPopup_AccountColorComponent, "type": "Repeater", "objectName": "statusColorRepeater", "visible": True, "enabled": True}
mainWallet_AddEditAccountPopup_AccountEmojiPopupButton = {"container": mainWallet_AddEditAccountPopup_Content, "objectName": "AddAccountPopup-AccountEmoji", "type": "StatusFlatRoundButton", "visible": True}
mainWallet_AddEditAccountPopup_SelectedOrigin = {"container": mainWallet_AddEditAccountPopup_Content, "objectName": "AddAccountPopup-SelectedOrigin", "type": "StatusListItem", "visible": True}
mainWallet_AddEditAccountPopup_OriginOption_Placeholder = {"container": statusDesktop_mainWindow, "objectName": "AddAccountPopup-OriginOption-%NAME%", "type": "StatusListItem", "visible": True}
mainWallet_AddEditAccountPopup_OriginOptionNewMasterKey = {"container": statusDesktop_mainWindow, "objectName": "AddAccountPopup-OriginOption-LABEL-OPTION-ADD-NEW-MASTER-KEY", "type": "StatusListItem", "visible": True}
addAccountPopup_OriginOption_StatusListItem = {"container": statusDesktop_mainWindow_overlay, "type": "StatusListItem", "visible": True}

mainWallet_AddEditAccountPopup_OriginOptionWatchOnlyAcc = {"container": statusDesktop_mainWindow, "objectName": "AddAccountPopup-OriginOption-LABEL-OPTION-ADD-WATCH-ONLY-ACC", "type": "StatusListItem", "visible": True}
mainWallet_AddEditAccountPopup_AccountWatchOnlyAddressComponent = {"container": mainWallet_AddEditAccountPopup_Content, "objectName": "AddAccountPopup-WatchOnlyAddress", "type": "StatusInput", "visible": True}
mainWallet_AddEditAccountPopup_AccountWatchOnlyAddress = {"container": mainWallet_AddEditAccountPopup_AccountWatchOnlyAddressComponent, "type": "TextEdit", "unnamed": 1, "visible": True}
mainWallet_AddEditAccountPopup_CopyDerivationPathButton = {"container": statusDesktop_mainWindow, "objectName": "copy-icon", "type": "CopyButton", "visible": True}
mainWallet_AddEditAccountPopup_EditDerivationPathButton = {"container": statusDesktop_mainWindow, "objectName": "AddAccountPopup-EditDerivationPath", "type": "StatusButton", "visible": True}
mainWallet_AddEditAccountPopup_ResetDerivationPathButton = {"container": statusDesktop_mainWindow, "objectName": "AddAccountPopup-ResetDerivationPath", "type": "StatusLinkText", "enabled": True, "visible": True}
mainWallet_AddEditAccountPopup_DerivationPathInputComponent = {"container": statusDesktop_mainWindow, "objectName": "AddAccountPopup-DerivationPathInput", "type": "DerivationPathInput", "visible": True}
mainWallet_AddEditAccountPopup_DerivationPathInput = {"container": mainWallet_AddEditAccountPopup_DerivationPathInputComponent, "type": "TextEdit", "unnamed": 1, "visible": True}
mainWallet_AddEditAccountPopup_PreDefinedDerivationPathsButton = {"container": mainWallet_AddEditAccountPopup_DerivationPathInputComponent, "objectName": "chevron-down-icon", "type": "StatusIcon", "visible": True}
mainWallet_AddEditAccountPopup_GeneratedAddressComponent = {"container": statusDesktop_mainWindow, "objectName": "AddAccountPopup-GeneratedAddress", "type": "StatusListItem", "visible": True}
mainWallet_AddEditAccountPopup_NonEthDerivationPathCheckBox = {"checkable": True, "container": statusDesktop_mainWindow, "objectName": "AddAccountPopup-ConfirmAddingNonEthDerivationPath", "type": "StatusCheckBox", "visible": True}
mainWallet_AddEditAccountPopup_MasterKey_ImportPrivateKeyOption = {"container": mainWallet_AddEditAccountPopup_Content, "objectName": "AddAccountPopup-ImportPrivateKey", "type": "StatusListItem", "visible": True}
mainWallet_AddEditAccountPopup_PrivateKey = {"container": mainWallet_AddEditAccountPopup_Content, "objectName": "AddAccountPopup-PrivateKeyInput", "type": "StatusPasswordInput", "visible": True}
mainWallet_AddEditAccountPopup_PrivateKeyNameComponent = {"container": mainWallet_AddEditAccountPopup_Content, "objectName": "AddAccountPopup-PrivateKeyName", "type": "StatusInput", "visible": True}
mainWallet_AddEditAccountPopup_PrivateKeyName = {"container": mainWallet_AddEditAccountPopup_PrivateKeyNameComponent, "type": "TextEdit", "unnamed": 1, "visible": True}
mainWallet_AddEditAccountPopup_MasterKey_GoToKeycardSettingsOption = {"container": mainWallet_AddEditAccountPopup_Content, "objectName": "AddAccountPopup-GoToKeycardSettings", "type": "StatusButton", "visible": True}
mainWallet_AddEditAccountPopup_MasterKey_ImportSeedPhraseOption = {"container": mainWallet_AddEditAccountPopup_Content, "objectName": "AddAccountPopup-ImportUsingSeedPhrase", "type": "StatusListItem", "visible": True}
mainWallet_AddEditAccountPopup_MasterKey_GenerateSeedPhraseOption = {"container": mainWallet_AddEditAccountPopup_Content, "objectName": "AddAccountPopup-GenerateNewMasterKey", "type": "StatusListItem", "visible": True}
mainWallet_AddEditAccountPopup_ImportedSeedPhraseKeyNameComponent = {"container": mainWallet_AddEditAccountPopup_Content, "objectName": "AddAccountPopup-ImportedSeedPhraseKeyName", "type": "StatusInput", "visible": True}
mainWallet_AddEditAccountPopup_ImportedSeedPhraseKeyName = {"container": mainWallet_AddEditAccountPopup_ImportedSeedPhraseKeyNameComponent, "type": "TextEdit", "unnamed": 1, "visible": True}
mainWallet_AddEditAccountPopup_GeneratedSeedPhraseKeyNameComponent = {"container": mainWallet_AddEditAccountPopup_Content, "objectName": "AddAccountPopup-GeneratedSeedPhraseKeyName", "type": "StatusInput", "visible": True}
mainWallet_AddEditAccountPopup_GeneratedSeedPhraseKeyName = {"container": mainWallet_AddEditAccountPopup_GeneratedSeedPhraseKeyNameComponent, "type": "TextEdit", "unnamed": 1, "visible": True}
mainWallet_AddEditAccountPopup_HavePenAndPaperCheckBox = {"checkable": True, "container": mainWallet_AddEditAccountPopup_Content, "objectName": "AddAccountPopup-HavePenAndPaper", "type": "StatusCheckBox", "visible": True}
mainWallet_AddEditAccountPopup_SeedPhraseWrittenCheckBox = {"checkable": True, "container": mainWallet_AddEditAccountPopup_Content, "objectName": "AddAccountPopup-SeedPhraseWritten", "type": "StatusCheckBox", "visible": True}
mainWallet_AddEditAccountPopup_StoringSeedPhraseConfirmedCheckBox = {"checkable": True, "container": mainWallet_AddEditAccountPopup_Content, "objectName": "AddAccountPopup-StoringSeedPhraseConfirmed", "type": "StatusCheckBox", "visible": True}
mainWallet_AddEditAccountPopup_SeedBackupAknowledgeCheckBox = {"checkable": True, "container": mainWallet_AddEditAccountPopup_Content, "objectName": "AddAccountPopup-SeedBackupAknowledge", "type": "StatusCheckBox", "visible": True}
mainWallet_AddEditAccountPopup_RevealSeedPhraseButton = {"container": mainWallet_AddEditAccountPopup_Content, "objectName": "AddAccountPopup-RevealSeedPhrase", "type": "StatusButton", "visible": True}
mainWallet_AddEditAccountPopup_SeedPhraseWordAtIndex_Placeholder = {"container": mainWallet_AddEditAccountPopup_Content, "objectName": "SeedPhraseWordAtIndex-%WORD-INDEX%", "type": "StatusSeedPhraseInput", "visible": True}
mainWallet_AddEditAccountPopup_EnterSeedPhraseWordComponent = {"container": mainWallet_AddEditAccountPopup_Content, "objectName": "AddAccountPopup-EnterSeedPhraseWord", "type": "StatusInput", "visible": True}
mainWallet_AddEditAccountPopup_EnterSeedPhraseWord = {"container": mainWallet_AddEditAccountPopup_EnterSeedPhraseWordComponent, "type": "TextEdit", "unnamed": 1, "visible": True}
mainWallet_AddEditAccountPopup_12WordsButton = {"container": mainWallet_AddEditAccountPopup_Content, "objectName": "12SeedButton", "type": "StatusSwitchTabButton"}
mainWallet_AddEditAccountPopup_18WordsButton = {"container": mainWallet_AddEditAccountPopup_Content, "objectName": "18SeedButton", "type": "StatusSwitchTabButton"}
mainWallet_AddEditAccountPopup_24WordsButton = {"container": mainWallet_AddEditAccountPopup_Content, "objectName": "24SeedButton", "type": "StatusSwitchTabButton"}
enterSeedPhraseInvalidSeedText_StatusBaseText = {"container": statusDesktop_mainWindow_overlay, "objectName": "enterSeedPhraseInvalidSeedText", "type": "StatusBaseText", "visible": True}
addAccountPopup_ImportedSeedPhraseKeyName_StatusInput = {"container": statusDesktop_mainWindow_overlay, "objectName": "AddAccountPopup-ImportedSeedPhraseKeyName", "type": "StatusInput", "visible": True}
addAccountPopup_PrivateKeyName_StatusInput = {"container": statusDesktop_mainWindow_overlay, "objectName": "AddAccountPopup-PrivateKeyName", "type": "StatusInput", "visible": True}

# Edit Account from settings popup
editWalletSettings_renameButton = {"container": statusDesktop_mainWindow_overlay, "objectName": "renameAccountModalSaveBtn", "type": "StatusButton"}
editWalletSettings_AccountNameInput = {"container": statusDesktop_mainWindow_overlay, "objectName": "renameAccountNameInput", "type": "TextEdit", "visible": True}
editWalletSettings_EmojiSelector = {"container": statusDesktop_mainWindow_overlay, "objectName": "statusSmartIdenticonLetter", "type": "StatusLetterIdenticon", "visible": True}
editWalletSettings_ColorSelector = {"container": statusDesktop_mainWindow_overlay, "type": "StatusColorRadioButton", "unnamed": 1, "visible": True}
editWalletSettings_EmojiItem = {"container": statusDesktop_mainWindow_overlay, "objectName": RegularExpression("statusEmoji_*"), "type": "StatusEmoji"}

# Remove Account from settings popup
removeConfirmationCrossCloseButton = {"container": statusDesktop_mainWindow_overlay, "objectName": "close-icon", "type": "StatusIcon", "visible": True}
removeConfirmationTextTitle = {"container": statusDesktop_mainWindow_overlay, "objectName": "headerTitle", "type": "StatusBaseText", "visible": True}
removeConfirmationTextBody = {"container": statusDesktop_mainWindow_overlay, "type": "StatusBaseText", "unnamed": 1, "visible": True}
removeConfirmationRemoveButton = {"container": statusDesktop_mainWindow_overlay, "objectName": RegularExpression("confirm*"), "type": "StatusButton"}
removeConfirmationAgreementCheckBox = {"container": statusDesktop_mainWindow_overlay, "objectName": "RemoveAccountPopup-HavePenPaper", "type": "StatusCheckBox"}
removeConfirmationConfirmButton = {"checkable": False, "container": statusDesktop_mainWindow_overlay, "objectName": "RemoveAccountPopup-ConfirmButton", "type": "StatusButton"}

# Testnet mode popup
turn_on_testnet_mode_StatusButton = {"container": statusDesktop_mainWindow_overlay, "id": "acceptBtn", "text": "Turn on testnet mode", "type": "StatusButton", "unnamed": 1, "visible": True}
turn_off_testnet_mode_StatusButton = {"container": statusDesktop_mainWindow_overlay, "id": "acceptBtn", "text": "Turn off testnet mode", "type": "StatusButton", "unnamed": 1, "visible": True}
testnet_mode_cancelButton = {"container": statusDesktop_mainWindow_overlay, "type": "StatusButton", "unnamed": 1, "visible": True}

# Testnet mode banner
mainWindow_testnetBanner_ModuleWarning = {"container": statusDesktop_mainWindow, "objectName": "testnetBanner", "type": "ModuleWarning", "visible": True}
mainWindow_Turn_off_Button = {"checkable": False, "container": statusDesktop_mainWindow, "id": "button", "text": "Turn off", "type": "Button", "unnamed": 1, "visible": True}

# Toast message
ephemeral_Notification_List = {"container": statusDesktop_mainWindow, "objectName": "ephemeralNotificationList", "type": "StatusListView"}
ephemeralNotificationList_StatusToastMessage = {"container": ephemeral_Notification_List, "objectName": "statusToastMessage", "type": "StatusToastMessage"}

# Change password view

settingsContentBase_ScrollView = {"container": statusDesktop_mainWindow, "objectName": "settingsContentBaseScrollView", "type": "StatusScrollView", "visible": True}
change_password_menu_current_password = {"container": settingsContentBase_ScrollView, "objectName": "passwordViewCurrentPassword", "type": "StatusPasswordInput", "visible": True}
change_password_menu_new_password = {"container": settingsContentBase_ScrollView, "objectName": "passwordViewNewPassword", "type": "StatusPasswordInput", "visible": True}
change_password_menu_new_password_confirm = {"container": settingsContentBase_ScrollView, "objectName": "passwordViewNewPasswordConfirm", "type": "StatusPasswordInput", "visible": True}
change_password_menu_change_password_button = {"container": settingsContentBase_ScrollView, "objectName": "changePasswordModalSubmitButton", "type": "StatusButton", "visible": True}
reEncryptRestartButton = {"container": statusDesktop_mainWindow_overlay, "objectName": "changePasswordModalSubmitButton", "type": "StatusButton", "visible": True}
reEncryptionComplete = {"container": statusDesktop_mainWindow_overlay, "objectName": "statusListItemSubTitle", "type": "StatusTextWithLoadingState", "visible": True}

# Social Links Popup
socialLink_StatusListItem = {"container": statusDesktop_mainWindow_overlay, "index": 1, "type": "StatusListItem", "unnamed": 1, "visible": True}
placeholder_StatusBaseText = {"container": statusDesktop_mainWindow_overlay, "id": "placeholder", "type": "StatusBaseText", "unnamed": 1, "visible": True}
social_links_back_StatusBackButton = {"container": statusDesktop_mainWindow_overlay, "type": "StatusBackButton", "unnamed": 1, "visible": True}
social_links_add_StatusBackButton = {"checkable": False, "container": statusDesktop_mainWindow_overlay, "objectName": "addButton", "type": "StatusButton", "visible": True}
linksView = {"container": statusDesktop_mainWindow, "id": "linksView", "type": "StatusListView", "unnamed": 1, "visible": True}

# Changes detected popup
mainWindow_settingsDirtyToastMessage_SettingsDirtyToastMessage = {"container": ":statusDesktop_mainWindow", "id": "settingsDirtyToastMessage", "type": "SettingsDirtyToastMessage", "unnamed": 1, "visible": True}

# Confirm switch waku mode popup
iUnderstandStatusButton = {"checkable": False, "container": statusDesktop_mainWindow_overlay, "id": "confirmButton", "type": "StatusButton", "unnamed": 1, "visible": True}

# Back up seed phrase banner
mainWindow_secureYourSeedPhraseBanner_ModuleWarning = {"container": statusDesktop_mainWindow, "objectName": "secureYourSeedPhraseBanner", "type": "ModuleWarning", "visible": True}
mainWindow_secureYourSeedPhraseBanner_Button = {"container": statusDesktop_mainWindow, "id": "button", "text": "Back up now", "type": "Button", "unnamed": 1, "visible": True}

# Sync new device popup
copy_SyncCodeStatusButton = {"container": statusDesktop_mainWindow_overlay, "objectName": "syncCodeCopyButton", "type": "StatusButton", "visible": True}
done_SyncCodeStatusButton = {"container": statusDesktop_mainWindow_overlay, "objectName": "syncAnewDeviceNextButton", "type": "StatusButton", "visible": True}
syncCodeInput_StatusPasswordInput = {"container": statusDesktop_mainWindow_overlay, "id": "syncCodeInput", "type": "StatusPasswordInput", "unnamed": 1, "visible": True}
close_StatusButton = {"checkable": False, "container": statusDesktop_mainWindow_overlay, "objectName": "syncAnewDeviceNextButton", "type": "StatusButton", "visible": True}
errorView_SyncingErrorMessage = {"container": statusDesktop_mainWindow_overlay, "id": "errorView", "type": "SyncingErrorMessage", "unnamed": 1, "visible": True}

# Edit group name and image popup
groupChatEdit_name_TextEdit = {"container": statusDesktop_mainWindow_overlay, "objectName": "groupChatEdit_name", "type": "TextEdit", "visible": True}
save_changes_StatusButton = {"checkable": False, "container": statusDesktop_mainWindow_overlay, "objectName": "groupChatEdit_save", "type": "StatusButton", "visible": True}

# Leave group popup
leave_StatusButton = {"checkable": False, "container": statusDesktop_mainWindow_overlay, "objectName": "leaveGroupConfirmationDialogLeaveButton", "type": "StatusButton", "visible": True}

# Clear chat history popup
clear_StatusButton = {"checkable": False, "container": statusDesktop_mainWindow_overlay, "objectName": "clearChatConfirmationDialogClearButton", "type": "StatusButton", "visible": True}

# Close chat popup
close_chat_StatusButton = {"checkable": False, "container": statusDesktop_mainWindow_overlay, "objectName": "deleteChatConfirmationDialogDeleteButton", "text": "Close chat", "type": "StatusButton", "visible": True}

# Create Keycard account with new seed phrase popup
cancel_StatusButton = {"checkable": False, "container": statusDesktop_mainWindow_overlay, "id": "cancelButton", "type": "StatusButton", "visible": True}
image_KeycardImage = {"container": statusDesktop_mainWindow_overlay, "id": "image", "type": "KeycardImage", "unnamed": 1, "visible": True}
img_Image = {"container": statusDesktop_mainWindow_overlay, "id": "img", "type": "Image", "unnamed": 1, "visible": True}
headerTitle = {"container": statusDesktop_mainWindow_overlay, "objectName": "headerTitle", "type": "StatusBaseText", "visible": True}
o_KeycardInit = {"container": statusDesktop_mainWindow_overlay, "type": "KeycardInit", "unnamed": 1, "visible": True}
keycard_reader_instruction_text = {"container": statusDesktop_mainWindow_overlay, "type": "StatusBaseText", "visible": True}
pinInputField_StatusPinInput = {"container": statusDesktop_mainWindow_overlay, "id": "pinInputField", "type": "StatusPinInput", "unnamed": 1, "visible": True}
inputText_TextInput = {"container": statusDesktop_mainWindow_overlay, "id": "inputText", "type": "TextInput", "unnamed": 1, "visible": False}
nextStatusButton = {"checkable": False, "container": statusDesktop_mainWindow_overlay, "objectName": "PrimaryButton", "type": "StatusButton", "visible": True}
revealSeedPhraseButton = {"checkable": False, "container": statusDesktop_mainWindow_overlay, "objectName": "AddAccountPopup-RevealSeedPhrase", "type": "StatusButton", "visible": True}
seedPhraseWordAtIndex_Placeholder = {"container": statusDesktop_mainWindow_overlay, "objectName": "SeedPhraseWordAtIndex-%WORD-INDEX%", "type": "StatusSeedPhraseInput", "visible": True}
word0_StatusInput = {"container": statusDesktop_mainWindow_overlay, "id": "word0", "type": "StatusInput", "unnamed": 1, "visible": True}
word1_StatusInput = {"container": statusDesktop_mainWindow_overlay, "id": "word1", "type": "StatusInput", "unnamed": 1, "visible": True}
word2_StatusInput = {"container": statusDesktop_mainWindow_overlay, "id": "word2", "type": "StatusInput", "unnamed": 1, "visible": True}
o_KeyPairItem = {"container": statusDesktop_mainWindow_overlay, "type": "KeyPairItem", "unnamed": 1, "visible": True}
o_KeyPairUnknownItem = {"container": statusDesktop_mainWindow_overlay, "type": "KeyPairUnknownItem", "unnamed": 1, "visible": True}
o_StatusListItemTag = {"container": statusDesktop_mainWindow_overlay, "type": "StatusListItemTag", "unnamed": 1, "visible": True}
radioButton_StatusRadioButton = {"checkable": True, "container": statusDesktop_mainWindow_overlay, "id": "radioButton", "type": "StatusRadioButton", "unnamed": 1, "visible": True}
statusSeedPhraseInputField_TextEdit = {"container": statusDesktop_mainWindow_overlay, "objectName": "enterSeedPhraseInputField", "type": "TextEdit", "visible": True}
switchTabBar_StatusSwitchTabBar = {"container": statusDesktop_mainWindow_overlay, "objectName": "enterSeedPhraseSwitchBar", "type": "StatusSwitchTabBar", "visible": True}
switchTabBar_12_words_StatusSwitchTabButton = {"checkable": True, "container": switchTabBar_StatusSwitchTabBar, "objectName": "12SeedButton", "type": "StatusSwitchTabButton", "visible": True}
switchTabBar_18_words_StatusSwitchTabButton = {"checkable": True, "container": switchTabBar_StatusSwitchTabBar, "objectName": "18SeedButton", "type": "StatusSwitchTabButton", "visible": True}
switchTabBar_24_words_StatusSwitchTabButton = {"checkable": True, "container": switchTabBar_StatusSwitchTabBar, "objectName": "24SeedButton", "type": "StatusSwitchTabButton", "visible": True}
i_understand_the_key_pair_on_this_Keycard_will_be_deleted_StatusCheckBox = {"checkable": True, "container": statusDesktop_mainWindow_overlay, "id": "confirmation", "type": "StatusCheckBox", "visible": True}
statusSmartIdenticonLetter_StatusLetterIdenticon = {"container": statusDesktop_mainWindow_overlay, "objectName": "statusSmartIdenticonLetter", "type": "StatusLetterIdenticon", "visible": True}
secondary_StatusButton = {"checkable": False, "container": statusDesktop_mainWindow_overlay, "id": "secondaryButton", "type": "StatusButton", "unnamed": 1, "visible": True}

# Send Popup
o_StatusTabBar = {"container": statusDesktop_mainWindow_overlay, "type": "StatusTabBar", "unnamed": 1, "visible": True}
tab_Status_template = {"container": o_StatusTabBar, "type": "StatusBaseText", "unnamed": 1, "visible": True}
o_TokenBalancePerChainDelegate_template = {"container": statusDesktop_mainWindow_overlay, "objectName": "tokenBalancePerChainDelegate", "type": "TokenBalancePerChainDelegate", "visible": True}
o_CollectibleNestedDelegate_template = {"container": statusDesktop_mainWindow_overlay, "type": "CollectibleNestedDelegate", "unnamed": 1, "visible": True}
amountInput_TextEdit = {"container": statusDesktop_mainWindow_overlay, "objectName": "amountToSend_textField", "type": "StatusTextField", "visible": True}
paste_StatusButton = {"checkable": False, "container": statusDesktop_mainWindow_overlay, "type": "StatusButton", "unnamed": 1, "visible": True}
ens_or_address_TextEdit = {"container": statusDesktop_mainWindow_overlay, "id": "edit", "type": "TextEdit", "unnamed": 1, "visible": True}
accountSelectionTabBar_StatusTabBar = {"container": statusDesktop_mainWindow_overlay, "id": "accountSelectionTabBar", "type": "StatusTabBar", "unnamed": 1, "visible": True}
accountSelectionTabBar_My_Accounts_StatusTabButton = {"checkable": True, "container": accountSelectionTabBar_StatusTabBar, "objectName": "myAccountsTab", "type": "StatusTabButton", "visible": True}
status_account_WalletAccountListItem_template = {"container": statusDesktop_mainWindow_overlay, "objectName": "Status account", "type": "WalletAccountListItem", "visible": True}
arbitrum_StatusListItem = {"container": statusDesktop_mainWindow_overlay, "objectName": "Arbitrum", "type": "StatusListItem", "visible": True}
mainnet_StatusListItem = {"container": statusDesktop_mainWindow_overlay, "objectName": "Mainnet", "type": "StatusListItem", "visible": True}
statusListItemSubTitle_StatusTextWithLoadingState = {"container": statusDesktop_mainWindow_overlay, "objectName": "statusListItemSubTitle", "type": "StatusTextWithLoadingState", "visible": True}
fiatFees_StatusBaseText = {"container": statusDesktop_mainWindow_overlay, "id": "fiatFees", "type": "StatusBaseText", "unnamed": 1, "visible": True}
send_StatusFlatButton = {"checkable": False, "container": statusDesktop_mainWindow_overlay, "objectName": "transactionModalFooterButton", "type": "StatusButton", "visible": True}
o_SearchBoxWithRightIcon = {"container": statusDesktop_mainWindow_overlay, "type": "SearchBoxWithRightIcon", "unnamed": 1, "visible": True}
search_TextEdit = {"container": o_SearchBoxWithRightIcon, "id": "edit", "type": "TextEdit", "unnamed": 1, "visible": True}

# Assets Context Menu popup
send_StatusMenuItem = {"checkable": False, "container": statusDesktop_mainWindow_overlay, "enabled": True, "objectName": "sendMenuItem", "type": "StatusMenuItem", "visible": True}
receive_StatusMenuItem = {"checkable": False, "container": statusDesktop_mainWindow_overlay, "enabled": True, "objectName": "receiveMenuItem", "type": "StatusMenuItem", "visible": True}

# Receive popup
networkTagRectangle_eth_Rectangle = {"container": statusDesktop_mainWindow_overlay, "objectName": "networkTagRectangle_eth", "type": "Rectangle", "visible": True}
networkTagRectangle_oeth_Rectangle = {"container": statusDesktop_mainWindow_overlay, "objectName": "networkTagRectangle_oeth", "type": "Rectangle", "visible": True}
networkTagRectangle_arb1_Rectangle = {"container": statusDesktop_mainWindow_overlay, "objectName": "networkTagRectangle_arb1", "type": "Rectangle", "visible": True}
tabBar_StatusSwitchTabBar = {"container": statusDesktop_mainWindow_overlay, "id": "tabBar", "type": "StatusSwitchTabBar", "unnamed": 1, "visible": True}
tabBar_Multichain_StatusSwitchTabButton = {"checkable": True, "container": tabBar_StatusSwitchTabBar, "objectName": "multichainButton", "type": "StatusSwitchTabButton", "visible": True}
tabBar_Legacy_StatusSwitchTabButton = {"checkable": True, "container": tabBar_StatusSwitchTabBar, "objectName": "legacyButton", "type": "StatusSwitchTabButton", "visible": True}
accountSelector_AccountSelectorHeader = {"container": statusDesktop_mainWindow_overlay, "objectName": "accountSelector", "type": "AccountSelectorHeader", "visible": True}
textContent_StatusBaseText = {"container": statusDesktop_mainWindow_overlay, "objectName": "textContent", "type": "StatusBaseText", "visible": True}
edit_pencil_icon_StatusIcon = {"container": statusDesktop_mainWindow_overlay, "objectName": "edit_pencil-icon", "type": "StatusIcon", "visible": True}
greenCircleAroundIcon_Rectangle = {"container": statusDesktop_mainWindow_overlay, "id": "greenCircleAroundIcon", "type": "Rectangle", "unnamed": 1, "visible": True}
qrCodeImage_Image = {"container": statusDesktop_mainWindow_overlay, "objectName": "qrCodeImage", "type": "Image", "visible": True}
networkSelectorDelegate_Mainnet_NetworkSelectItemDelegate = {"container": statusDesktop_mainWindow_overlay, "index": 0, "objectName": "networkSelectorDelegate_Mainnet", "type": "NetworkSelectItemDelegate", "visible": True}
networkSelectorDelegate_Optimism_NetworkSelectItemDelegate = {"container": statusDesktop_mainWindow_overlay, "index": 1, "objectName": "networkSelectorDelegate_Optimism", "type": "NetworkSelectItemDelegate", "visible": True}
networkSelectorDelegate_Arbitrum_NetworkSelectItemDelegate = {"container": statusDesktop_mainWindow_overlay, "index": 2, "objectName": "networkSelectorDelegate_Arbitrum", "type": "NetworkSelectItemDelegate", "visible": True}

# Bridge popup
holdingSelector_TokenSelectorNew = {"container": statusDesktop_mainWindow_overlay, "objectName": "holdingSelector", "type": "TokenSelectorNew", "visible": True}
tokenSelectorButton = {"container": statusDesktop_mainWindow_overlay, "id": "tokenSelectorButton", "type": "TokenSelectorButton", "unnamed": 1, "visible": True}
modalHeader_HeaderTitleText = {"container": statusDesktop_mainWindow_overlay, "objectName": "modalHeader", "type": "HeaderTitleText", "visible": True}

# Token Selector popup
tokenSelectorPanel_TokenSelectorNew = {"container": statusDesktop_mainWindow_overlay, "objectName": "tokenSelectorPanel", "type": "TokenSelectorPanel", "visible": True}
tokensTabBar_StatusTabBar = {"container": statusDesktop_mainWindow_overlay, "objectName": "tokensTabBar", "type": "StatusTabBar", "visible": True}
tokenSelectorPanel_AssetsTab = {"container": tokensTabBar_StatusTabBar, "objectName": "assetsTab", "type": "StatusTabButton", "visible": True}
tokenSelectorPanel_CollectiblesTab = {"container": tokensTabBar_StatusTabBar, "objectName": "collectiblesTab", "type": "StatusTabButton", "visible": True}
tokenSelectorAssetDelegate_template = {"container": statusDesktop_mainWindow_overlay, "objectName": RegularExpression("tokenSelectorAssetDelegate*"), "type": "TokenSelectorAssetDelegate", "visible": True}
searchableCollectiblesPanel = {"container": statusDesktop_mainWindow_overlay, "id": "searchableCollectiblesPanel", "type": "SearchableCollectiblesPanel", "unnamed": 1, "visible": True}
collectiblesListView = {"container": statusDesktop_mainWindow_overlay, "type": "StatusListView", "id": "collectiblesListView", "visible": True}
collectiblesInnerListView = {"container": statusDesktop_mainWindow_overlay, "type": "StatusListView", "unnamed": 1, "visible": True}
collectiblesListViewInnerItem = {"container": collectiblesListView, "type": "Item", "unnamed": 1, "visible": True}
tokenSelectorCollectibleDelegate_template = {"container": statusDesktop_mainWindow_overlay, "objectName": RegularExpression("tokenSelectorCollectibleDelegate_*"), "type": "TokenSelectorCollectibleDelegate", "visible": True}
tokenSelectorBackButton = {"container": statusDesktop_mainWindow_overlay, "id": "backButton", "type": "StatusIconTextButton", "unnamed": 1, "visible": True}
tokenSelectorSearchBar = {"container": statusDesktop_mainWindow_overlay, "objectName": "collectiblesSearchBox", "type": "TokenSearchBox", "visible": True}
# tokenSelectorSearchBarBaseInput = {"container": tokenSelectorSearchBar, "objectName": "statusBaseInput", "occurrence": 2, "type": "StatusBaseInput", "visible": True}
tokenSelectorSearchBarTextEdit = {"container": tokenSelectorSearchBar, "id": "edit", "type": "TextEdit", "unnamed": 1, "visible": True}



# Verify identity popup
profileSendContactRequestModal_sayWhoYouAreInput_TextEdit = {"container": statusDesktop_mainWindow_overlay, "objectName": "ProfileSendContactRequestModal_sayWhoYouAreInput", "type": "TextEdit", "visible": True}
send_verification_request_StatusButton = {"checkable": False, "container": statusDesktop_mainWindow_overlay, "objectName": "ProfileSendContactRequestModal_sendContactRequestButton", "type": "StatusButton", "visible": True}
close_icon_StatusIcon = {"container": statusDesktop_mainWindow_overlay, "objectName": "close-icon", "type": "StatusIcon", "visible": True}
messageInput_StatusInput = {"container": statusDesktop_mainWindow_overlay, "id": "messageInput", "type": "StatusInput", "unnamed": 1, "visible": True}

# Respond to ID request popup
send_Answer_StatusButton = {"checkable": False, "container": statusDesktop_mainWindow_overlay, "objectName": "sendAnswerButton", "type": "StatusButton", "visible": True}
refuse_Verification_StatusButton = {"checkable": False, "container": statusDesktop_mainWindow_overlay, "objectName": "refuseVerificationButton", "type": "StatusButton", "unnamed": 1, "visible": True}
change_answer_StatusFlatButton = {"checkable": False, "container": statusDesktop_mainWindow_overlay, "objectName": "changeAnswerButton", "type": "StatusFlatButton", "visible": True}
close_StatusButton = {"checkable": False, "container": statusDesktop_mainWindow_overlay, "objectName": "closeButton", "type": "StatusButton", "visible": True}

# Build showcase popup
build_your_showcase_StatusButton = {"checkable": False, "container": statusDesktop_mainWindow_overlay, "objectName": "buildShowcaseButton", "type": "StatusButton", "visible": True}

# Activity center
activityCenterStatusFlatButton = {"checkable": False, "container": statusDesktop_mainWindow_overlay, "objectName": "activityCenterGroupButton", "type": "StatusFlatButton", "visible": True}
checkmark_circle_icon_StatusIcon = {"container": statusDesktop_mainWindow_overlay, "objectName": "checkmark-circle-icon", "type": "StatusIcon", "visible": True}
o_ActivityNotificationContactRequest = {"container": statusDesktop_mainWindow_overlay, "type": "ActivityNotificationContactRequest", "unnamed": 1, "visible": True}
activityCenterTopBar_ActivityCenterPopupTopBarPanel = {"container": statusDesktop_mainWindow_overlay, "id": "activityCenterTopBar", "type": "ActivityCenterPopupTopBarPanel", "unnamed": 1, "visible": True}
statusListView = {"container": statusDesktop_mainWindow_overlay, "type": "StatusListView", "unnamed": 1, "visible": True}

# Rename keypair popup
save_changes_rename_StatusButton = {"checkable": False, "container": statusDesktop_mainWindow_overlay, "objectName": "saveRenameKeypairChangesButton", "type": "StatusButton", "visible": True}
nameInput_StatusInput = {"container": statusDesktop_mainWindow_overlay, "id": "nameInput", "type": "StatusInput", "unnamed": 1, "visible": True}

# Link preview options popup
show_for_this_message_StatusMenuItem = {"checkable": False, "container": statusDesktop_mainWindow_overlay, "enabled": True, "text": "Show for this message", "type": "StatusMenuItem", "unnamed": 1, "visible": True}
always_show_previews_StatusMenuItem = {"checkable": False, "container": statusDesktop_mainWindow_overlay, "enabled": True, "text": "Always show previews", "type": "StatusMenuItem", "unnamed": 1, "visible": True}
never_show_previews_StatusMenuItem = {"checkable": False, "container": statusDesktop_mainWindow_overlay, "enabled": True, "text": "Never show previews", "type": "StatusMenuItem", "unnamed": 1, "visible": True}

# OS NAMES
# Open Files Dialog
chooseAnImageALogo_QQuickWindow = {"title": RegularExpression("Choose.*"), "type": "QQuickWindow", "unnamed": 1, "visible": True}
choose_an_image_as_logo_titleBar_ToolBar = {"container": chooseAnImageALogo_QQuickWindow, "id": "titleBar", "type": "ToolBar", "unnamed": 1, "visible": True}
titleBar_currentPathField_TextField = {"container": choose_an_image_as_logo_titleBar_ToolBar, "id": "currentPathField", "type": "TextField", "unnamed": 1, "visible": True}

# WALLET NAMES

mainWindow_WalletLayout = {"container": statusDesktop_mainWindow, "type": "WalletLayout", "unnamed": 1, "visible": True}

# Left Wallet Panel
mainWallet_LeftTab = {"container": statusDesktop_mainWindow, "objectName": "walletLeftTab", "type": "LeftTabView", "visible": True}
mainWallet_Saved_Addresses_Button = {"container": mainWindow_RighPanel, "objectName": "savedAddressesBtn", "type": "StatusFlatButton"}
walletAccounts_StatusListView = {"container": statusDesktop_mainWindow, "objectName": "walletAccountsListView", "type": "StatusListView", "visible": True}
mainWallet_All_Accounts_Button = {"container": walletAccounts_StatusListView, "objectName": "allAccountsBtn", "type": "Button", "visible": True}
mainWallet_Add_Account_Button = {"container": statusDesktop_mainWindow, "objectName": "addAccountButton", "type": "StatusRoundButton", "visible": True}
walletAccount_StatusListItem = {"container": walletAccounts_StatusListView, "objectName": RegularExpression("walletAccount*"), "type": "StatusListItem", "visible": True}
mainWallet_All_Accounts_Balance = {"container": mainWallet_All_Accounts_Button, "objectName": "walletLeftListAmountValue", "type": "StatusTextWithLoadingState", "visible": True}

# Saved Address View
mainWindow_SavedAddressesView = {"container": statusDesktop_mainWindow, "type": "SavedAddressesView", "unnamed": 1, "visible": True}
mainWindow_SavedAddressesView_2 = {"container": mainWindow_WalletLayout, "type": "SavedAddressesView", "unnamed": 1, "visible": True}
mainWallet_Saved_Addresses_Add_Buttton = {"container": mainWindow_SavedAddressesView, "objectName": "walletHeaderButton", "type": "StatusButton"}
mainWallet_Saved_Addresses_List = {"container": mainWindow_SavedAddressesView, "objectName": "SavedAddressesView_savedAddresses", "type": "StatusListView"}
savedAddressView_Delegate = {"container": mainWallet_Saved_Addresses_List, "objectName": RegularExpression("savedAddressView_Delegate*"), "type": "SavedAddressesDelegate", "visible": True}
send_StatusRoundButton = {"container": "", "type": "StatusRoundButton", "unnamed": 1, "visible": True}
savedAddressView_Delegate_menuButton = {"container": mainWindow_SavedAddressesView, "objectName": RegularExpression("savedAddressView_Delegate_menuButton*"), "type": "StatusRoundButton", "visible": True}
savedAddressesArea_SavedAddresses = {"container": mainWindow_SavedAddressesView, "objectName": "savedAddressesArea", "type": "SavedAddresses", "visible": True}
savedAddresses_area = {"container": mainWindow_SavedAddressesView_2, "objectName": "savedAddressesArea", "type": "SavedAddresses", "visible": True}

# MOCKED KEYCARD CONTROLLER NAMES

QQuickApplicationWindow = {"type": "QQuickApplicationWindow", "unnamed": 1, "visible": True}
mocked_Keycard_Lib_Controller_Overlay = {"container": QQuickApplicationWindow, "type": "Overlay", "unnamed": 1, "visible": True}

plugin_Reader_StatusButton = {"checkable": False, "container": QQuickApplicationWindow, "objectName": "pluginReaderButton", "type": "StatusButton", "visible": True}
unplug_Reader_StatusButton = {"checkable": False, "container": QQuickApplicationWindow, "objectName": "unplugReaderButton", "type": "StatusButton", "visible": True}
insert_Keycard_1_StatusButton = {"checkable": False, "container": QQuickApplicationWindow, "objectName": "insertKeycard1Button", "type": "StatusButton", "visible": True}
insert_Keycard_2_StatusButton = {"checkable": False, "container": QQuickApplicationWindow, "objectName": "insertKeycard2Button", "type": "StatusButton", "visible": True}
remove_Keycard_StatusButton = {"checkable": False, "container": QQuickApplicationWindow, "objectName": "removeKeycardButton", "type": "StatusButton", "visible": True}
set_initial_reader_state_StatusButton = {"checkable": False, "container": QQuickApplicationWindow, "id": "selectReaderStateButton", "type": "StatusButton", "visible": True}
keycardSettingsTab = {"container": QQuickApplicationWindow, "type": "KeycardSettingsTab", "visible": True}
set_initial_keycard_state_StatusButton = {"checkable": False, "container": keycardSettingsTab, "id": "selectKeycardsStateButton", "type": "StatusButton", "visible": True}
register_Keycard_StatusButton = {"checkable": False, "container": keycardSettingsTab, "objectName": "registerKeycardButton", "type": "StatusButton", "visible": True}

not_Status_Keycard_StatusMenuItem = {"checkable": False, "container": mocked_Keycard_Lib_Controller_Overlay, "enabled": True, "objectName": "notStatusKeycardAction", "type": "StatusMenuItem", "visible": True}
empty_Keycard_StatusMenuItem = {"checkable": False, "container": mocked_Keycard_Lib_Controller_Overlay, "enabled": True, "objectName": "emptyKeycardAction", "text": "Empty Keycard", "type": "StatusMenuItem", "visible": True}
max_Pairing_Slots_Reached_StatusMenuItem = {"checkable": False, "container": mocked_Keycard_Lib_Controller_Overlay, "enabled": True, "objectName": "maxPairingSlotsReachedAction", "type": "StatusMenuItem", "visible": True}
max_PIN_Retries_Reached_StatusMenuItem = {"checkable": False, "container": mocked_Keycard_Lib_Controller_Overlay, "enabled": True, "objectName": "maxPINRetriesReachedAction", "type": "StatusMenuItem", "visible": True}
max_PUK_Retries_Reached_StatusMenuItem = {"checkable": False, "container": mocked_Keycard_Lib_Controller_Overlay, "enabled": True, "objectName": "maxPUKRetriesReachedAction", "type": "StatusMenuItem", "visible": True}
keycard_With_Mnemonic_Only_StatusMenuItem = {"checkable": False, "container": mocked_Keycard_Lib_Controller_Overlay, "enabled": True, "objectName": "keycardWithMnemonicOnlyAction", "type": "StatusMenuItem", "visible": True}
keycard_With_Mnemonic_Metadata_StatusMenuItem = {"checkable": False, "container": mocked_Keycard_Lib_Controller_Overlay, "enabled": True, "objectName": "keycardWithMnemonicAndMedatadaAction", "type": "StatusMenuItem", "visible": True}
custom_Keycard_StatusMenuItem = {"checkable": False, "container": mocked_Keycard_Lib_Controller_Overlay, "enabled": True, "objectName": "customKeycardAction", "type": "StatusMenuItem", "visible": True}

reader_Unplugged_StatusMenuItem = {"checkable": False, "container": mocked_Keycard_Lib_Controller_Overlay, "enabled": True, "objectName": "readerStateReaderUnpluggedAction", "type": "StatusMenuItem", "visible": True}
keycard_Not_Inserted_StatusMenuItem = {"checkable": False, "container": mocked_Keycard_Lib_Controller_Overlay, "enabled": True, "objectName": "readerStateKeycardNotInsertedAction", "type": "StatusMenuItem", "visible": True}
keycard_Inserted_StatusMenuItem = {"checkable": False, "container": mocked_Keycard_Lib_Controller_Overlay, "enabled": True, "objectName": "readerStateKeycardInsertedAction", "type": "StatusMenuItem", "visible": True}

keycard_edit_TextEdit = {"container": keycardSettingsTab, "id": "edit", "type": "TextEdit", "unnamed": 1, "visible": True}
keycardFlickable = {"container": keycardSettingsTab, "type": "Flickable", "unnamed": 1, "visible": True}
