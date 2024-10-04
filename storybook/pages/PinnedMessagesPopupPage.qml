import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.14

import StatusQ.Controls 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Components 0.1

import Storybook 1.0
import Models 1.0

import utils 1.0
import shared.views.chat 1.0
import shared.status 1.0
import AppLayouts.Chat.popups 1.0

SplitView {
    QtObject {
        id: d
    }

    Logs { id: logs }

    QtObject {
        id: mockMessageStore
        property var messages: [
            {
                messageId: "msg1",
                senderId: "user1",
                senderDisplayName: "Alice",
                senderOptionalName: "",
                senderIsEnsVerified: false,
                senderIcon: "",
                amISender: false,
                senderIsAdded: false,
                senderTrustStatus: Constants.trustStatus.unknown,
                messageText: "This is a pinned message",
                unparsedText: "This is a pinned message",
                messageImage: "",
                messageTimestamp: 1621234567,
                messageOutgoingStatus: "",
                resendError: "",
                messageContentType: Constants.messageContentType.messageType,
                pinnedMessage: true,
                messagePinnedBy: "user2",
                reactionsModel: [],
                linkPreviewModel: null,
                messageAttachments: "",
                transactionParams: null,
                emojiReactionsModel: null,
                responseToMessageWithId: "",
                quotedMessageText: "",
                quotedMessageFrom: "",
                quotedMessageContentType: Constants.messageContentType.messageType,
                quotedMessageDeleted: false,
                album: [],
                albumCount: 0,
                quotedMessageAlbumMessageImages: [],
                quotedMessageAlbumImagesCount: 0
            },
            {
                messageId: "msg2",
                senderId: "user2",
                senderDisplayName: "Bob",
                senderOptionalName: "",
                senderIsEnsVerified: false,
                senderIcon: "",
                amISender: false,
                senderIsAdded: false,
                senderTrustStatus: Constants.trustStatus.unknown,
                messageText: "Another pinned message",
                unparsedText: "Another pinned message",
                messageImage: "",
                messageTimestamp: 1621234568,
                messageOutgoingStatus: "",
                resendError: "",
                messageContentType: Constants.messageContentType.messageType,
                pinnedMessage: true,
                messagePinnedBy: "user1",
                reactionsModel: [],
                linkPreviewModel: null,
                messageAttachments: "",
                transactionParams: null,
                emojiReactionsModel: null,
                responseToMessageWithId: "",
                quotedMessageText: "",
                quotedMessageFrom: "",
                quotedMessageContentType: Constants.messageContentType.messageType,
                quotedMessageDeleted: false,
                album: [],
                albumCount: 0,
                quotedMessageAlbumMessageImages: [],
                quotedMessageAlbumImagesCount: 0
            }
        ]

        function getMessageByIndexAsJson(index) {
            if (index >= 0 && index < messages.length) {
                return JSON.stringify(messages[index])
            }
            return "{}"
        }

        function unpinMessage(messageId) {
            console.log("Unpinning message:", messageId)
        }

        property bool amIChatAdmin: false
        property int chatType: Constants.chatType.oneToOne

        function setEditModeOff(messageId) {
            console.log("Setting edit mode off for message:", messageId)
        }

        function setEditModeOn(messageId) {
            console.log("Setting edit mode on for message:", messageId)
        }

        function warnAndDeleteMessage(messageId) {
            console.log("Warning and deleting message:", messageId)
        }

        function toggleReaction(messageId, emojiId) {
            console.log("Toggling reaction for message:", messageId, "with emoji:", emojiId)
        }

        function markMessageAsUnread(messageId) {
            console.log("Marking message as unread:", messageId)
        }

        function pinMessage(messageId) {
            console.log("Pinning message:", messageId)
        }
    }

    QtObject {
        id: mockRootStore
        property var messageStore: mockMessageStore
    }

    SplitView {
        orientation: Qt.Vertical
        SplitView.fillWidth: true

        Rectangle {
            SplitView.fillWidth: true
            SplitView.fillHeight: true
            color: Theme.palette.statusAppLayout.rightPanelBackgroundColor
            clip: true

            ColumnLayout {
                anchors.centerIn: parent
                spacing: 10

                Button {
                    text: "Open Pinned Messages Popup"
                    onClicked: {
                        pinnedMessagesPopup.open()
                    }
                }
            }

            PinnedMessagesPopup {
                id: pinnedMessagesPopup
                store: mockRootStore
                messageStore: mockMessageStore
                pinnedMessagesModel: mockMessageStore.messages
                chatId: "chat1"

                property var chatContentModule: QtObject {
                    property var chatDetails: QtObject {
                        property bool canPostReactions: true
                        property bool canPost: true
                        property bool canView: true
                    }
                    property var pinnedMessagesModel: mockMessageStore.messages
                }

                property var usersStore: QtObject {
                    property var usersModel: []
                }

                property var contactsStore: QtObject {
                    function getProfileContext(publicKey, myPublicKey, isBridgedAccount) {
                        return {
                            profileType: Constants.profileType.regular,
                            trustStatus: Constants.trustStatus.unknown,
                            contactType: Constants.contactType.nonContact,
                            ensVerified: false,
                            onlineStatus: Constants.onlineStatus.unknown,
                            hasLocalNickname: false
                        }
                    }
                }

                property var emojiPopup: null
                property var stickersPopup: null

                onPinMessageRequested: (messageId) => {
                    logs.logEvent("Pin message requested:", messageId)
                }
                onUnpinMessageRequested: (messageId) => {
                    logs.logEvent("Unpin message requested:", messageId)
                }
                onJumpToMessageRequested: (messageId) => {
                    logs.logEvent("Jump to message requested:", messageId)
                }
            }
        }
    }

    LogsAndControlsPanel {
        id: logsAndControlsPanel

        SplitView.minimumWidth: 150
        SplitView.preferredWidth: 250

        logsView.logText: logs.logText

        controls: ColumnLayout {
            spacing: 16

            Button {
                text: "Add Pinned Message"
                onClicked: {
                    mockMessageStore.messages.push({
                        messageId: "msg" + (mockMessageStore.messages.length + 1),
                        senderId: "user" + (mockMessageStore.messages.length + 1),
                        senderDisplayName: "User " + (mockMessageStore.messages.length + 1),
                        senderOptionalName: "",
                        senderIsEnsVerified: false,
                        senderIcon: "",
                        amISender: false,
                        senderIsAdded: false,
                        senderTrustStatus: Constants.trustStatus.unknown,
                        messageText: "New pinned message " + (mockMessageStore.messages.length + 1),
                        unparsedText: "New pinned message " + (mockMessageStore.messages.length + 1),
                        messageImage: "",
                        messageTimestamp: Date.now() / 1000,
                        messageOutgoingStatus: "",
                        resendError: "",
                        messageContentType: Constants.messageContentType.messageType,
                        pinnedMessage: true,
                        messagePinnedBy: "user1",
                        reactionsModel: [],
                        linkPreviewModel: null,
                        messageAttachments: "",
                        transactionParams: null,
                        emojiReactionsModel: null,
                        responseToMessageWithId: "",
                        quotedMessageText: "",
                        quotedMessageFrom: "",
                        quotedMessageContentType: Constants.messageContentType.messageType,
                        quotedMessageDeleted: false,
                        album: [],
                        albumCount: 0,
                        quotedMessageAlbumMessageImages: [],
                        quotedMessageAlbumImagesCount: 0
                    })
                    pinnedMessagesPopup.pinnedMessagesModel = mockMessageStore.messages
                }
            }

            Button {
                text: "Clear Pinned Messages"
                onClicked: {
                    mockMessageStore.messages = []
                    pinnedMessagesPopup.pinnedMessagesModel = mockMessageStore.messages
                }
            }

            CheckBox {
                id: isPinActionAvailableCheckBox
                text: "Is Pin Action Available"
                checked: true
                onCheckedChanged: {
                    pinnedMessagesPopup.isPinActionAvailable = checked
                }
            }

            TextField {
                id: messageToPinInput
                placeholderText: "Message to pin"
                onTextChanged: {
                    pinnedMessagesPopup.messageToPin = text
                }
            }
        }
    }
}

// category: Views