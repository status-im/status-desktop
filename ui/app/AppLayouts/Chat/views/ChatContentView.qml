import QtQuick 2.15
import QtQml 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

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
    property int chatType: Constants.chatType.unknown

    readonly property alias chatMessagesLoader: chatMessagesLoader

    property var emojiPopup
    property var stickersPopup
    property UsersStore usersStore: UsersStore {}

    onChatContentModuleChanged: if (!!chatContentModule) {
        root.usersStore.usersModule = root.chatContentModule.usersModule
    }

    signal openAppSearch()
    signal openStickerPackPopup(string stickerPackId)

    property Component sendTransactionNoEnsModal
    property Component receiveTransactionModal
    property Component sendTransactionWithEnsModal

    property bool isBlocked: false
    property bool isUserAllowedToSendMessage: root.rootStore.isUserAllowedToSendMessage
    property string chatInputPlaceholder: root.rootStore.chatInputPlaceHolderText
    property bool stickersLoaded: false

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

    QtObject {
        id: d

        readonly property string blockedText: qsTr("This user has been blocked.")

        function showReplyArea(messageId) {
            let obj = messageStore.getMessageByIdAsJson(messageId)
            if (!obj) {
                return
            }
            if (inputAreaLoader.item) {
                inputAreaLoader.item.chatInput.showReplyArea(messageId, obj.senderDisplayName, obj.messageText, obj.contentType, obj.messageImage, obj.albumMessageImages, obj.albumImagesCount, obj.sticker)
            }
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
                messageStore: root.messageStore
                emojiPopup: root.emojiPopup
                stickersPopup: root.stickersPopup
                usersStore: root.usersStore
                stickersLoaded: root.stickersLoaded
                chatId: root.chatId
                isOneToOne: root.chatType === Constants.chatType.oneToOne
                isContactBlocked: root.isBlocked
                isChatBlocked: root.isBlocked || !root.isUserAllowedToSendMessage
                channelEmoji: !chatContentModule ? "" : (chatContentModule.chatDetails.emoji || "")
                isActiveChannel: root.isActiveChannel
                onShowReplyArea: (messageId, senderId) => {
                    d.showReplyArea(messageId)
                }
                onOpenStickerPackPopup: {
                    root.openStickerPackPopup(stickerPackId);
                }
                onEditModeChanged: {
                    if (!editModeOn && inputAreaLoader.item)
                        inputAreaLoader.item.chatInput.forceInputActiveFocus()
                }
            }
        }

        Loader {
            id: inputAreaLoader

            Layout.alignment: Qt.AlignHCenter | Qt.AlignBottom
            Layout.fillWidth: true

            active: root.isActiveChannel
            asynchronous: true

            property string preservedText
            Binding on preservedText {
                when: inputAreaLoader.item != null
                value: inputAreaLoader.item ? inputAreaLoader.item.chatInput.textInput.text : inputAreaLoader.preservedText
                restoreMode: Binding.RestoreNone
                delayed: true
            }

            // FIXME: `StatusChatInput` is way too heavy
            // see: https://github.com/status-im/status-desktop/pull/10343#issuecomment-1515103756
            sourceComponent: Item {
                id: inputArea
                implicitHeight: chatInput.implicitHeight
                                + chatInput.anchors.topMargin
                                + chatInput.anchors.bottomMargin

                readonly property alias chatInput: chatInput

                StatusChatInput {
                    id: chatInput

                    anchors.fill: parent
                    anchors.margins: Style.current.smallPadding

                    // We enable the component if the contact is blocked, because if we disable it, the `Unban` button
                    // becomes disabled. All the local components inside already disable themselves when blocked
                    enabled: root.isBlocked ||
                            (root.rootStore.sectionDetails.joined && !root.rootStore.sectionDetails.amIBanned &&
                             root.isUserAllowedToSendMessage)

                    store: root.rootStore
                    usersStore: root.usersStore

                    textInput.text: inputAreaLoader.preservedText
                    textInput.placeholderText: root.isBlocked ? d.blockedText : root.chatInputPlaceholder
                    emojiPopup: root.emojiPopup
                    stickersPopup: root.stickersPopup
                    isContactBlocked: root.isBlocked
                    isActiveChannel: root.isActiveChannel
                    anchors.bottom: parent.bottom
                    chatType: root.chatType
                    suggestions.suggestionFilter.addSystemSuggestions: chatType === Constants.chatType.communityChat

                    Binding on chatInputPlaceholder {
                        when: root.isBlocked
                        value: d.blockedText
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

                    Component.onCompleted: {
                        Qt.callLater(() => {
                            forceInputActiveFocus()
                            textInput.cursorPosition = textInput.length
                        })
                    }
                }
            }
        }
    }
}
