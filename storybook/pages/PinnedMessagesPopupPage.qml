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
        id: d_msg

        readonly property var messagesModel: ListModel {
            ListElement {
                timestamp: 1656937930123
                senderId: "zq123456789"
                senderDisplayName: "simon"
                profileImage: "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAADIAAAAyCAYAAAAeP4ixAAAAlklEQVR4nOzW0QmDQBAG4SSkl7SUQlJGCrElq9F3QdjjVhh/5nv3cFhY9vUIYQiNITSG0BhCExPynn1gWf9bx498P7/
                              nzPcxEzGExhBdJGYihtAYQlO+tUZvqrPbqeudo5iJGEJjCE15a3VtodH3q2ImYgiNITTlTdG1nUZ5a92VITQxITFiJmIIjSE0htAYQrMHAAD//+wwFVpz+yqXAAAAAElFTkSuQmCC"
                contentType: StatusMessage.ContentType.Text
                message: "Hello, this is awesome! Feels like decentralized Discord! And it even supports HTML markup, like <b>bold</b>, <i>italics</i> or <u>underline</u>"
                isContact: true
                isAReply: false
                trustIndicator: StatusContactVerificationIcons.TrustedType.Verified
                outgoingStatus: StatusMessage.OutgoingStatus.Delivered
            }
            ListElement {
                timestamp: 1657937930135
                senderId: "zqABCDEFG"
                senderDisplayName: "Mark Cuban"
                contentType: StatusMessage.ContentType.Text
                message: "I know a lot of you really seem to get off or be validated by arguing with strangers online but please know it's a complete waste of your time and energy"
                isContact: false
                isAReply: false
                trustIndicator: StatusContactVerificationIcons.TrustedType.Untrustworthy
                outgoingStatus: StatusMessage.OutgoingStatus.Delivered
            }
            ListElement {
                timestamp: 1667937930159
                senderId: "zqdeadbeef"
                senderDisplayName: "replicator.stateofus.eth"
                contentType: StatusMessage.ContentType.Text
                message: "Test reply; the original text above should have a horizontal gradient mask"
                isContact: true
                isAReply: true
                trustIndicator: StatusContactVerificationIcons.TrustedType.None
                outgoingStatus: StatusMessage.OutgoingStatus.Delivered
            }
        }
        readonly property var colorHash: ListModel {
            ListElement { colorId: 13; segmentLength: 5 }
            ListElement { colorId: 31; segmentLength: 5 }
            ListElement { colorId: 10; segmentLength: 1 }
        }
    }

    QtObject {
        id: mockMessageStore
        // redo it, use first message as pinned message from d_msg.messagesModel the one whose timestamp is 1656937930123
        property ListModel pinnedMessagesModel: ListModel {
        }

        function getMessageByIndexAsJson(index) {
            if (index >= 0 && index < pinnedMessagesModel.count) {
                return JSON.stringify(pinnedMessagesModel.get(index))
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
                    text: "Open Empty Pinned Messages Popup"
                    onClicked: {
                        mockMessageStore.pinnedMessagesModel.clear()
                        pinnedMessagesPopup.messageToPin = ""
                        pinnedMessagesPopup.open()
                    }
                }

                Button {
                    text: "Open Pinned Messages Popup (2 messages)"
                    onClicked: {
                        mockMessageStore.pinnedMessagesModel.clear()
                        mockMessageStore.pinnedMessagesModel.append(d_msg.messagesModel.get(0))
                        mockMessageStore.pinnedMessagesModel.append(d_msg.messagesModel.get(1))
                        pinnedMessagesPopup.messageToPin = ""
                        pinnedMessagesPopup.open()
                    }
                }

                Button {
                    text: "Open Full Pinned Messages Popup (3 messages)"
                    onClicked: {
                        mockMessageStore.pinnedMessagesModel.clear()
                        mockMessageStore.pinnedMessagesModel.append(d_msg.messagesModel.get(0))
                        mockMessageStore.pinnedMessagesModel.append(d_msg.messagesModel.get(1))
                        mockMessageStore.pinnedMessagesModel.append(d_msg.messagesModel.get(2))
                        pinnedMessagesPopup.messageToPin = ""
                        pinnedMessagesPopup.open()
                    }
                }

                Button {
                    text: "Open Unpin Messages Popup (3 messages + messageToPin)"
                    onClicked: {
                        mockMessageStore.pinnedMessagesModel.clear()
                        mockMessageStore.pinnedMessagesModel.append(d_msg.messagesModel.get(0))
                        mockMessageStore.pinnedMessagesModel.append(d_msg.messagesModel.get(1))
                        mockMessageStore.pinnedMessagesModel.append(d_msg.messagesModel.get(2))
                        pinnedMessagesPopup.messageToPin = "This is a message to pin"
                        pinnedMessagesPopup.open()
                    }
                }
            }

            PinnedMessagesPopup {
                id: pinnedMessagesPopup
                store: mockRootStore
                messageStore: d_msg
                pinnedMessagesModel: mockMessageStore.pinnedMessagesModel
                chatId: "chat1"

                property var chatContentModule: QtObject {
                    property var chatDetails: QtObject {
                        property bool canPostReactions: true
                        property bool canPost: true
                        property bool canView: true
                    }
                    property var pinnedMessagesModel: mockMessageStore.pinnedMessagesModel
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
        }
    }
}

// category: Views