from objectmaphelper import *

# MAIN NAMES

statusDesktop_mainWindow = {"name": "mainWindow", "type": "StatusWindow"}
mainWindow_StatusWindow = {"name": "mainWindow", "type": "StatusWindow", "visible": True}
statusDesktop_mainWindow_overlay = {"container": statusDesktop_mainWindow, "type": "Overlay", "unnamed": 1, "visible": True}
statusDesktop_mainWindow_overlay_popup2 = {"container": statusDesktop_mainWindow_overlay, "occurrence": 2, "type": "PopupItem", "unnamed": 1, "visible": True}
scrollView_StatusScrollView = {"container": statusDesktop_mainWindow_overlay, "id": "scrollView", "type": "StatusScrollView", "unnamed": 1, "visible": True}
splashScreen = {"container": statusDesktop_mainWindow, "objectName": "splashScreen", "type": "DidYouKnowSplashScreen"}

# Common names
settingsSave_StatusButton = {"container": statusDesktop_mainWindow, "objectName": "settingsDirtyToastMessageSaveButton", "type": "StatusButton", "visible": True}
mainWindow_Save_changes_StatusButton = {"checkable": False, "container": statusDesktop_mainWindow, "objectName": "settingsDirtyToastMessageSaveButton", "type": "StatusButton", "visible": True}
closeCrossPopupButton = {"container": statusDesktop_mainWindow_overlay, "objectName": "headerActionsCloseButton", "type": "StatusFlatRoundButton", "visible": True}

# Main right panel
mainWindow_RighPanel = {"container": statusDesktop_mainWindow, "type": "ColumnLayout", "objectName": "mainRightView", "visible": True}

# Navigation Panel
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

# Banners
secureYourSeedPhraseBanner_ModuleWarning = {"container": statusDesktop_mainWindow, "objectName": "secureYourSeedPhraseBanner", "type": "ModuleWarning", "visible": True}

# Scroll
o_Flickable = {"container": statusDesktop_mainWindow_overlay, "type": "Flickable", "unnamed": 1, "visible": True}

# Context Menu
o_StatusListView = {"container": statusDesktop_mainWindow_overlay, "type": "StatusListView", "unnamed": 1, "visible": True}

# COMPONENT NAMES

""" Onboarding """
# Before you get started Popup
acknowledge_checkbox = {"checkable": True, "container": statusDesktop_mainWindow_overlay, "objectName": "acknowledgeCheckBox", "type": "StatusCheckBox", "visible": True}
termsOfUseCheckBox_StatusCheckBox = {"checkable": True, "container": statusDesktop_mainWindow_overlay, "objectName":"termsOfUseCheckBox", "type": "StatusCheckBox", "visible": True}
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
userLabel_StyledText = {"container": o_StatusListView, "type": "StyledText", "unnamed": 1, "visible": True}
o_StatusIdenticonRing = {"container": o_StatusListView, "type": "StatusIdenticonRing", "unnamed": 1, "visible": True}

# My Profile Popup
ProfileHeader_userImage = {"container": statusDesktop_mainWindow_overlay, "objectName": "ProfileDialog_userImage", "type": "UserImage", "visible": True}
ProfilePopup_displayName = {"container": statusDesktop_mainWindow_overlay, "objectName": "ProfileDialog_displayName", "type": "StatusBaseText", "visible": True}
ProfilePopup_editButton = {"container": statusDesktop_mainWindow_overlay, "objectName": "editProfileButton", "type": "StatusButton", "visible": True}
ProfilePopup_SendContactRequestButton = {"container": statusDesktop_mainWindow_overlay, "objectName": "profileDialog_sendContactRequestButton", "type": "StatusButton", "visible": True}
profileDialog_userEmojiHash_EmojiHash = {"container": statusDesktop_mainWindow_overlay, "objectName": "ProfileDialog_userEmojiHash", "type": "EmojiHash", "visible": True}
edit_TextEdit = {"container": statusDesktop_mainWindow_overlay, "id": "edit", "type": "TextEdit", "unnamed": 1, "visible": True}
https_status_app_StatusBaseText = {"container": edit_TextEdit, "type": "StatusBaseText", "unnamed": 1, "visible": True}
copy_icon_CopyButton = {"container": statusDesktop_mainWindow_overlay, "objectName": "copy-icon", "type": "CopyButton", "visible": True}

# Welcome Status Popup
betaConsent_StatusModal = {"container": statusDesktop_mainWindow_overlay, "objectName": "desktopBetaStatusModal", "type": "StatusModal", "visible": True}
agreeToUse_StatusCheckBox = {"checkable": True, "container": statusDesktop_mainWindow_overlay, "objectName": "desktopBetaAgreeCheckBox", "type": "StatusCheckBox", "visible": True}
readyToUse_StatusCheckBox = {"checkable": True, "container": statusDesktop_mainWindow_overlay, "objectName": "desktopBetaReadyCheckBox", "type": "StatusCheckBox", "visible": True}
i_m_ready_to_use_Status_Desktop_Beta_StatusButton = {"container": statusDesktop_mainWindow_overlay, "type": "StatusButton", "objectName": "desktopBetaStatusButton", "visible": True}

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

# Pinned messages
unpinButton_StatusFlatRoundButton = {"container": statusDesktop_mainWindow_overlay, "id": "unpinButton", "type": "StatusFlatRoundButton", "unnamed": 1, "visible": True}
headerActionsCloseButton_StatusFlatRoundButton = {"container": statusDesktop_mainWindow_overlay, "objectName": "headerActionsCloseButton", "type": "StatusFlatRoundButton", "visible": True}
o_StatusPinMessageDetails = {"container": statusDesktop_mainWindow_overlay, "type": "StatusPinMessageDetails", "unnamed": 1, "visible": True}

""" Settings """

# Send Contact Request
sendContactRequestModal_ChatKey_Input_TextEdit = {"container": statusDesktop_mainWindow_overlay, "objectName": "SendContactRequestModal_ChatKey_Input", "type": "TextEdit", "visible": True}
sendContactRequestModal_SayWhoYouAre_Input_TextEdit = {"container": statusDesktop_mainWindow_overlay, "objectName": "SendContactRequestModal_SayWhoYouAre_Input", "type": "TextEdit", "visible": True}
send_Contact_Request_StatusButton = {"container": statusDesktop_mainWindow_overlay, "objectName": "SendContactRequestModal_Send_Button", "type": "StatusButton", "visible": True}

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

# Remove account popup:
mainWallet_Remove_Account_Popup_Account_Notification = {"container": statusDesktop_mainWindow, "objectName": "RemoveAccountPopup-Notification", "type": "StatusBaseText", "visible": True}
mainWallet_Remove_Account_Popup_Account_Path_Component = {"container": statusDesktop_mainWindow, "objectName": "RemoveAccountPopup-DerivationPath", "type": "StatusInput", "visible": True}
mainWallet_Remove_Account_Popup_Account_Path = {"container": mainWallet_Remove_Account_Popup_Account_Path_Component, "type": "TextEdit", "unnamed": 1, "visible": True}
mainWallet_Remove_Account_Popup_HavePenPaperCheckBox = {"checkable": True, "container": statusDesktop_mainWindow, "objectName": "RemoveAccountPopup-HavePenPaper", "type": "StatusCheckBox", "visible": True}
mainWallet_Remove_Account_Popup_ConfirmButton = {"container": statusDesktop_mainWindow, "objectName": "RemoveAccountPopup-ConfirmButton", "type": "StatusButton", "visible": True}
mainWallet_Remove_Account_Popup_CancelButton = {"container": statusDesktop_mainWindow, "objectName": "RemoveAccountPopup-CancelButton", "type": "StatusFlatButton", "visible": True}

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
mainWallet_Saved_Addresses_Popup_Network_Selector_Optimism_network_tag = {"container": statusDesktop_mainWindow_overlay, "objectName": "networkTagRectangle_opt", "type": "Rectangle", "visible": True}
mainWallet_Saved_Addresses_Popup_Network_Selector_Arbitrum_network_tag = {"container": statusDesktop_mainWindow_overlay, "objectName": "networkTagRectangle_arb", "type": "Rectangle", "visible": True}

# Context Menu
contextMenu_PopupItem = {"container": statusDesktop_mainWindow_overlay, "type": "PopupItem", "unnamed": 1, "visible": True}
contextMenuItem = {"container": statusDesktop_mainWindow_overlay, "type": "StatusBaseText", "unnamed": 1, "visible": True}
contextMenuItem_AddWatchOnly = {"container": statusDesktop_mainWindow_overlay, "enabled": True, "objectName": RegularExpression("AccountMenu-AddWatchOnlyAccountAction*"), "type": "StatusMenuItem"}
contextMenuItem_Delete = {"container": statusDesktop_mainWindow_overlay, "enabled": True, "objectName": RegularExpression("AccountMenu-DeleteAction*"), "type": "StatusMenuItem"}
contextMenuItem_Edit = {"container": statusDesktop_mainWindow_overlay, "enabled": True, "objectName": RegularExpression("AccountMenu-EditAction*"), "type": "StatusMenuItem"}
contextMenuItem_HideInclude = {"container": statusDesktop_mainWindow_overlay, "enabled": True, "objectName": RegularExpression("AccountMenu-HideFromTotalBalance*"), "type": "StatusMenuItem"}
contextSavedAddressEdit = {"container": statusDesktop_mainWindow, "objectName": "editSavedAddress", "type": "StatusMenuItem"}
contextSavedAddressDelete = {"container": statusDesktop_mainWindow, "objectName": "deleteSavedAddress", "type": "StatusMenuItem"}

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
authenticate_StatusButton = {"container": statusDesktop_mainWindow_overlay, "objectName": "PrimaryButton", "text": "Authenticate", "type": "StatusButton", "visible": True}
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
social_links_add_StatusBackButton = {"container": statusDesktop_mainWindow_overlay, "type": "StatusButton", "unnamed": 1, "visible": True}
linksView = {"container": statusDesktop_mainWindow, "id": "linksView", "type": "StatusListView", "unnamed": 1, "visible": True}

# Changes detected popup
mainWindow_settingsDirtyToastMessage_SettingsDirtyToastMessage = {"container": ":statusDesktop_mainWindow", "id": "settingsDirtyToastMessage", "type": "SettingsDirtyToastMessage", "unnamed": 1, "visible": True}

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
statusSeedPhraseInputField_TextEdit = {"container": statusDesktop_mainWindow_overlay, "objectName": "statusSeedPhraseInputField", "type": "TextEdit", "visible": True}
switchTabBar_StatusSwitchTabBar = {"container": statusDesktop_mainWindow_overlay, "id": "switchTabBar", "type": "StatusSwitchTabBar", "unnamed": 1, "visible": True}
switchTabBar_12_words_StatusSwitchTabButton = {"checkable": True, "container": switchTabBar_StatusSwitchTabBar, "objectName": "12SeedButton", "text": "12 words", "type": "StatusSwitchTabButton", "visible": True}
switchTabBar_18_words_StatusSwitchTabButton = {"checkable": True, "container": switchTabBar_StatusSwitchTabBar, "objectName": "18SeedButton", "text": "18 words", "type": "StatusSwitchTabButton", "visible": True}
switchTabBar_24_words_StatusSwitchTabButton = {"checkable": True, "container": switchTabBar_StatusSwitchTabBar, "objectName": "24SeedButton", "text": "24 words", "type": "StatusSwitchTabButton", "visible": True}
i_understand_the_key_pair_on_this_Keycard_will_be_deleted_StatusCheckBox = {"checkable": True, "container": statusDesktop_mainWindow_overlay, "id": "confirmation", "type": "StatusCheckBox", "visible": True}
statusSmartIdenticonLetter_StatusLetterIdenticon = {"container": statusDesktop_mainWindow_overlay, "objectName": "statusSmartIdenticonLetter", "type": "StatusLetterIdenticon", "visible": True}
secondary_StatusButton = {"checkable": False, "container": statusDesktop_mainWindow_overlay, "id": "secondaryButton", "type": "StatusButton", "unnamed": 1, "visible": True}

# Send Popup
o_StatusTabBar = {"container": statusDesktop_mainWindow_overlay, "type": "StatusTabBar", "unnamed": 1, "visible": True}
tab_Status_template = {"container": o_StatusTabBar, "type": "StatusBaseText", "unnamed": 1, "visible": True}
o_TokenBalancePerChainDelegate_template = {"container": statusDesktop_mainWindow_overlay, "objectName": "tokenBalancePerChainDelegate", "type": "TokenBalancePerChainDelegate", "visible": True}
o_CollectibleNestedDelegate_template = {"container": statusDesktop_mainWindow_overlay, "type": "CollectibleNestedDelegate", "unnamed": 1, "visible": True}
amountInput_TextEdit = {"container": statusDesktop_mainWindow_overlay, "objectName": "amountInput", "type": "TextEdit", "visible": True}
paste_StatusButton = {"checkable": False, "container": statusDesktop_mainWindow_overlay, "type": "StatusButton", "unnamed": 1, "visible": True}
ens_or_address_TextEdit = {"container": statusDesktop_mainWindow_overlay, "id": "edit", "type": "TextEdit", "unnamed": 1, "visible": True}
accountSelectionTabBar_StatusTabBar = {"container": statusDesktop_mainWindow_overlay, "id": "accountSelectionTabBar", "type": "StatusTabBar", "unnamed": 1, "visible": True}
accountSelectionTabBar_My_Accounts_StatusTabButton = {"checkable": True, "container": accountSelectionTabBar_StatusTabBar, "objectName": "myAccountsTab", "type": "StatusTabButton", "visible": True}
status_account_WalletAccountListItem_template = {"container": statusDesktop_mainWindow_overlay, "objectName": "Status account", "type": "WalletAccountListItem", "visible": True}
arbitrum_StatusListItem = {"container": statusDesktop_mainWindow_overlay, "objectName": "Arbitrum", "type": "StatusListItem", "visible": True}
mainnet_StatusListItem = {"container": statusDesktop_mainWindow_overlay, "objectName": "Mainnet", "type": "StatusListItem", "visible": True}
statusListItemSubTitle_StatusTextWithLoadingState = {"container": statusDesktop_mainWindow_overlay, "objectName": "statusListItemSubTitle", "type": "StatusTextWithLoadingState", "visible": True}
fiatFees_StatusBaseText = {"container": statusDesktop_mainWindow_overlay, "id": "fiatFees", "type": "StatusBaseText", "unnamed": 1, "visible": True}
send_StatusFlatButton = {"checkable": False, "container": statusDesktop_mainWindow_overlay, "objectName": "sendModalFooterSendButton", "type": "StatusFlatButton", "visible": True}
o_SearchBoxWithRightIcon = {"container": statusDesktop_mainWindow_overlay, "type": "SearchBoxWithRightIcon", "unnamed": 1, "visible": True}
search_TextEdit = {"container": o_SearchBoxWithRightIcon, "id": "edit", "type": "TextEdit", "unnamed": 1, "visible": True}

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

# OS NAMES
# Open Files Dialog
chooseAnImageALogo_QQuickWindow = {"title": RegularExpression("Choose.*"), "type": "QQuickWindow", "unnamed": 1, "visible": True}
choose_an_image_as_logo_titleBar_ToolBar = {"container": chooseAnImageALogo_QQuickWindow, "id": "titleBar", "type": "ToolBar", "unnamed": 1, "visible": True}
titleBar_currentPathField_TextField = {"container": choose_an_image_as_logo_titleBar_ToolBar, "id": "currentPathField", "type": "TextField", "unnamed": 1, "visible": True}

# SETTINGS NAMES

mainWindow_ProfileLayout = {"container": statusDesktop_mainWindow, "objectName": "profileStatusSectionLayout", "type": "StatusSectionLayout", "visible": True}
mainWindow_StatusSectionLayout_ContentItem = {"container": mainWindow_ProfileLayout, "objectName": "StatusSectionLayout", "type": "ContentItem", "visible": True}
settingsContentBase_ScrollView = {"container": statusDesktop_mainWindow, "objectName": "settingsContentBaseScrollView", "type": "StatusScrollView", "visible": True}
settingsContentBaseScrollView_Flickable = {"container": settingsContentBase_ScrollView, "type": "Flickable", "unnamed": 1, "visible": True}

# Left Panel

mainWindow_LeftTabView = {"container": statusDesktop_mainWindow, "type": "LeftTabView", "unnamed": 1, "visible": True}
LeftTabView_ScrollView = {"container": mainWindow_LeftTabView, "type": "StatusScrollView", "unnamed": 1, "visible": True}
LeftTabProfileMenu = {"container": LeftTabView_ScrollView, "objectName": "leftTabViewProfileMenu", "type": "MenuPanel", "visible": True}
mainWindow_Settings_StatusNavigationPanelHeadline = {"container": mainWindow_LeftTabView, "type": "StatusNavigationPanelHeadline", "unnamed": 1, "visible": True}
mainWindow_scrollView_StatusScrollView = {"container": mainWindow_LeftTabView, "id": "scrollView", "type": "StatusScrollView", "unnamed": 1, "visible": True}
scrollView_MenuItem_StatusNavigationListItem = {"container": LeftTabView_ScrollView, "type": "StatusNavigationListItem", "visible": True}
scrollView_Flickable = {"container": mainWindow_scrollView_StatusScrollView, "type": "Flickable", "unnamed": 1, "visible": True}
settingsBackUpSeedPhraseOption = {"container": LeftTabView_ScrollView, "objectName": "18-MainMenuItem", "type": "StatusNavigationListItem", "visible": True}
settingsWalletOption = {"container": LeftTabView_ScrollView, "objectName": "5-AppMenuItem", "type": "StatusNavigationListItem", "visible": True}

# Communities View
mainWindow_CommunitiesView = {"container": statusDesktop_mainWindow, "type": "CommunitiesView", "unnamed": 1, "visible": True}
mainWindow_settingsContentBaseScrollView_StatusScrollView = {"container": mainWindow_CommunitiesView, "objectName": "settingsContentBaseScrollView", "type": "StatusScrollView", "visible": True}
settingsContentBaseScrollView_listItem_StatusListItem = {"container": mainWindow_settingsContentBaseScrollView_StatusScrollView, "id": "listItem", "type": "StatusListItem", "unnamed": 1, "visible": True}

# Templates to generate Real Name in test
settings_iconOrImage_StatusSmartIdenticon = {"id": "iconOrImage", "type": "StatusSmartIdenticon", "unnamed": 1, "visible": True}
settings_StatusTextWithLoadingState = {"type": "StatusTextWithLoadingState", "unnamed": 1, "visible": True}
settings_statusListItemSubTitle = {"objectName": "statusListItemSubTitle", "type": "StatusTextWithLoadingState", "visible": True}
settings_StatusFlatButton = {"type": "StatusFlatButton", "unnamed": 1, "visible": True}

# Messaging View
mainWindow_MessagingView = {"container": statusDesktop_mainWindow, "type": "MessagingView", "unnamed": 1, "visible": True}
contactsListItem_btn_StatusContactRequestsIndicatorListItem = {"container": mainWindow_MessagingView, "objectName": "MessagingView_ContactsListItem_btn", "type": "StatusContactRequestsIndicatorListItem", "visible": True}

# Contacts View
mainWindow_ContactsView = {"container": statusDesktop_mainWindow, "type": "ContactsView", "unnamed": 1, "visible": True}
mainWindow_Send_contact_request_to_chat_key_StatusButton = {"checkable": False, "container": mainWindow_ContactsView, "objectName": "ContactsView_ContactRequest_Button", "type": "StatusButton", "visible": True}
contactsTabBar_Pending_Requests_StatusTabButton = {"checkable": True, "container": mainWindow_ContactsView, "objectName": "ContactsView_PendingRequest_Button", "type": "StatusTabButton", "visible": True}
settingsContentBaseScrollView_ContactListPanel = {"container": mainWindow_ContactsView, "objectName": "ContactListPanel_ListView", "type": "StatusListView", "visible": True}
settingsContentBaseScrollView_sentRequests_ContactsListPanel = {"container": mainWindow_ContactsView, "objectName": "sentRequests_ContactsListPanel", "type": "ContactsListPanel", "visible": True}
contactsTabBar_Contacts_StatusTabButton = {"checkable": True, "container": mainWindow_ContactsView, "id": "contactsBtn", "type": "StatusTabButton", "unnamed": 1, "visible": True}
settingsContentBaseScrollView_receivedRequests_ContactsListPanel = {"container": mainWindow_ContactsView, "objectName": "receivedRequests_ContactsListPanel", "type": "ContactsListPanel", "visible": True}
settingsContentBaseScrollView_mutualContacts_ContactsListPanel = {"container": mainWindow_ContactsView, "id": "mutualContacts", "type": "ContactsListPanel", "unnamed": 1, "visible": True}
settingsContentBaseScrollView_Invite_friends_StatusButton = {"checkable": False, "container": mainWindow_ContactsView, "type": "StatusButton", "unnamed": 1, "visible": True}
settingsContentBaseScrollView_NoFriendsRectangle = {"container": mainWindow_ContactsView, "type": "NoFriendsRectangle", "unnamed": 1, "visible": True}
view_Profile_StatusMenuItem = {"checkable": False, "container": statusDesktop_mainWindow_overlay, "enabled": True, "objectName": "viewProfile_StatusItem", "type": "StatusMenuItem", "visible": True}
verify_Identity_StatusMenuItem = {"checkable": False, "container": statusDesktop_mainWindow_overlay, "enabled": True, "objectName": "verifyIdentity_StatusItem", "type": "StatusMenuItem", "visible": True}
respond_to_ID_Request_StatusMenuItem = {"checkable": False, "container": statusDesktop_mainWindow_overlay, "enabled": True, "objectName": "pendingIdentity_StatusItem", "type": "StatusMenuItem", "visible": True}
settingsContentBaseScrollView_Respond_to_ID_Request_StatusFlatButton = {"checkable": False, "container": mainWindow_ContactsView, "objectName": "verifyIdentity_StatusItem", "type": "StatusFlatButton", "unnamed": 1, "visible": True}

# Keycard Settings View
mainWindow_KeycardView = {"container": statusDesktop_mainWindow, "type": "KeycardView", "unnamed": 1, "visible": True}
setupFromExistingKeycardAccount_StatusListItem = {"container": settingsContentBase_ScrollView, "objectName": "setupFromExistingKeycardAccount", "type": "StatusListItem", "visible": True}
createNewKeycardAccount_StatusListItem = {"container": settingsContentBase_ScrollView, "objectName": "createNewKeycardAccount", "type": "StatusListItem", "visible": True}
importRestoreKeycard_StatusListItem = {"container": settingsContentBase_ScrollView, "objectName": "importRestoreKeycard", "type": "StatusListItem", "visible": True}
importFromKeycard_StatusListItem = {"container": settingsContentBase_ScrollView, "objectName": "importFromKeycard", "type": "StatusListItem", "visible": True}
checkWhatsNewKeycard_StatusListItem = {"container": settingsContentBase_ScrollView, "objectName": "checkWhatsNewKeycard", "type": "StatusListItem", "visible": True}
factoryResetKeycard_StatusListItem = {"container": settingsContentBase_ScrollView, "objectName": "factoryResetKeycard", "type": "StatusListItem", "visible": True}

# Wallet Settings View
mainWindow_WalletView = {"container": statusDesktop_mainWindow, "type": "WalletView", "unnamed": 1, "visible": True}
settings_Wallet_MainView_Networks = {"container": statusDesktop_mainWindow, "objectName": "networksItem", "type": "StatusListItem"}
settings_Wallet_MainView_AddNewAccountButton = {"container": statusDesktop_mainWindow, "objectName": "settings_Wallet_MainView_AddNewAccountButton", "type": "StatusButton", "visible": True}
settingsContentBaseScrollView_accountOrderItem_StatusListItem = {"container": settingsContentBase_ScrollView, "objectName": "accountOrderItem", "type": "StatusListItem", "visible": True}
settingsContentBaseScrollView_savedAddressesItem_StatusListItem = {"container": settingsContentBase_ScrollView, "objectName": "savedAddressesItem", "type": "StatusListItem", "visible": True}
settingsContentBaseScrollView_StatusListItem = {"container": settingsContentBase_ScrollView, "type": "StatusListItem", "unnamed": 1, "visible": True}
settings_Wallet_NetworksView_TestNet_Toggle = {"container": statusDesktop_mainWindow, "objectName": "testnetModeSwitch", "type": "StatusSwitch"}
settings_Wallet_NetworksView_TestNet_Toggle_Title = {"container": settingsContentBase_ScrollView, "objectName": "statusListItemSubTitle", "type": "StatusTextWithLoadingState", "visible": True}
settings_Wallet_SavedAddresses_AddAddressButton = {"container": statusDesktop_mainWindow, "objectName": "addNewSavedAddressButton", "type": "StatusButton", "visible": True}
settings_Wallet_SavedAddress_ItemDelegate ={"container": settingsContentBase_ScrollView, "objectName": RegularExpression("savedAddressView_Delegate*"), "type": "SavedAddressesDelegate", "visible": True}
settingsContentBaseScrollView_Goerli_testnet_active_StatusBaseText = {"container": settingsContentBase_ScrollView, "type": "StatusBaseText", "unnamed": 1, "visible": True}
settingsContentBaseScrollView_accountsList_StatusListView = {"container": settingsContentBase_ScrollView, "id": "accountsList", "type": "StatusListView", "unnamed": 1, "visible": True}
settingsContentBaseScrollView_draggableDelegate_StatusDraggableListItem = {"checkable": False, "container": settingsContentBase_ScrollView, "id": "draggableDelegate", "type": "StatusDraggableListItem", "unnamed": 1, "visible": True}
settingsContentBaseScrollView_accountOrderView_AccountOrderView = {"container": settingsContentBase_ScrollView, "id": "accountOrderView", "type": "AccountOrderView", "unnamed": 1, "visible": True}
settingsContentBaseScrollView_StatusBaseText = {"container": settingsContentBase_ScrollView, "type": "StatusBaseText", "unnamed": 1, "visible": True}
mainWindow_StatusToolBar = {"container": statusDesktop_mainWindow, "objectName": "statusToolBar", "type": "StatusToolBar", "visible": True}
main_toolBar_back_button = {"container": mainWindow_StatusToolBar, "objectName": "toolBarBackButton", "type": "StatusFlatButton", "visible": True}
settingsContentBaseScrollView_WalletNetworkDelegate_template = {"container": settingsContentBase_ScrollView, "objectName": "walletNetworkDelegate_Mainnet_1", "type": "WalletNetworkDelegate", "visible": True}
networkSettingsNetworks_Mainnet = {"container": settingsContentBase_ScrollView, "objectName": "walletNetworkDelegate_Mainnet_1", "type": "WalletNetworkDelegate", "visible": True}
networkSettingsNetworks_Mainnet_Goerli = {"container": settingsContentBase_ScrollView, "objectName": "walletNetworkDelegate_Mainnet_5", "type": "WalletNetworkDelegate", "visible": True}
networkSettingsNetworks_Optimism = {"container": settingsContentBase_ScrollView, "objectName": "walletNetworkDelegate_Optimism_10", "type": "WalletNetworkDelegate", "visible": True}
networkSettingsNetworks_Optimism_Goerli = {"container": settingsContentBase_ScrollView, "objectName": "walletNetworkDelegate_Optimism_420", "type": "WalletNetworkDelegate", "visible": True}
networkSettingsNetworks_Arbitrum = {"container": settingsContentBase_ScrollView, "objectName": "walletNetworkDelegate_Arbitrum_42161", "type": "WalletNetworkDelegate", "visible": True}
networkSettingsNetworks_Arbitrum_Goerli = {"container": settingsContentBase_ScrollView, "objectName": "walletNetworkDelegate_Arbitrum_421613", "type": "WalletNetworkDelegate", "visible": True}
networkSettingsNetworks_Mainnet_Goerli_sensor = {"container": networkSettingsNetworks_Mainnet_Goerli, "objectName": "walletNetworkDelegate_Mainnet_5_sensor", "id": "sensor", "type": "MouseArea", "unnamed": 1, "visible": True}
networkSettingsNetowrks_Mainnet_Testlabel = {"container": networkSettingsNetworks_Mainnet_Goerli_sensor, "objectName": "testnetLabel_Mainnet", "type": "StatusBaseText", "visible": True}
settingsWalletAccountDelegate_Status_account = {"container": settingsContentBase_ScrollView, "objectName": "Status account", "type": "WalletAccountDelegate", "visible": True}
settingsWalletAccountDelegate = {"container": settingsContentBase_ScrollView, "index": 0, "objectName": RegularExpression("*"), "type": "WalletAccountDelegate", "visible": True}
settingsWalletKeyPairDelegate = {"container": settingsContentBase_ScrollView, "objectName": "walletKeyPairDelegate", "type": "StatusListItem", "visible": True}
settingsWalletAccountTotalBalance = {"container": settingsContentBase_ScrollView, "objectName": "includeTotalBalanceListItem", "type": "StatusListItem", "visible": True}
settingsWalletAccountTotalBalanceToggle = {"checkable": True, "container": settingsWalletAccountTotalBalance, "type": "StatusSwitch", "visible": True}

# Wallet Account Details view
walletAccountViewEditAccountButton = {"container": statusDesktop_mainWindow, "objectName": "walletAccountViewEditAccountButton", "type": "StatusButton"}
walletAccountViewAccountName = {"container": statusDesktop_mainWindow, "objectName": "walletAccountViewAccountName", "type": "StatusBaseText"}
walletAccountViewAccountEmoji = {"container": statusDesktop_mainWindow, "objectName": "walletAccountViewAccountImage", "type": "StatusEmoji", "visible": True}
walletAccountViewRemoveAccountButton = {"container": statusDesktop_mainWindow, "objectName": "deleteAccountButton", "type": "StatusButton"}
walletAccountViewDetailsLabel = {"container": settingsContentBase_ScrollView, "objectName": "AccountDetails_TextLabel", "type": "StatusBaseText"}
walletAccountViewBalance = {"container": settingsContentBase_ScrollView, "objectName": "Balance_ListItem", "type": "WalletAccountDetailsListItem"}
walletAccountViewAddress = {"container": settingsContentBase_ScrollView, "objectName": "Address_ListItem", "type": "WalletAccountDetailsListItem"}
walletAccountViewKeypairItem = {"container": settingsContentBase_ScrollView, "objectName": "KeyPair_Item", "type": "WalletAccountDetailsKeypairItem"}
walletAccountViewOrigin = {"container": settingsContentBase_ScrollView, "objectName": "Origin_ListItem", "type": "WalletAccountDetailsListItem"}
walletAccountViewDerivationPath = {"container": settingsContentBase_ScrollView, "objectName": "DerivationPath_ListItem", "type": "WalletAccountDetailsListItem"}
walletAccountViewStored = {"container": settingsContentBase_ScrollView, "objectName": "Stored_ListItem", "type": "WalletAccountDetailsListItem"}
walletAccountViewPreferredNetworks = {"container": settingsContentBase_ScrollView, "objectName": "PreferredNetworks_ListItem", "type": "StatusListItem"}

# Wallet edit network view
settingsContentBaseScrollView_editPreviwTabBar_StatusTabBar = {"container": statusDesktop_mainWindow, "objectName": "editPreviwTabBar", "type": "StatusTabBar"}
editNetworkLiveButton = {"container": settingsContentBaseScrollView_editPreviwTabBar_StatusTabBar, "objectName": "editNetworkLiveButton", "type": "StatusTabButton"}
editNetworkTestButton = {"container": settingsContentBaseScrollView_editPreviwTabBar_StatusTabBar, "objectName": "editNetworkTestButton", "type": "StatusTabButton"}
editNetworkNameInput = {"container": statusDesktop_mainWindow, "objectName": "editNetworkNameInput", "type": "TextEdit"}
editNetworkShortNameInput = {"container": statusDesktop_mainWindow, "objectName": "editNetworkShortNameInput", "type": "TextEdit"}
editNetworkChainIdInput = {"container": statusDesktop_mainWindow, "objectName": "editNetworkChainIdInput", "type": "TextEdit"}
editNetworkSymbolInput = {"container": statusDesktop_mainWindow, "objectName": "editNetworkSymbolInput", "type": "TextEdit"}
editNetworkMainRpcInput = {"container": statusDesktop_mainWindow, "objectName": "editNetworkMainRpcInput", "type": "TextEdit", "visible": True}
editNetworkFailoverRpcUrlInput = {"container": statusDesktop_mainWindow, "objectName": "editNetworkFailoverRpcUrlInput", "type": "TextEdit", "visible": True}
editNetworkExplorerInput = {"container": statusDesktop_mainWindow, "objectName": "editNetworkExplorerInput", "type": "TextEdit"}
editNetworkAknowledgmentCheckbox = {"container": statusDesktop_mainWindow, "objectName": "editNetworkAknowledgmentCheckbox", "type": "StatusCheckBox", "visible": True}
editNetworkRevertButton = {"container": statusDesktop_mainWindow, "objectName": "editNetworkRevertButton", "type": "StatusButton"}
editNetworkSaveButton = {"container": statusDesktop_mainWindow, "objectName": "editNetworkSaveButton", "type": "StatusButton"}
mainRpcUrlInputObject = {"container": settingsContentBase_ScrollView, "objectName": "mainRpcInputObject", "type": "StatusInput", "visible": True}
failoverRpcUrlInputObject = {"container": settingsContentBase_ScrollView, "objectName": "failoverRpcUrlInputObject", "type": "StatusInput", "visible": True}

# Profile View
mainWindow_MyProfileView = {"container": statusDesktop_mainWindow, "type": "MyProfileView", "unnamed": 1, "visible": True}
displayName_StatusInput = {"container": statusDesktop_mainWindow, "objectName": "displayNameInput", "type": "StatusInput", "visible": True}
displayName_TextEdit = {"container": displayName_StatusInput, "type": "TextEdit", "unnamed": 1, "visible": True}
change_password_button = {"container": statusDesktop_mainWindow, "type": "StatusButton", "objectName": "profileSettingsChangePasswordButton", "visible": True}
bio_StatusInput = {"container": statusDesktop_mainWindow, "objectName": "bioInput", "type": "StatusInput", "visible": True}
bio_TextEdit = {"container": bio_StatusInput, "type": "TextEdit", "unnamed": 1, "visible": True}
addMoreSocialLinks = {"container": statusDesktop_mainWindow, "objectName": "addMoreSocialLinks", "type": "StatusLinkText", "visible": True}
mainWindow_profileTabBar_StatusTabBar = {"container": statusDesktop_mainWindow, "id": "profileTabBar", "type": "StatusTabBar", "unnamed": 1, "visible": True}
profileTabBar_Web_StatusTabButton = {"checkable": True, "container": mainWindow_profileTabBar_StatusTabBar, "objectName": "webTabButton", "type": "StatusTabButton", "visible": True}
profileTabBar_Identity_StatusTabButton = {"checkable": True, "container": mainWindow_profileTabBar_StatusTabBar, "objectName": "identityTabButton", "type": "StatusTabButton", "visible": True}

# Password view
mainWindow_PasswordView = {"container": statusDesktop_mainWindow, "type": "ChangePasswordView", "unnamed": 1, "visible": True}

# Syncing Settings View
mainWindow_SyncingView = {"container": statusDesktop_mainWindow, "type": "SyncingView", "unnamed": 1, "visible": True}
settings_Setup_Syncing_StatusButton = {"container": statusDesktop_mainWindow, "objectName": "setupSyncingStatusButton", "type": "StatusButton", "visible": True}
settings_Backup_Data_StatusButton = {"container": settingsContentBase_ScrollView, "objectName": "setupSyncBackupDataButton", "type": "StatusButton", "visible": True}
settings_Sync_New_Device_Header = {"container": settingsContentBase_ScrollView, "objectName": "syncNewDeviceTextLabel", "type": "StatusBaseText", "visible": True}
settings_Sync_New_Device_SubTitle = {"container": settingsContentBase_ScrollView, "objectName": "syncNewDeviceSubTitleTextLabel", "type": "StatusBaseText", "visible": True}

#Sing out and quit View
signOutConfirmationButton = {"container": statusDesktop_mainWindow_overlay, "objectName": "signOutConfirmation", "type": "StatusButton", "visible": True}

# ENS usernames View
mainWindow_EnsWelcomeView = {"container": statusDesktop_mainWindow, "type": "EnsWelcomeView", "unnamed": 1, "visible": True}
mainWindow_Start_StatusButton = {"checkable": False, "container": statusDesktop_mainWindow, "objectName": "ensStartButton", "type": "StatusButton", "visible": True}
mainWindow_EnsSearchView = {"container": statusDesktop_mainWindow, "type": "EnsSearchView", "unnamed": 1, "visible": True}
mainWindow_ensUsernameInput_StyledTextField = {"container": statusDesktop_mainWindow, "objectName": "ensUsernameInput", "type": "StyledTextField", "visible": True}
mainWindow_ensNextButton_StatusRoundButton = {"container": statusDesktop_mainWindow, "objectName": "ensNextButton", "type": "StatusRoundButton", "visible": True}
ens_StatusBaseText = {"container": mainWindow_EnsSearchView, "type": "StatusBaseText", "unnamed": 1, "visible": True}
mainWindow_EnsTermsAndConditionsView = {"container": statusDesktop_mainWindow, "type": "EnsTermsAndConditionsView", "unnamed": 1, "visible": True}
mainWindow_sview_StatusScrollView = {"container": statusDesktop_mainWindow, "id": "sview", "type": "StatusScrollView", "unnamed": 1, "visible": True}
sview_walletAddressLbl_StatusDescriptionListItem = {"container": mainWindow_sview_StatusScrollView, "id": "walletAddressLbl", "type": "StatusDescriptionListItem", "unnamed": 1, "visible": True}
sview_keyLbl_StatusDescriptionListItem = {"container": mainWindow_sview_StatusScrollView, "id": "keyLbl", "type": "StatusDescriptionListItem", "unnamed": 1, "visible": True}
sview_ensAgreeTerms_StatusCheckBox = {"checkable": True, "container": mainWindow_sview_StatusScrollView, "objectName": "ensAgreeTerms", "type": "StatusCheckBox", "visible": True}
mainWindow_Register_StatusButton = {"checkable": False, "container": statusDesktop_mainWindow, "objectName": "ensStartTransaction", "text": "Register", "type": "StatusButton", "visible": True}
mainWindow_EnsRegisteredView = {"container": statusDesktop_mainWindow, "type": "EnsRegisteredView", "unnamed": 1, "visible": True}

# ONBOARDING NAMES
mainWindow_onboardingBackButton_StatusRoundButton = {"container": statusDesktop_mainWindow, "objectName": "onboardingBackButton", "type": "StatusRoundButton", "visible": True}

# Advanced view
mainWindow_AdvancedView = {"container": mainWindow_StatusWindow, "type": "AdvancedView", "unnamed": 1, "visible": True}
mainWindow_settingsContentBaseScrollView_StatusScrollView = {"container": mainWindow_StatusWindow, "objectName": "settingsContentBaseScrollView", "type": "StatusScrollView", "visible": True}
manageCommunitiesOnTestnetButton_StatusSettingsLineButton = {"container": mainWindow_settingsContentBaseScrollView_StatusScrollView, "objectName": "manageCommunitiesOnTestnetButton", "type": "StatusSettingsLineButton", "visible": True}
enableCreateCommunityButton_StatusSettingsLineButton = {"container": settingsContentBase_ScrollView, "objectName": "enableCreateCommunityButton", "type": "StatusSettingsLineButton", "visible": True}

# Allow Notification View
mainWindow_AllowNotificationsView = {"container": statusDesktop_mainWindow, "type": "AllowNotificationsView", "unnamed": 1, "visible": True}
mainWindow_Start_using_Status_StatusButton = {"checkable": False, "container": statusDesktop_mainWindow, "objectName": "allowNotificationsOnboardingOkButton", "type": "StatusButton", "visible": True}

# Welcome View
mainWindow_WelcomeView = {"container": statusDesktop_mainWindow, "type": "WelcomeView", "unnamed": 1, "visible": True}
mainWindow_I_am_new_to_Status_StatusBaseText = {"container": mainWindow_WelcomeView, "objectName": "welcomeViewIAmNewToStatusButton", "type": "StatusButton"}
mainWindow_I_already_use_Status_StatusFlatButton = {"checkable": False, "container": statusDesktop_mainWindow, "id": "btnExistingUser", "type": "StatusFlatButton", "visible": True}

# Get Keys View
mainWindow_KeysMainView = {"container": statusDesktop_mainWindow, "type": "KeysMainView", "unnamed": 1, "visible": True}
mainWindow_Generate_new_keys_StatusButton = {"checkable": False, "container": mainWindow_KeysMainView, "objectName": "keysMainViewPrimaryActionButton", "type": "StatusButton", "visible": True}
mainWindow_Generate_keys_for_new_Keycard_StatusBaseText = {"container": mainWindow_KeysMainView, "id": "button2",
                                                           "type": "StatusBaseText", "unnamed": 1, "visible": True}
mainWindow_Import_seed_phrase = {"container": mainWindow_KeysMainView, "id": "button3", "type": "Row", "unnamed": 1,
                                 "visible": True}

# Import Seed Phrase View
keysMainView_PrimaryAction_Button = {"container": statusDesktop_mainWindow,
                                     "objectName": "keysMainViewPrimaryActionButton", "type": "StatusButton"}

# Seed Phrase Input View
mainWindow_SeedPhraseInputView = {"container": statusDesktop_mainWindow, "type": "SeedPhraseInputView", "unnamed": 1,
                                  "visible": True}
switchTabBar_12_words_Button = {"container": mainWindow_SeedPhraseInputView, "objectName": "12SeedButton",
                                "type": "StatusSwitchTabButton"}
switchTabBar_18_words_Button = {"container": mainWindow_SeedPhraseInputView, "objectName": "18SeedButton",
                                "type": "StatusSwitchTabButton"}
switchTabBar_24_words_Button = {"container": mainWindow_SeedPhraseInputView, "objectName": "24SeedButton",
                                "type": "StatusSwitchTabButton"}
mainWindow_statusSeedPhraseInputField_TextEdit = {"container": mainWindow_StatusWindow, "objectName": "enterSeedPhraseInputField", "type": "TextEdit", "visible": True}

mainWindow_Import_StatusButton = {"checkable": False, "container": mainWindow_SeedPhraseInputView,
                                  "objectName": "seedPhraseViewSubmitButton", "text": "Import", "type": "StatusButton",
                                  "visible": True}

# SyncCode View
mainWindow_SyncCodeView = {"container": statusDesktop_mainWindow, "type": "SyncCodeView", "unnamed": 1, "visible": True}
mainWindow_switchTabBar_StatusSwitchTabBar_2 = {"container": statusDesktop_mainWindow, "id": "switchTabBar", "type": "StatusSwitchTabBar", "unnamed": 1, "visible": True}
switchTabBar_Enter_sync_code_StatusSwitchTabButton = {"checkable": True, "container": mainWindow_switchTabBar_StatusSwitchTabBar_2, "text": "Enter sync code", "type": "StatusSwitchTabButton", "unnamed": 1, "visible": True}
mainWindow_statusBaseInput_StatusBaseInput = {"container": statusDesktop_mainWindow, "id": "statusBaseInput", "type": "StatusBaseInput", "unnamed": 1, "visible": True}
mainWindow_Paste_StatusButton = {"container": statusDesktop_mainWindow, "objectName": "syncCodePasteButton", "type": "StatusButton", "visible": True}
mainWindow_syncingEnterCode_SyncingEnterCode = {"container": mainWindow_StatusWindow, "objectName": "syncingEnterCode", "type": "SyncingEnterCode", "visible": True}

# SyncDevice View
mainWindow_SyncingDeviceView_found = {"container": statusDesktop_mainWindow, "type": "SyncingDeviceView", "unnamed": 1, "visible": True}
mainWindow_SyncingDeviceView_synced = {"container": mainWindow_StatusWindow, "type": "SyncingDeviceView", "unnamed": 1, "visible": True}
mainWindow_SyncDeviceResult = {"container": mainWindow_StatusWindow, "type": "SyncDeviceResult", "unnamed": 1, "visible": True}
synced_StatusBaseText = {"container": mainWindow_StatusWindow, "type": "StatusBaseText", "unnamed": 1, "visible": True}
mainWindow_Sign_in_StatusButton = {"checkable": False, "container": mainWindow_StatusWindow, "text": "Sign in", "type": "StatusButton", "unnamed": 1, "visible": True}
sync_text_item = {"container": statusDesktop_mainWindow, "type": "StatusBaseText", "unnamed": 1, "visible": True}

# Keycard Init View
mainWindow_KeycardInitView = {"container": statusDesktop_mainWindow, "type": "KeycardInitView", "unnamed": 1,
                              "visible": True}
mainWindow_Plug_in_Keycard_reader_StatusBaseText = {"container": mainWindow_KeycardInitView, "type": "StatusBaseText",
                                                    "unnamed": 1, "visible": True}

# Your Profile View
mainWindow_InsertDetailsView = {"container": statusDesktop_mainWindow, "objectName": "onboardingInsertDetailsView", "type": "InsertDetailsView", "visible": True}
updatePicButton_StatusRoundButton = {"container": mainWindow_InsertDetailsView, "id": "updatePicButton", "type": "StatusRoundButton", "unnamed": 1, "visible": True}
mainWindow_statusRoundImage_StatusRoundedImage = {"container": statusDesktop_mainWindow, "id": "statusRoundImage", "type": "StatusRoundedImage", "unnamed": 1, "visible": True}
mainWindow_IdenticonRing = {"container": statusDesktop_mainWindow, "type": "StatusIdenticonRing", "unnamed": 1, "visible": True}
mainWindow_Next_StatusButton = {"checkable": False, "container": mainWindow_StatusWindow, "objectName": "onboardingDetailsViewNextButton", "type": "StatusButton", "visible": True}
mainWindow_inputLayout_ColumnLayout = {"container": statusDesktop_mainWindow, "id": "inputLayout", "type": "ColumnLayout", "unnamed": 1, "visible": True}
mainWindow_statusBaseInput_StatusBaseInput = {"container": mainWindow_inputLayout_ColumnLayout, "objectName": "onboardingDisplayNameInput", "type": "TextEdit", "visible": True}
mainWindow_errorMessage_StatusBaseText = {"container": mainWindow_inputLayout_ColumnLayout, "type": "StatusBaseText", "unnamed": 1, "visible": True}
mainWindow_nameInput_StatusInput = {"container": statusDesktop_mainWindow, "id": "nameInput", "type": "StatusInput", "unnamed": 1, "visible": True}
mainWindow_clear_icon_StatusIcon = {"container": statusDesktop_mainWindow, "objectName": "clear-icon", "type": "StatusIcon"}

# Your emojihash and identicon ring
mainWindow_welcomeScreenUserProfileImage_StatusSmartIdenticon = {"container": mainWindow_InsertDetailsView, "objectName": "welcomeScreenUserProfileImage", "type": "StatusSmartIdenticon", "visible": True}
mainWindow_insertDetailsViewChatKeyTxt_StyledText = {"container": statusDesktop_mainWindow, "objectName": "profileChatKeyViewChatKeyTxt", "type": "StyledText", "visible": True}
mainWindow_EmojiHash = {"container": statusDesktop_mainWindow, "objectName": "publicKeyEmojiHash", "type": "EmojiHash", "visible": True}
mainWindow_Header_Title = {"container": statusDesktop_mainWindow, "objectName": "onboardingHeaderText", "type": "StyledText", "visible": True}
mainWindow_userImageCopy_StatusSmartIdenticon = {"container": statusDesktop_mainWindow, "id": "userImageCopy", "type": "StatusSmartIdenticon", "unnamed": 1, "visible": True}
profileImageCropper = {"container": statusDesktop_mainWindow, "objectName": "imageCropWorkflow", "type": "ImageCropWorkflow", "visible": True}

# Create Password View
mainWindow_CreatePasswordView = {"container": statusDesktop_mainWindow, "type": "CreatePasswordView", "unnamed": 1, "visible": True}
mainWindow_passwordViewNewPassword = {"container": mainWindow_CreatePasswordView, "objectName": "passwordViewNewPassword", "type": "StatusPasswordInput", "visible": True}
mainWindow_passwordViewNewPasswordConfirm = {"container": mainWindow_CreatePasswordView, "objectName": "passwordViewNewPasswordConfirm", "type": "StatusPasswordInput", "visible": True}
mainWindow_Create_password_StatusButton = {"checkable": False, "container": mainWindow_CreatePasswordView, "objectName": "onboardingCreatePasswordButton", "type": "StatusButton", "visible": True}
mainWindow_view_PasswordView = {"container": statusDesktop_mainWindow, "id": "view", "type": "PasswordView", "unnamed": 1, "visible": True}
mainWindow_RowLayout = {"container": mainWindow_StatusWindow, "type": "RowLayout", "unnamed": 1, "visible": True}
mainWindow_strengthInditactor_StatusPasswordStrengthIndicator = {"container": mainWindow_StatusWindow, "id": "strengthInditactor", "type": "StatusPasswordStrengthIndicator", "unnamed": 1, "visible": True}
mainWindow_show_icon_StatusIcon = {"container": mainWindow_StatusWindow, "objectName": "show-icon", "type": "StatusIcon", "visible": True}
mainWindow_hide_icon_StatusIcon = {"container": mainWindow_StatusWindow, "objectName": "hide-icon", "type": "StatusIcon", "visible": True}

# Confirm Password View
mainWindow_ConfirmPasswordView = {"container": statusDesktop_mainWindow, "type": "ConfirmPasswordView", "unnamed": 1,"visible": True}
mainWindow_confirmAgainPasswordInput = {"container": mainWindow_ConfirmPasswordView, "objectName": "confirmAgainPasswordInput", "type": "StatusPasswordInput", "visible": True}
mainWindow_Finalise_Status_Password_Creation_StatusButton = {"checkable": False, "container": mainWindow_ConfirmPasswordView, "objectName": "confirmPswSubmitBtn", "type": "StatusButton", "visible": True}
mainWindow_passwordView_PasswordConfirmationView = {"container": statusDesktop_mainWindow, "id": "passwordView", "type": "PasswordConfirmationView", "unnamed": 1, "visible": True}

# Login View
mainWindow_LoginView = {"container": statusDesktop_mainWindow, "type": "LoginView", "unnamed": 1, "visible": True}
loginView_submitBtn = {"container": mainWindow_LoginView, "type": "StatusRoundButton", "visible": True}
loginView_passwordInput = {"container": mainWindow_LoginView, "objectName": "loginPasswordInput", "type": "StyledTextField"}
loginView_currentUserNameLabel = {"container": mainWindow_LoginView, "objectName": "currentUserNameLabel", "type": "StatusBaseText"}
loginView_changeAccountBtn = {"container": mainWindow_LoginView, "objectName": "loginChangeAccountButton", "type": "StatusFlatRoundButton"}
accountsView_accountListPanel = {"container": statusDesktop_mainWindow, "objectName": "LoginView_AccountsRepeater", "type": "Repeater", "visible": True}
mainWindow_txtPassword_Input = {"container": statusDesktop_mainWindow, "id": "txtPassword", "type": "Input", "unnamed": 1, "visible": True}

# Touch ID Auth View
mainWindow_TouchIDAuthView = {"container": statusDesktop_mainWindow, "type": "TouchIDAuthView", "unnamed": 1, "visible": True}
mainWindow_touchIdYesUseTouchIDButton = {"container": statusDesktop_mainWindow, "objectName": "touchIdYesUseTouchIDButton", "type": "StatusButton", "visible": True}
mainWindow_touchIdIPreferToUseMyPasswordText = {"container": statusDesktop_mainWindow, "objectName": "touchIdIPreferToUseMyPasswordText", "type": "StatusBaseText"}

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

# Wallet Account View
mainWindow_RightTabView = {"container": statusDesktop_mainWindow, "type": "RightTabView", "unnamed": 1, "visible": True}
mainWallet_Account_Name = {"container": mainWindow_RightTabView, "objectName": "walletHeaderTitle", "type": "StatusBaseText", "visible": True}
mainWindow_Send_Button = {"container": statusDesktop_mainWindow, "objectName": "walletFooterSendButton", "type": "StatusFlatButton", "visible": True}
mainWindow_RightTabView = {"container": mainWindow_StatusWindow, "type": "RightTabView", "unnamed": 1, "visible": True}
filterButton_StatusFlatButton = {"checkable": True, "container": mainWindow_RightTabView, "objectName": "filterButton", "type": "StatusFlatButton", "visible": True}
cmbTokenOrder_SortOrderComboBox = {"container": mainWindow_RightTabView, "objectName": "cmbTokenOrder", "type": "SortOrderComboBox", "visible": True}
rightSideWalletTabBar_StatusTabBar = {"container": mainWindow_RightTabView, "objectName": "rightSideWalletTabBar", "type": "StatusTabBar", "visible": True}
rightSideWalletTabBar_Assets_StatusTabButton = {"checkable": True, "container": rightSideWalletTabBar_StatusTabBar, "objectName": "assetsTabButton", "text": "Assets", "type": "StatusTabButton", "visible": True}
rightSideWalletTabBar_Collectibles_StatusTabButton = {"checkable": True, "container": rightSideWalletTabBar_StatusTabBar, "objectName": "collectiblesTabButton", "text": "Collectibles", "type": "StatusTabButton", "visible": True}
rightSideWalletTabBar_Activity_StatusTabButton = {"checkable": True, "container": rightSideWalletTabBar_StatusTabBar, "objectName": "activityTabButton", "text": "Activity", "type": "StatusTabButton", "visible": True}
o_AssetsView = {"container": mainWindow_RightTabView, "type": "AssetsView", "unnamed": 1, "visible": True}
itemDelegate = {"checkable": False, "container": statusDesktop_mainWindow_overlay, "id": "menuDelegate", "type": "ItemDelegate", "unnamed": 1, "visible": True}
assetView_TokenListItem_TokenDelegate = {"container": mainWindow_RightTabView, "objectName": RegularExpression("AssetView_TokenListItem_*"), "type": "TokenDelegate", "visible": True}
arrow_icon_StatusIcon = {"container": statusDesktop_mainWindow_overlay, "objectName": "arrow-up-icon", "type": "StatusIcon", "visible": True}

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
