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
    property string chatId

    readonly property alias chatMessagesLoader: chatMessagesLoader

    property var emojiPopup
    property var stickersPopup
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

    QtObject {
        id: d

        property bool isUserAdded

        function updateIsUserAdded() {
            isUserAdded = Qt.binding(() => {isActiveChannel; return Utils.getContactDetailsAsJson(root.chatId, false).isAdded})
        }

        Component.onCompleted: updateIsUserAdded()
    }

    onIsActiveChannelChanged: {
        if (isActiveChannel) {
            chatInput.forceInputActiveFocus();
        }
    }

    Connections {
        target: root.contactsStore.myContactsModel

        function onItemChanged(pubKey) {
            if (pubKey === root.chatId) {
                d.updateIsUserAdded()
            }
        }
    }

    Loader {
        Layout.fillWidth: true
        active: root.isBlocked
        visible: active
        sourceComponent: StatusBanner {
            type: StatusBanner.Type.Danger
            statusText: qsTr("Blocked")
        }
    }

    readonly property var messageStore: MessageStore {
        messageModule: chatContentModule ? chatContentModule.messagesModule : null
        chatSectionModule: root.rootStore.chatCommunitySectionModule
    }

    MessageContextMenuView {
        id: contextmenu
        store: root.rootStore
        reactionModel: root.rootStore.emojiReactionsModel
        disabledForChat: chatType === Constants.chatType.oneToOne && !d.isUserAdded

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
            Global.openPinnedMessagesPopupRequested(rootStore, messageStore, chatContentModule.pinnedMessagesModel, messageId, root.chatId)
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

        Loader {
            id: chatMessagesLoader
            Layout.fillWidth: true
            Layout.fillHeight: true

            sourceComponent: ChatMessagesView {
                chatContentModule: root.chatContentModule
                rootStore: root.rootStore
                contactsStore: root.contactsStore
                messageContextMenu: contextmenu
                messageStore: root.messageStore
                emojiPopup: root.emojiPopup
                stickersPopup: root.stickersPopup
                usersStore: root.usersStore
                stickersLoaded: root.stickersLoaded
                isChatBlocked: root.isBlocked || (chatContentModule && chatContentModule.chatDetails.type === Constants.chatType.oneToOne && !d.isUserAdded)
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
                onEditModeChanged: if (!editModeOn) chatInput.forceInputActiveFocus()
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

                enabled: root.rootStore.sectionDetails.joined && !root.rootStore.sectionDetails.amIBanned &&
                         !(chatType === Constants.chatType.oneToOne && !d.isUserAdded)

                store: root.rootStore
                usersStore: root.usersStore

                messageContextMenu: contextmenu
                emojiPopup: root.emojiPopup
                stickersPopup: root.stickersPopup
                isContactBlocked: root.isBlocked
                isActiveChannel: root.isActiveChannel
                anchors.bottom: parent.bottom
                chatType: chatContentModule ? chatContentModule.chatDetails.type : Constants.chatType.unknown
                suggestions.suggestionFilter.addSystemSuggestions: chatType == Constants.chatType.communityChat

                Binding on chatInputPlaceholder {
                    when: root.isBlocked
                    value: qsTr("This user has been blocked.")
                }

                Binding on chatInputPlaceholder {
                    when: !root.rootStore.sectionDetails.joined || root.rootStore.sectionDetails.amIBanned
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

                    if(root.rootStore.sendMessage(chatContentModule.getMyChatId(),
                                                  event,
                                                  chatInput.getTextWithPublicKeys(),
                                                  chatInput.isReply? chatInput.replyMessageId : "",
                                                  chatInput.fileUrlsAndSources
                                                  ))
                    {
                        Global.playSendMessageSound()

                        chatInput.textInput.clear();
                        chatInput.textInput.textFormat = TextEdit.PlainText;
                        chatInput.textInput.textFormat = TextEdit.RichText;
                    }
                }

                onUnblockChat: {
                    chatContentModule.unblockChat()
                }
                onKeyUpPress: messageStore.setEditModeOnLastMessage(root.rootStore.userProfileInst.pubKey)
            }
        }
    }
}
