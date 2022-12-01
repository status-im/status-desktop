import QtQuick 2.13
import Qt.labs.platform 1.1
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
import QtGraphicalEffects 1.0

import StatusQ.Core.Theme 0.1
import StatusQ.Core.Utils 0.1 as StatusQUtils
import StatusQ.Components 0.1
import StatusQ.Controls 0.1

import utils 1.0
import shared 1.0
import shared.popups 1.0
import shared.status 1.0
import shared.controls 1.0
import shared.views.chat 1.0

import "../helpers"
import "../controls"
import "../popups"
import "../panels"
import "../../Wallet"
import "../stores"

ColumnLayout {
    id: root
    objectName: "chatContentViewColumn"
    spacing: 0

    // Important:
    // Each chat/channel has its own ChatContentModule
    property var chatContentModule
    property var chatSectionModule
    property var rootStore
    property var contactsStore
    property bool isActiveChannel: false
    property var emojiPopup
    property var stickersPopup
    property alias textInputField: chatInput
    property UsersStore usersStore: UsersStore {}

    onChatContentModuleChanged: {
        root.usersStore.usersModule = root.chatContentModule.usersModule
    }

    signal openAppSearch()
    signal openStickerPackPopup(string stickerPackId)

    property Component sendTransactionNoEnsModal
    property Component receiveTransactionModal
    property Component sendTransactionWithEnsModal

    property bool isBlocked: false

    property bool stickersLoaded: false

    // FIXME: this should be section data related only to that view, not the active one
    readonly property var activeSectionData: rootStore.mainModuleInst ? rootStore.mainModuleInst.activeSection || {} : {}

    // NOTE: Used this property change as it is the current way used for displaying new channel/chat data of content view.
    // If in the future content is loaded dynamically, input focus should be activated when loaded / created content view.
    onHeightChanged: {
        if(root.height > 0) {
            chatInput.forceInputActiveFocus()
        }
    }

    StatusBanner {
        Layout.fillWidth: true
        visible: root.isBlocked
        type: StatusBanner.Type.Danger
        statusText: qsTr("Blocked")
    }

    MessageStore {
        id: messageStore
        messageModule: chatContentModule ? chatContentModule.messagesModule : null
        chatSectionModule: root.rootStore.chatCommunitySectionModule
    }

    MessageContextMenuView {
        id: contextmenu
        store: root.rootStore
        reactionModel: root.rootStore.emojiReactionsModel
        onPinMessage: {
            messageStore.pinMessage(messageId)
        }

        onUnpinMessage: {
            messageStore.unpinMessage(messageId)
        }

        onPinnedMessagesLimitReached: {
            if(!chatContentModule) {
                console.warn("error on open pinned messages limit reached from message context menu - chat content module is not set")
                return
            }
            Global.openPopup(Global.pinnedMessagesPopup, {
                                 store: rootStore,
                                 messageStore: messageStore,
                                 pinnedMessagesModel: chatContentModule.pinnedMessagesModel,
                                 messageToPin: messageId
                             })
        }

        onToggleReaction: {
            messageStore.toggleReaction(messageId, emojiId)
        }

        onOpenProfileClicked: {
            Global.openProfilePopup(publicKey, null)
        }

        onDeleteMessage: {
            messageStore.deleteMessage(messageId)
        }

        onEditClicked: messageStore.setEditModeOn(messageId)

        onCreateOneToOneChat: {
            Global.changeAppSectionBySectionType(Constants.appSection.chat)
            root.rootStore.chatCommunitySectionModule.createOneToOneChat("", chatId, ensName)
        }
        onShowReplyArea: {
            let obj = messageStore.getMessageByIdAsJson(messageId)
            if (!obj) {
                return
            }
            chatInput.showReplyArea(messageId, obj.senderDisplayName, obj.messageText, obj.contentType, obj.messageImage, obj.sticker)
        }
    }

    ColumnLayout {
        Layout.fillWidth: true
        Layout.fillHeight: true
        clip: true

        ChatMessagesView {
            id: chatMessages
            Layout.fillWidth: true
            Layout.fillHeight: true
            chatContentModule: root.chatContentModule
            rootStore: root.rootStore
            contactsStore: root.contactsStore
            messageContextMenu: contextmenu
            messageStore: messageStore
            emojiPopup: root.emojiPopup
            stickersPopup: root.stickersPopup
            usersStore: root.usersStore
            stickersLoaded: root.stickersLoaded
            isChatBlocked: root.isBlocked
            channelEmoji: !chatContentModule ? "" : (chatContentModule.chatDetails.emoji || "")
            isActiveChannel: root.isActiveChannel
            onShowReplyArea: {
                let obj = messageStore.getMessageByIdAsJson(messageId)
                if (!obj) {
                    return
                }
                chatInput.showReplyArea(messageId, obj.senderDisplayName, obj.messageText, obj.contentType, obj.messageImage, obj.sticker)
            }
            onOpenStickerPackPopup: {
                root.openStickerPackPopup(stickerPackId);
            }
        }

        Item {
            id: inputArea
            Layout.alignment: Qt.AlignHCenter | Qt.AlignBottom
            Layout.fillWidth: true
            Layout.preferredHeight: chatInput.implicitHeight
                                    + chatInput.anchors.topMargin
                                    + chatInput.anchors.bottomMargin

            StatusChatInput {
                id: chatInput

                anchors.fill: parent
                anchors.margins: Style.current.smallPadding

                enabled: root.activeSectionData.joined

                store: root.rootStore
                usersStore: root.usersStore

                messageContextMenu: contextmenu
                emojiPopup: root.emojiPopup
                stickersPopup: root.stickersPopup
                isContactBlocked: root.isBlocked
                isActiveChannel: root.isActiveChannel
                anchors.bottom: parent.bottom
                chatType: chatContentModule? chatContentModule.chatDetails.type : Constants.chatType.unknown

                Binding on chatInputPlaceholder {
                    when: root.isBlocked
                    value: qsTr("This user has been blocked.")
                }

                Binding on chatInputPlaceholder {
                    when: !root.activeSectionData.joined
                    value: qsTr("You need to join this community to send messages")
                }

                onSendTransactionCommandButtonClicked: {
                    if(!chatContentModule) {
                        console.debug("error on sending transaction command - chat content module is not set")
                        return
                    }

                    if (Utils.isEnsVerified(chatContentModule.getMyChatId())) {
                        Global.openPopup(root.sendTransactionWithEnsModal)
                    } else {
                        Global.openPopup(root.sendTransactionNoEnsModal)
                    }
                }
                onReceiveTransactionCommandButtonClicked: {
                    Global.openPopup(root.receiveTransactionModal)
                }
                onStickerSelected: {
                    root.rootStore.sendSticker(chatContentModule.getMyChatId(),
                                                          hashId,
                                                          chatInput.isReply ? chatInput.replyMessageId : "",
                                                          packId,
                                                          url)
                }


                onSendMessage: {
                    if (!chatContentModule) {
                        console.debug("error on sending message - chat content module is not set")
                        return
                    }

                    if(root.rootStore.sendMessage(event,
                                                  chatInput.getTextWithPublicKeys(),
                                                  chatInput.isReply? chatInput.replyMessageId : "",
                                                  chatInput.fileUrlsAndSources
                                                  ))
                    {
                        Global.sendMessageSound.stop();
                        Qt.callLater(Global.sendMessageSound.play);

                        chatInput.textInput.clear();
                        chatInput.textInput.textFormat = TextEdit.PlainText;
                        chatInput.textInput.textFormat = TextEdit.RichText;
                    }
                }

                onUnblockChat: {
                    chatContentModule.unblockChat()
                }
            }
        }
    }
}
