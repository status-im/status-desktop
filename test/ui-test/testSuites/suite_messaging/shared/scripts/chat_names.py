from scripts.global_names import *

# Chat view:
mainWindow_scrollView_ScrollView = {"container": statusDesktop_mainWindow, "id": "scrollView", "type": "StatusScrollView", "unnamed": 1, "visible": True}
mark_as_Read_StatusMenuItem = {"container": statusDesktop_mainWindow_overlay, "objectName": "chatMarkAsReadMenuItem", "type": "StatusMenuItem", "visible": True}
chat_Input_Stickers_Button = {"container": statusDesktop_mainWindow, "objectName": "statusChatInputStickersButton", "type": "StatusFlatRoundButton", "visible": True}
emojiPopup_Emoji_Button_Placeholder = {"container": statusDesktop_mainWindow, "objectName": "statusEmoji_%NAME%", "type": "StatusEmoji", "visible": True}
chatInput_Emoji_Button = {"container": statusDesktop_mainWindow, "objectName": "statusChatInputEmojiButton", "type": "StatusFlatRoundButton", "visible": True}
chatView_unfurledLinkComponent_linkImage = {"container": chatView_log, "objectName": "LinksMessageView_unfurledLinkComponent_linkImage", "type": "StatusChatImageLoader", "visible": True}
chatView_LinksMessageView_enableBtn = {"container": chatView_log, "objectName": "LinksMessageView_enableBtn", "type": "StatusFlatButton", "visible": True}

# More options menu
editNameAndImageMenuItem = {"container": statusDesktop_mainWindow_overlay, "objectName": "editNameAndImageMenuItem", "type": "StatusMenuItem", "visible": True}
leaveChatMenuItem = {"container": statusDesktop_mainWindow_overlay, "enabled": True, "objectName": "deleteOrLeaveMenuItem", "type": "StatusMenuItem", "visible": True}

# group chat edit popup
groupChatEdit_main = {"container": statusDesktop_mainWindow_overlay, "objectName": "groupChatEdit_main", "type": "StatusDialog", "visible": True}
groupChatEdit_name = {"container": statusDesktop_mainWindow_overlay, "objectName": "groupChatEdit_name", "type": "TextEdit", "visible": True}
groupChatEdit_save= {"container": statusDesktop_mainWindow_overlay, "objectName": "groupChatEdit_save", "type": "StatusButton", "visible": True}
groupChatEdit_colorRepeater = {"container": statusDesktop_mainWindow, "type": "Repeater", "objectName": "statusColorRepeater", "visible": True}
groupChatEdit_workflowItem= {"container": statusDesktop_mainWindow, "type": "Item", "objectName": "imageCropWorkflow"}
groupChatEdit_cropperAcceptButton = {"container": statusDesktop_mainWindow, "type": "StatusButton", "objectName": "imageCropperAcceptButton"}
groupChatEdit_image = {"container": statusDesktop_mainWindow_overlay, "objectName": "groupChatEdit_image", "type": "EditCroppedImagePanel"}

# Join chat popup:
chat_name_PlaceholderText = {"container": statusDesktop_mainWindow_overlay, "text": "chat-name", "type": "PlaceholderText", "unnamed": 1, "visible": True}

# Create chat view:
createChatView_contactsList = {"container": statusDesktop_mainWindow, "objectName": "createChatContactsList", "type": "StatusListView"}
createChatView_confirmBtn = {"container": statusDesktop_mainWindow, "objectName": "inlineSelectorConfirmButton", "type": "StatusButton"}

# Members panel:
chatView_chatMembers_ListView = {"container": statusDesktop_mainWindow, "objectName": "userListPanel", "type": "ListView"}

# Stickers Popup
chat_StickersPopup_GetStickers_Button = {"container": statusDesktop_mainWindow_overlay, "objectName": "stickersPopupGetStickersButton", "type": "StatusButton", "visible": True}
chat_StickersPopup_Retry_Button = {"container": statusDesktop_mainWindow_overlay, "objectName": "stickersPopupRetryButton", "type": "StatusButton", "visible": True}
chat_StickersPopup_StickerMarket_GridView = {"container": statusDesktop_mainWindow_overlay, "objectName": "stickerMarketStatusGridView", "type": "StatusGridView", "visible": True}
chat_StickersPopup_StickerMarket_DelegateItem_1 = {"container": chat_StickersPopup_StickerMarket_GridView, "objectName": "stickerMarketDelegateItem1", "type": "Item", "visible": True}
chat_StickersPopup_StickerMarket_Install_Button = {"container": statusDesktop_mainWindow_overlay, "objectName": "statusStickerMarketInstallButton", "type": "StatusStickerButton", "visible": True}
chat_StickersPopup_StickerList_Grid = {"container": statusDesktop_mainWindow_overlay, "objectName": "statusStickerPopupStickerGrid", "type": "StatusStickerList", "visible": True}
