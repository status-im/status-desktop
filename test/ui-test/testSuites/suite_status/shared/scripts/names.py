# encoding: UTF-8

from objectmaphelper import *

# Global UI objects:
statusDesktop_mainWindow = {"name": "mainWindow", "type": "StatusWindow", "visible": True}
statusDesktop_mainWindow_overlay = {"container": statusDesktop_mainWindow, "type": "Overlay", "unnamed": 1, "visible": True}

mainWindow_ScrollView = {"container": statusDesktop_mainWindow, "type": "StatusScrollView", "unnamed": 1, "visible": True}
mainWindow_scrollView_ScrollView = {"container": statusDesktop_mainWindow, "id": "scrollView", "type": "StatusScrollView", "unnamed": 1, "visible": True}
mainWindow_startChat = {"checkable": True, "container": statusDesktop_mainWindow, "objectName": "startChatButton", "type": "StatusIconTabButton"}
mainWindow_dropRectangle_Rectangle = {"container": statusDesktop_mainWindow, "id": "dropRectangle", "type": "Rectangle", "unnamed": 1, "visible": True}
acknowledge_checkbox = {"checkable": True, "container": statusDesktop_mainWindow_overlay, "objectName": "acknowledgeCheckBox", "type": "StatusCheckBox", "visible": True}
termsOfUseCheckBox_StatusCheckBox = {"checkable": True, "container": statusDesktop_mainWindow_overlay, "objectName":"termsOfUseCheckBox", "type": "StatusCheckBox", "visible": True}
getStartedStatusButton_StatusButton = {"container": statusDesktop_mainWindow_overlay, "objectName": "getStartedStatusButton", "type": "StatusButton", "visible": True}
mainWindow_I_am_new_to_Status_StatusBaseText = {"container": statusDesktop_mainWindow, "text": "I am new to Status", "type": "StatusBaseText", "unnamed": 1, "visible": True}
mainWindow_Generate_new_keys_StatusBaseText = {"container": statusDesktop_mainWindow, "text": "Generate new keys", "type": "StatusBaseText", "unnamed": 1, "visible": True}
get_Started_StatusBaseText = {"container": statusDesktop_mainWindow_overlay, "text": "Get Started", "type": "StatusBaseText", "unnamed": 1, "visible": True}
i_accept_Status_StatusBaseText = {"container": statusDesktop_mainWindow_overlay, "text": "I accept Status", "type": "StatusBaseText", "unnamed": 1, "visible": True}
termsOfUseLink_StatusBaseText = {"container": statusDesktop_mainWindow_overlay, "objectName": "termsOfUseLink", "type": "StatusBaseText", "visible": True}
mainWindow_edit_TextEdit = {"container": statusDesktop_mainWindow, "type": "TextEdit", "unnamed": 1, "visible": True}
mainWindow_Next_StatusBaseText = {"container": statusDesktop_mainWindow, "text": "Next", "type": "StatusBaseText", "unnamed": 1, "visible": True}
mainWindow_Display_name_StatusBaseText = {"container": statusDesktop_mainWindow, "text": "Display name", "type": "StatusBaseText", "unnamed": 1, "visible": True}
mainWindow_nextBtn_StatusButton = {"container": statusDesktop_mainWindow, "type": "StatusButton", "unnamed": 1, "visible": True}
mainWindow_Password_textField = {"container": statusDesktop_mainWindow, "echoMode": 2, "occurrence": 2, "passwordCharacter": "•", "type": "StyledTextField", "unnamed": 1, "visible": True}
mainWindow_Rectangle = {"container": statusDesktop_mainWindow, "occurrence": 11, "type": "Rectangle", "unnamed": 1, "visible": True}
mainWindow_I_prefer_to_use_my_password_StatusBaseText = {"container": statusDesktop_mainWindow, "text": "I prefer to use my password", "type": "StatusBaseText", "unnamed": 1, "visible": True}
mainWindow_Enter_password_PlaceholderText = {"container": statusDesktop_mainWindow, "text": "Enter password", "type": "PlaceholderText", "unnamed": 1, "visible": True}
mainWindow_button_StatusButton = {"container": statusDesktop_mainWindow, "id": "button", "type": "StatusButton", "unnamed": 1, "visible": True}
mainWindow_Username_must_be_at_least_5_characters_StatusBaseText = {"container": statusDesktop_mainWindow, "text": "Username must be at least 5 characters", "type": "StatusBaseText", "unnamed": 1, "visible": True}
mainWindow_Passwords_don_t_match_StatusBaseText = {"container": statusDesktop_mainWindow, "text": "Passwords don't match", "type": "StatusBaseText", "unnamed": 1, "visible": True}
mainWindow_inputRectangle_Rectangle = {"container": statusDesktop_mainWindow, "id": "inputRectangle", "occurrence": 2, "type": "Rectangle", "unnamed": 1, "visible": True}
mainWindow_inputRectangle_Rectangle_2 = {"container": statusDesktop_mainWindow, "id": "inputRectangle", "type": "Rectangle", "unnamed": 1, "visible": True}
mainWindow_You_will_not_be_able_to_recover_this_password_if_it_is_lost_StatusBaseText = {"container": statusDesktop_mainWindow, "text": "You will not be able to recover this password if it is lost.", "type": "StatusBaseText", "unnamed": 1, "visible": True}
mainWindow_Ok_got_it_StatusBaseText = {"container": statusDesktop_mainWindow, "text": "Ok, got it", "type": "StatusBaseText", "unnamed": 1, "visible": True}
mainWindow_background_Rectangle = {"container": statusDesktop_mainWindow, "id": "background", "type": "Rectangle", "unnamed": 1, "visible": True}
o_Rectangle = {"container": statusDesktop_mainWindow_overlay, "occurrence": 2, "type": "Rectangle", "unnamed": 1, "visible": True}
edit_TextEdit = {"container": statusDesktop_mainWindow_overlay, "id": "edit", "type": "TextEdit", "unnamed": 1, "visible": True}
background_Rectangle = {"container": statusDesktop_mainWindow_overlay, "id": "background", "type": "Rectangle", "unnamed": 1, "visible": True}
statusIcon_StatusIcon = {"container": statusDesktop_mainWindow_overlay, "id": "statusIcon", "source": "qrc:/StatusQ/src/assets/img/icons/clear.svg", "type": "StatusIcon", "unnamed": 1, "visible": True}
statusIcon_StatusIcon_2 = {"container": statusDesktop_mainWindow_overlay, "id": "statusIcon", "source": "qrc:/StatusQ/src/assets/img/icons/close.svg", "type": "StatusIcon", "unnamed": 1, "visible": True}
o_Rectangle_2 = {"container": statusDesktop_mainWindow_overlay, "type": "Rectangle", "unnamed": 1, "visible": True}
mainWindow_statusIcon_StatusIcon = {"container": statusDesktop_mainWindow, "id": "statusIcon", "source": "qrc:/StatusQ/src/assets/img/icons/arrow-right.svg", "type": "StatusIcon", "unnamed": 1, "visible": True}
join_public_chat_StatusMenuItemDelegate = {"checkable": False, "container": statusDesktop_mainWindow_overlay, "enabled": True, "text": "Join public chat", "type": "StatusMenuItemDelegate", "unnamed": 1, "visible": True}
chat_name_PlaceholderText = {"container": statusDesktop_mainWindow_overlay, "text": "chat-name", "type": "PlaceholderText", "unnamed": 1, "visible": True}
inputValue_StyledTextField = {"container": statusDesktop_mainWindow_overlay, "echoMode": 0, "id": "inputValue", "type": "StyledTextField", "unnamed": 1, "visible": True}
reactionImage_SVGImage = {"container": statusDesktop_mainWindow_overlay, "id": "reactionImage", "source": "qrc:/imports/assets/icons/emojiReactions/heart.svg", "type": "SVGImage", "unnamed": 1, "visible": True}
mainWindow_statusIcon_StatusIcon_2 = {"container": statusDesktop_mainWindow, "id": "statusIcon", "source": "qrc:/StatusQ/src/assets/img/icons/public-chat.svg", "type": "StatusIcon", "unnamed": 1, "visible": True}
import_a_seed_phrase_StatusBaseText = {"container": statusDesktop_mainWindow, "text": "Import a seed phrase", "type": "StatusBaseText", "unnamed": 1, "visible": True}
mainWindow_placeholder_StatusBaseText = {"container": statusDesktop_mainWindow, "id": "placeholder", "type": "StatusBaseText", "unnamed": 1, "visible": True}
mainWindow_Image = {"container": statusDesktop_mainWindow, "source": "qrc:/imports/assets/png/traffic_lights/close.png", "type": "Image", "unnamed": 1, "visible": True}
mainWindow_edit_TextEdit_2 = {"container": statusDesktop_mainWindow, "id": "edit", "occurrence": 7, "type": "TextEdit", "unnamed": 1, "visible": True}
mainWindow_edit_TextEdit_3 = {"container": statusDesktop_mainWindow, "id": "edit", "occurrence": 2, "type": "TextEdit", "unnamed": 1, "visible": True}
mainWindow_edit_TextEdit_4 = {"container": statusDesktop_mainWindow, "id": "edit", "occurrence": 8, "type": "TextEdit", "unnamed": 1, "visible": True}
mainWindow_btnOk_StatusButton = {"container": statusDesktop_mainWindow, "id": "btnOk", "type": "StatusButton", "unnamed": 1, "visible": True}
mainWindow_Rectangle_2 = {"container": statusDesktop_mainWindow, "occurrence": 32, "type": "Rectangle", "unnamed": 1, "visible": True}
mainWindow_switchTabBar_StatusSwitchTabBar = {"container": statusDesktop_mainWindow, "id": "switchTabBar", "type": "StatusSwitchTabBar", "unnamed": 1, "visible": True}
switchTabBar_18_words_StatusBaseText = {"container": mainWindow_switchTabBar_StatusSwitchTabBar, "text": "18 words", "type": "StatusBaseText", "unnamed": 1, "visible": True}
switchTabBar_24_words_StatusBaseText = {"container": mainWindow_switchTabBar_StatusSwitchTabBar, "text": "24 words", "type": "StatusBaseText", "unnamed": 1, "visible": True}
switchTabBar_12_words_StatusBaseText = {"container": mainWindow_switchTabBar_StatusSwitchTabBar, "text": "12 words", "type": "StatusBaseText", "unnamed": 1, "visible": True}
mainWindow_grid_GridView = {"container": statusDesktop_mainWindow, "id": "grid", "type": "GridView", "unnamed": 1, "visible": True}
grid_seedWordInput_StatusSeedPhraseInput = {"container": mainWindow_grid_GridView, "id": "seedWordInput", "index": 5, "type": "StatusSeedPhraseInput", "unnamed": 1, "visible": True}
seedWordInput_background_Rectangle = {"container": grid_seedWordInput_StatusSeedPhraseInput, "id": "background", "type": "Rectangle", "unnamed": 1, "visible": True}
mainWindow_statusIcon_StatusIcon_3 = {"container": statusDesktop_mainWindow, "id": "statusIcon", "occurrence": 3, "source": "qrc:/StatusQ/src/assets/img/icons/arrow-left.svg", "type": "StatusIcon", "unnamed": 1, "visible": True}
mainWindow_statusIcon_StatusIcon_4 = {"container": statusDesktop_mainWindow, "id": "statusIcon", "source": "qrc:/StatusQ/src/assets/img/icons/arrow-left.svg", "type": "StatusIcon", "unnamed": 1, "visible": True}
mainWindow_Rectangle_3 = {"container": statusDesktop_mainWindow, "occurrence": 4, "type": "Rectangle", "unnamed": 1, "visible": True}
mainWindow_edit_TextEdit_5 = {"container": statusDesktop_mainWindow, "id": "edit", "occurrence": 3, "type": "TextEdit", "unnamed": 1, "visible": True}
grid_seedWordInput_StatusSeedPhraseInput_2 = {"container": mainWindow_grid_GridView, "id": "seedWordInput", "index": 2, "type": "StatusSeedPhraseInput", "unnamed": 1, "visible": True}
seedWordInput_seedSuggestionsList_ListView = {"container": grid_seedWordInput_StatusSeedPhraseInput_2, "id": "seedSuggestionsList", "type": "ListView", "unnamed": 1, "visible": True}
seedSuggestionsList_txtDelegate_Item = {"container": seedWordInput_seedSuggestionsList_ListView, "id": "txtDelegate", "index": 0, "type": "Item", "unnamed": 1, "visible": True}
txtDelegate_Rectangle = {"container": seedSuggestionsList_txtDelegate_Item, "type": "Rectangle", "unnamed": 1, "visible": True}
mainWindow_edit_TextEdit_6 = {"container": statusDesktop_mainWindow, "id": "edit", "occurrence": 4, "type": "TextEdit", "unnamed": 1, "visible": True}
grid_seedWordInput_StatusSeedPhraseInput_3 = {"container": mainWindow_grid_GridView, "id": "seedWordInput", "index": 3, "type": "StatusSeedPhraseInput", "unnamed": 1, "visible": True}
seedWordInput_seedSuggestionsList_ListView_2 = {"container": grid_seedWordInput_StatusSeedPhraseInput_3, "id": "seedSuggestionsList", "type": "ListView", "unnamed": 1, "visible": True}
seedSuggestionsList_txtDelegate_Item_2 = {"container": seedWordInput_seedSuggestionsList_ListView_2, "id": "txtDelegate", "index": 0, "type": "Item", "unnamed": 1, "visible": True}
txtDelegate_survey_StatusBaseText = {"container": seedSuggestionsList_txtDelegate_Item_2, "text": "survey", "type": "StatusBaseText", "unnamed": 1, "visible": True}
mainWindow_Restore_Status_Profile_StatusBaseText = {"container": statusDesktop_mainWindow, "text": "Restore Status Profile", "type": "StatusBaseText", "unnamed": 1, "visible": True}
mainWindow_Rectangle_4 = {"container": statusDesktop_mainWindow, "occurrence": 31, "type": "Rectangle", "unnamed": 1, "visible": True}
mainWindow_submitButton_StatusButton = {"container": statusDesktop_mainWindow, "id": "submitButton", "type": "StatusButton", "unnamed": 1, "visible": True}
i_understand_StatusBaseText = {"container": statusDesktop_mainWindow_overlay, "text": "I understand", "type": "StatusBaseText", "unnamed": 1, "visible": True}
mainWindow_navBarListView_ListView = {"container": statusDesktop_mainWindow, "type": "ListView", "unnamed": 1, "visible": True}
navBarListView_StatusNavBarTabButton = {"checkable": True, "container": mainWindow_navBarListView_ListView, "occurrence": 4, "type": "StatusNavBarTabButton", "unnamed": 1, "visible": True}
statusIcon_StatusIcon_3 = {"container": navBarListView_StatusNavBarTabButton, "id": "statusIcon", "source": "qrc:/StatusQ/src/assets/img/icons/settings.svg", "type": "StatusIcon", "unnamed": 1, "visible": True}
privacy_and_security_StatusBaseText = {"container": mainWindow_ScrollView, "text": "Privacy and security", "type": "StatusBaseText", "unnamed": 1, "visible": True}
settingsMenuDelegate_StatusNavigationListItem = {"container": mainWindow_ScrollView, "id": "settingsMenuDelegate", "occurrence": 4, "type": "StatusNavigationListItem", "unnamed": 1, "visible": True}
language_Currency_StatusBaseText = {"container": mainWindow_ScrollView, "text": "Language & Currency", "type": "StatusBaseText", "unnamed": 1, "visible": True}
advanced_StatusBaseText = {"container": statusDesktop_mainWindow, "text": "Advanced", "type": "StatusBaseText", "unnamed": 1, "visible": True}
mainWindow_ScrollView_2 = {"container": statusDesktop_mainWindow, "occurrence": 2, "type": "StatusScrollView", "unnamed": 1, "visible": True}
o_StatusSettingsLineButton = {"container": mainWindow_ScrollView_2, "occurrence": 4, "type": "StatusSettingsLineButton", "unnamed": 1, "visible": True}
navBarListView_StatusNavBarTabButton_2 = {"checkable": True, "container": mainWindow_navBarListView_ListView, "occurrence": 2, "type": "StatusNavBarTabButton", "unnamed": 1, "visible": True}
statusIcon_StatusIcon_4 = {"container": navBarListView_StatusNavBarTabButton_2, "id": "statusIcon", "source": "qrc:/StatusQ/src/assets/img/icons/settings.svg", "type": "StatusIcon", "unnamed": 1, "visible": True}
o_Flickable = {"container": mainWindow_ScrollView, "type": "Flickable", "unnamed": 1, "visible": True}
settingsMenuDelegate_StatusNavigationListItem_2 = {"container": mainWindow_ScrollView, "id": "settingsMenuDelegate", "occurrence": 5, "type": "StatusNavigationListItem", "unnamed": 1, "visible": True}
appsMenuDelegate_StatusNavigationListItem = {"container": mainWindow_ScrollView, "id": "appsMenuDelegate", "occurrence": 2, "type": "StatusNavigationListItem", "unnamed": 1, "visible": True}
twelve_seed_phrase_address = {"container": mainWindow_ScrollView_2, "text": "0x8285cb9bf17b23d64a489a8dad29163dd227d0fd", "type": "StatusBaseText", "unnamed": 1, "visible": True}
o_Flickable_2 = {"container": mainWindow_ScrollView_2, "type": "Flickable", "unnamed": 1, "visible": True}
appsMenuDelegate_StatusNavigationListItem_2 = {"container": mainWindow_ScrollView, "id": "appsMenuDelegate", "occurrence": 3, "type": "StatusNavigationListItem", "unnamed": 1, "visible": True}
settingsMenuDelegate_StatusNavigationListItem_3 = {"container": mainWindow_ScrollView, "id": "settingsMenuDelegate", "occurrence": 2, "type": "StatusNavigationListItem", "unnamed": 1, "visible": True}
settingsMenuDelegate_StatusNavigationListItem_4 = {"container": mainWindow_ScrollView, "id": "settingsMenuDelegate", "type": "StatusNavigationListItem", "unnamed": 1, "visible": True}
settingsMenuDelegate_StatusNavigationListItem_5 = {"container": mainWindow_ScrollView, "id": "settingsMenuDelegate", "occurrence": 6, "type": "StatusNavigationListItem", "unnamed": 1, "visible": True}
follow_your_interests_in_one_of_the_many_Public_Chats_StatusBaseText = {"container": mainWindow_ScrollView, "text": "Follow your interests in one of the many Public Chats.", "type": "StatusBaseText", "unnamed": 1, "visible": True}
notifications_Sounds_StatusBaseText = {"container": mainWindow_ScrollView, "text": "Notifications & Sounds", "type": "StatusBaseText", "unnamed": 1, "visible": True}
wallet_StatusBaseText = {"container": mainWindow_ScrollView, "text": "Wallet", "type": "StatusBaseText", "unnamed": 1, "visible": True}
switchItem_StatusSwitch = {"checkable": True, "container": mainWindow_ScrollView_2, "id": "switchItem", "occurrence": 2, "type": "StatusSwitch", "unnamed": 1, "visible": True}
settingsMenuDelegate_StatusNavigationListItem_6 = {"container": mainWindow_ScrollView, "id": "settingsMenuDelegate", "occurrence": 3, "type": "StatusNavigationListItem", "unnamed": 1, "visible": True}
circle_Rectangle = {"container": mainWindow_ScrollView_2, "id": "circle", "occurrence": 2, "type": "Rectangle", "unnamed": 1, "visible": True}
o_WalletAccountDelegate = {"container": mainWindow_ScrollView_2, "type": "WalletAccountDelegate", "unnamed": 1, "visible": True}
statusIcon_StatusIcon_5 = {"container": mainWindow_ScrollView_2, "id": "statusIcon", "source": "qrc:/StatusQ/src/assets/img/icons/filled-account.svg", "type": "StatusIcon", "unnamed": 1, "visible": True}
mainWindow_Wallet_StatusBaseText = {"container": statusDesktop_mainWindow, "occurrence": 2, "text": "Wallet", "type": "StatusBaseText", "unnamed": 1, "visible": True}
o_StatusListItem = {"container": mainWindow_ScrollView_2, "occurrence": 2, "type": "StatusListItem", "unnamed": 1, "visible": True}
mainWindow_Testnet_Mode_StatusSwitch = {"checkable": True, "container": statusDesktop_mainWindow, "text": "Testnet Mode", "type": "StatusSwitch", "unnamed": 1, "visible": True}
o_crypto_StyledText = {"container": mainWindow_ScrollView, "text": "#crypto", "type": "StyledText", "unnamed": 1, "visible": True}
emptyViewAndSuggestions_EmptyViewPanel = {"container": mainWindow_ScrollView, "id": "emptyViewAndSuggestions", "type": "EmptyViewPanel", "unnamed": 1, "visible": True}
o_vr_ar_StyledText = {"container": mainWindow_ScrollView, "text": "#vr-ar", "type": "StyledText", "unnamed": 1, "visible": True}
o_SuggestedChannel = {"container": mainWindow_ScrollView, "occurrence": 64, "type": "SuggestedChannel", "unnamed": 1, "visible": True}
o_status_assemble_StyledText = {"container": mainWindow_ScrollView, "text": "#status-assemble", "type": "StyledText", "unnamed": 1, "visible": True}
mainWindow_statusIcon_StatusIcon_5 = {"container": statusDesktop_mainWindow, "id": "statusIcon", "source": "qrc:/StatusQ/src/assets/img/icons/chevron-down.svg", "type": "StatusIcon", "unnamed": 1, "visible": True}
o_AccountMenuItemPanel = {"checkable": False, "container": statusDesktop_mainWindow_overlay, "enabled": True, "occurrence": 2, "type": "AccountMenuItemPanel", "unnamed": 1, "visible": True}
mainWindow_walkieTalkieImage_Image = {"container": statusDesktop_mainWindow, "id": "walkieTalkieImage", "source": "qrc:/imports/assets/png/chat/chat@2x.png", "type": "Image", "unnamed": 1, "visible": True}
eighteen_seed_phrase_address = {"container": mainWindow_ScrollView_2, "text": "0xba1d0d6ef35df8751df5faf55ebd885ad0e877b0", "type": "StatusBaseText", "unnamed": 1, "visible": True}
typeRectangle_Rectangle = {"container": mainWindow_ScrollView_2, "id": "typeRectangle", "type": "Rectangle", "unnamed": 1, "visible": True}
mainWindow_StatusFlatButton = {"container": statusDesktop_mainWindow, "type": "StatusFlatButton", "unnamed": 1, "visible": True}
walletAccount_WalletAccountDelegate = {"container": mainWindow_ScrollView_2, "objectName": "walletAccount", "type": "WalletAccountDelegate", "visible": True}
twenty_four_seed_phrase_address = {"container": mainWindow_ScrollView_2, "text": "0x28cf6770664821a51984daf5b9fb1b52e6538e4b", "type": "StatusBaseText", "unnamed": 1, "visible": True}
advanced_listItem_StatusNavigationListItem = {"container": mainWindow_ScrollView, "objectName": "Advanced-listItem", "type": "StatusNavigationListItem", "visible": True}
communities_AppMenu_StatusNavigationListItem = {"container": mainWindow_ScrollView, "objectName": "Communities-AppMenu", "type": "StatusNavigationListItem", "visible": True}
wallet_AppMenu_StatusNavigationListItem = {"container": mainWindow_ScrollView, "objectName": "Wallet-AppMenu", "type": "StatusNavigationListItem", "visible": True}
mainWindow_public_chat_icon_StatusIcon = {"container": statusDesktop_mainWindow, "objectName": "public-chat-icon", "source": "qrc:/StatusQ/src/assets/img/icons/public-chat.svg", "type": "StatusIcon", "visible": True}
mainWindow_Rectangle_5 = {"container": statusDesktop_mainWindow, "occurrence": 3, "type": "Rectangle", "unnamed": 1, "visible": True}
mainWindow_Welcome_to_Status_StyledText = {"container": statusDesktop_mainWindow, "text": "Welcome to Status", "type": "StyledText", "unnamed": 1, "visible": True}
mainWindow_Your_fully_decentralized_gateway_to_Ethereum_and_Web3_Crypto_wallet_privacy_first_group_chat_and_dApp_browser_StyledText = {"container": statusDesktop_mainWindow, "text": "Your fully decentralized gateway to Ethereum and Web3. Crypto wallet, privacy first group chat, and dApp browser.", "type": "StyledText", "unnamed": 1, "visible": True}
mainWindow_I_already_use_Status_StatusBaseText = {"container": statusDesktop_mainWindow, "text": "I already use Status", "type": "StatusBaseText", "unnamed": 1, "visible": True}
mainWindow_Enter_a_seed_phrase_StatusBaseText = {"container": statusDesktop_mainWindow, "text": "Enter a seed phrase", "type": "StatusBaseText", "unnamed": 1, "visible": True}
get_started_StatusBaseText = {"container": statusDesktop_mainWindow_overlay, "text": "Get started", "type": "StatusBaseText", "unnamed": 1, "visible": True}
mainWindow_submitBtn_StatusButton = {"container": statusDesktop_mainWindow, "id": "submitBtn", "type": "StatusButton", "unnamed": 1, "visible": True}
appearance_SettingsMenu_StatusNavigationListItem = {"container": mainWindow_ScrollView, "objectName": "Appearance-SettingsMenu", "type": "StatusNavigationListItem", "visible": True}
advanced_SettingsMenu_StatusNavigationListItem = {"container": mainWindow_ScrollView, "objectName": "Advanced-SettingsMenu", "type": "StatusNavigationListItem", "visible": True}
walletSettingsLineButton = {"container": statusDesktop_mainWindow, "objectName": "WalletSettingsLineButton", "type": "StatusSettingsLineButton", "visible": True}
navBarListView_Settings_navbar_StatusNavBarTabButton = {"checkable": True, "container": mainWindow_navBarListView_ListView, "objectName": "Settings-navbar", "type": "StatusNavBarTabButton", "visible": True}
settings_navbar_settings_icon_StatusIcon = {"container": navBarListView_Settings_navbar_StatusNavBarTabButton, "objectName": "settings-icon", "type": "StatusIcon", "visible": True}
navBarListView_Communities_Portal_navbar_StatusNavBarTabButton = {"checkable": True, "container": mainWindow_navBarListView_ListView, "objectName": "Communities Portal-navbar", "type": "StatusNavBarTabButton", "visible": True}
communities_Portal_navbar_communities_icon_StatusIcon = {"container": navBarListView_Communities_Portal_navbar_StatusNavBarTabButton, "objectName": "communities-icon", "type": "StatusIcon", "visible": True}
mainWindow_communitiesPortalLayoutContainer_CommunitiesPortalLayout = {"container": statusDesktop_mainWindow, "objectName": "communitiesPortalLayout", "type": "CommunitiesPortalLayout"}
communitiesPortalLayoutContainer_createCommunityButton_StatusButton = {"container": mainWindow_communitiesPortalLayoutContainer_CommunitiesPortalLayout, "objectName": "createCommunityButton", "type": "StatusButton", "visible": True}
createCommunityNameInput_TextEdit = {"container": statusDesktop_mainWindow_overlay, "objectName": "createCommunityNameInput", "type": "TextEdit", "visible": True}
createCommunityDescriptionInput_TextEdit = {"container": statusDesktop_mainWindow_overlay, "objectName": "createCommunityDescriptionInput", "type": "TextEdit", "visible": True}
createCommunityIntroMessageInput_TextEdit = {"container": statusDesktop_mainWindow_overlay, "objectName": "createCommunityIntroMessageInput", "type": "TextEdit", "visible": True}
createCommunityOutroMessageInput_TextEdit = {"container": statusDesktop_mainWindow_overlay, "objectName": "createCommunityOutroMessageInput", "type": "TextEdit", "visible": True}
createCommunityNextBtn_StatusButton = {"container": statusDesktop_mainWindow_overlay, "objectName": "createCommunityNextBtn", "type": "StatusButton", "visible": True}
createCommunityFinalBtn_StatusButton = {"container": statusDesktop_mainWindow_overlay, "objectName": "createCommunityFinalBtn", "type": "StatusButton", "visible": True}
mainWindow_createChannelOrCategoryBtn_StatusBaseText = {"container": statusDesktop_mainWindow, "objectName": "createChannelOrCategoryBtn", "type": "StatusBaseText", "visible": True}
create_channel_StatusMenuItemDelegate = {"checkable": False, "container": statusDesktop_mainWindow_overlay, "enabled": True, "objectName": "createCommunityChannelBtn", "type": "StatusMenuItemDelegate", "visible": True}
create_category_StatusMenuItemDelegate = {"checkable": False, "container": statusDesktop_mainWindow_overlay, "enabled": True, "objectName": "createCommunityCategoryBtn", "type": "StatusMenuItemDelegate", "visible": True}
createOrEditCommunityChannelNameInput_TextEdit = {"container": statusDesktop_mainWindow_overlay, "objectName": "createOrEditCommunityChannelNameInput", "type": "TextEdit", "visible": True}
createOrEditCommunityChannelDescriptionInput_TextEdit = {"container": statusDesktop_mainWindow_overlay, "objectName": "createOrEditCommunityChannelDescriptionInput", "type": "TextEdit", "visible": True}
createOrEditCommunityChannelBtn_StatusButton = {"container": statusDesktop_mainWindow_overlay, "objectName": "createOrEditCommunityChannelBtn", "type": "StatusButton", "visible": True}
channel_Header_chat_title_StatusBaseText = {"container": statusDesktop_mainWindow, "objectName": "chatInfoNameText", "type": "StatusBaseText", "visible": True}
chat_moreOptions_menuButton = {"container": statusDesktop_mainWindow, "objectName": "chatToolbarMoreOptionsButton", "type": "StatusFlatRoundButton", "visible": True}
edit_Channel_StatusMenuItemDelegate = {"checkable": False, "container": statusDesktop_mainWindow_overlay, "enabled": True, "objectName": "editChannelMenuItem", "type": "StatusMenuItemDelegate", "visible": True}

navBarListView_Wallet_navbar_StatusNavBarTabButton = {"checkable": True, "container": mainWindow_navBarListView_ListView, "objectName": "Wallet-navbar", "type": "StatusNavBarTabButton", "visible": True}
wallet_navbar_wallet_icon_StatusIcon = {"container": navBarListView_Wallet_navbar_StatusNavBarTabButton, "objectName": "wallet-icon", "type": "StatusIcon", "visible": True}

mainWallet_Account_Name = {"container": statusDesktop_mainWindow, "objectName": "accountName", "type": "StatusBaseText", "visible": True}
mainWallet_Add_Account = {"container": statusDesktop_mainWindow, "text": "Add account", "type": "StatusBaseText", "unnamed": 1, "visible": True}

mainWallet_Add_Account_Popup_Main = {"container": statusDesktop_mainWindow, "objectName": "AddAccountModalContent", "type": "StatusScrollView", "visible": True}
mainWallet_Add_Account_Popup_Password = {"container": mainWallet_Add_Account_Popup_Main, "text": "Enter your password...", "type": "PlaceholderText", "unnamed": 1, "visible": True}
mainWallet_Add_Account_Popup_Advanced = {"container": mainWallet_Add_Account_Popup_Main, "text": "Advanced", "type": "StatusBaseText", "unnamed": 1, "visible": True}
mainWallet_Add_Account_Popup_Type_Selector = {"container": mainWallet_Add_Account_Popup_Main, "text": "Default", "type": "StatusBaseText", "unnamed": 1, "visible": True}
mainWallet_Add_Account_Popup_Type_Watch_Only = {"container": statusDesktop_mainWindow, "text": "Add a watch-only address", "type": "StatusBaseText", "unnamed": 1, "visible": True}
mainWallet_Add_Account_Popup_Type_Private_Key = {"container": statusDesktop_mainWindow, "text": "Generate from Private key", "type": "StatusBaseText", "unnamed": 1, "visible": True}
mainWallet_Add_Account_Popup_Type_Seed_Phrase = {"container": statusDesktop_mainWindow, "text": "Import new Seed Phrase", "type": "StatusBaseText", "unnamed": 1, "visible": True}
mainWallet_Add_Account_Popup_Account_Name = {"container": mainWallet_Add_Account_Popup_Main, "text": "Enter an account name...", "type": "StatusBaseText", "unnamed": 1, "visible": True}
mainWallet_Add_Account_Popup_Watch_Only_Address = {"container": mainWallet_Add_Account_Popup_Main, "text": "Enter address...", "type": "StatusBaseText", "unnamed": 1, "visible": True}
mainWallet_Add_Account_Popup_Private_Key = {"container": mainWallet_Add_Account_Popup_Main, "text": "Paste the contents of your private key", "type": "StatusBaseText", "unnamed": 1, "visible": True}
mainWindow_Add_Account_Popup_Seed_Phrase_0 = {"container": mainWallet_Add_Account_Popup_Main, "type": "StatusBaseText", "objectName": "seedPhraseInputPlaceholder0", "visible": True}
mainWindow_Add_Account_Popup_Seed_Phrase_1 = {"container": mainWallet_Add_Account_Popup_Main, "type": "StatusBaseText", "objectName": "seedPhraseInputPlaceholder1", "visible": True}
mainWindow_Add_Account_Popup_Seed_Phrase_2 = {"container": mainWallet_Add_Account_Popup_Main, "type": "StatusBaseText", "objectName": "seedPhraseInputPlaceholder2", "visible": True}
mainWindow_Add_Account_Popup_Seed_Phrase_3 = {"container": mainWallet_Add_Account_Popup_Main, "type": "StatusBaseText", "objectName": "seedPhraseInputPlaceholder3", "visible": True}
mainWindow_Add_Account_Popup_Seed_Phrase_4 = {"container": mainWallet_Add_Account_Popup_Main, "type": "StatusBaseText", "objectName": "seedPhraseInputPlaceholder4", "visible": True}
mainWindow_Add_Account_Popup_Seed_Phrase_5 = {"container": mainWallet_Add_Account_Popup_Main, "type": "StatusBaseText", "objectName": "seedPhraseInputPlaceholder5", "visible": True}
mainWindow_Add_Account_Popup_Seed_Phrase_6 = {"container": mainWallet_Add_Account_Popup_Main, "type": "StatusBaseText", "objectName": "seedPhraseInputPlaceholder6", "visible": True}
mainWindow_Add_Account_Popup_Seed_Phrase_7 = {"container": mainWallet_Add_Account_Popup_Main, "type": "StatusBaseText", "objectName": "seedPhraseInputPlaceholder7", "visible": True}
mainWindow_Add_Account_Popup_Seed_Phrase_8 = {"container": mainWallet_Add_Account_Popup_Main, "type": "StatusBaseText", "objectName": "seedPhraseInputPlaceholder8", "visible": True}
mainWindow_Add_Account_Popup_Seed_Phrase_9 = {"container": mainWallet_Add_Account_Popup_Main, "type": "StatusBaseText", "objectName": "seedPhraseInputPlaceholder9", "visible": True}
mainWindow_Add_Account_Popup_Seed_Phrase_10 = {"container": mainWallet_Add_Account_Popup_Main, "type": "StatusBaseText", "objectName": "seedPhraseInputPlaceholder10", "visible": True}
mainWindow_Add_Account_Popup_Seed_Phrase_11 = {"container": mainWallet_Add_Account_Popup_Main, "type": "StatusBaseText", "objectName": "seedPhraseInputPlaceholder11", "visible": True}

mainWallet_Add_Account_Popup_Footer = {"container": statusDesktop_mainWindow, "type": "StatusModalFooter", "unnamed": 1, "visible": True}
mainWallet_Add_Account_Popup_Footer_Add_Account = {"container": mainWallet_Add_Account_Popup_Footer, "text": "Add account", "type": "StatusBaseText", "unnamed": 1, "visible": True}

settings_Wallet_MainView_GeneratedAccounts = {"container": statusDesktop_mainWindow, "objectName":'generatedAccounts', "type": 'ListView'}
settings_Wallet_AccountView_DeleteAccount = {"container": statusDesktop_mainWindow, "type": "StatusButton", "objectName": "deleteAccountButton"}
settings_Wallet_AccountView_DeleteAccount_Confirm = {"container": statusDesktop_mainWindow, "type": "StatusButton", "objectName": "confirmDeleteAccountButton"}
mainWindow_communityColumnView_CommunityColumnView = {"container": statusDesktop_mainWindow, "objectName": "communityColumnView", "type": "CommunityColumnView"}
settings_navbar_settings_icon_StatusIcon = {"container": navBarListView_Settings_navbar_StatusNavBarTabButton, "objectName": "settings-icon", "source": "qrc:/StatusQ/src/assets/img/icons/settings.svg", "type": "StatusIcon", "visible": True}

# Onboarding region:
onboarding_newPsw_Input = {"container": statusDesktop_mainWindow, "text": "New password", "type": "PlaceholderText"}
onboarding_confirmPsw_Input = {"container": statusDesktop_mainWindow, "text": "Confirm password", "type": "PlaceholderText"}
onboarding_create_password_button = {"container": statusDesktop_mainWindow, "objectName": "createPswBtn", "type": "StatusButton"}
onboarding_confirmPswAgain_Input = {"container": statusDesktop_mainWindow, "text": "Confirm your password (again)", "type": "PlaceholderText"}
onboarding_finalise_password_button = {"container": statusDesktop_mainWindow, "objectName": "confirmPswSubmitBtn", "type": "StatusButton"}

# Loading region:
loginView_passwordInput = {"container": statusDesktop_mainWindow, "objectName": "loginPasswordInput", "type": "StyledTextField"}
loginView_changeAccountBtn = {"container": statusDesktop_mainWindow, "objectName": "changeAccountBtn", "type": "Rectangle"}
loginView_submitBtn = {"container": statusDesktop_mainWindow, "type": "StatusRoundButton", "visible": True}
loginView_main = {"container": statusDesktop_mainWindow, "type": "LoginView", "visible": True}
loginView_errMsgLabel = {"container": statusDesktop_mainWindow, "id": "errMsg", "type": "StyledText", "visible": True}
accountsView_accountListPanel = {"container": statusDesktop_mainWindow, "type": "ListView", "visible": True}

# Main Window - chat related:
chatList_Repeater = {"container": statusDesktop_mainWindow, "objectName": "chatListItems", "type": "Repeater"}

# Join chat popup:
startChat_Btn = {"container": statusDesktop_mainWindow_overlay, "objectName": "startChatButton", "type": "StatusButton"}

# Create chat view region:
createChatView_contactsList = {"container": statusDesktop_mainWindow, "objectName": "tagSelectorUserList", "type": "ListView"}
createChatView_confirmBtn = {"container": statusDesktop_mainWindow, "objectName": "createChatConfirmButton", "type": "StatusButton"}

# Chat view region:
chatView_log = {"container": statusDesktop_mainWindow, "objectName": "chatLogView", "type": "StatusListView", "visible": True}
chatView_StatusChatInfoButton = {"container": statusDesktop_mainWindow, "objectName": "chatInfoBtnInHeader", "type": "StatusChatInfoButton"}
chatView_messageInput = {"container": mainWindow_scrollView_ScrollView, "objectName": "messageInputField", "type": "TextArea", "visible": True}

# Community chat region
mainWindow_communityHeader_StatusChatInfoButton = {"container": statusDesktop_mainWindow, "objectName": "communityHeaderButton", "type": "StatusChatInfoButton", "visible": True}
community_ChatInfo_Name_Text = {"container": mainWindow_communityHeader_StatusChatInfoButton, "objectName": "statusChatInfoButtonNameText", "type": "StatusBaseText", "visible": True}


chatView_chatLogView_lastMsg_MessageView = {"container": chatView_log, "index": 0, "type": "MessageView"}
chatView_lastChatText_Text = {"container": chatView_chatLogView_lastMsg_MessageView, "objectName": "chatText", "type": "StyledTextEdit"}
chatMessageListView_msgDelegate_MessageView = {"container": chatView_log, "objectName": "chatMessageViewDelegate", "index": 1, "type": "MessageView", "visible": True}
msgDelegate_channelIdentifierNameText_StyledText = {"container": chatMessageListView_msgDelegate_MessageView, "objectName": "channelIdentifierNameText", "type": "StyledText", "visible": True}

# Members panel:
chatView_chatMembers_ListView = {"container": statusDesktop_mainWindow, "objectName": "userListPanel", "type": "ListView"}
