import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.14

import StatusQ.Core 0.1
import StatusQ.Components 0.1
import StatusQ.Core.Theme 0.1

import Storybook 1.0
import Models 1.0

SplitView {
    id: root

    Logs { id: logs }

    QtObject {
        id: d

        readonly property var exampleAlbum: [ModelsData.banners.coinbase, ModelsData.icons.status]

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
            ListElement {
                timestamp: 1667937930489
                senderId: "zqdeadbeef"
                senderDisplayName: "replicator.stateofus.eth"
                contentType: StatusMessage.ContentType.Text
                message: "Test message with a link https://github.com/. Try to copy the link!"
                isContact: true
                isAReply: true
                trustIndicator: StatusContactVerificationIcons.TrustedType.None
                outgoingStatus: StatusMessage.OutgoingStatus.Delivered
            }
            ListElement {
                timestamp: 1667937930159
                senderId: "zqdeadbeef86"
                senderDisplayName: "8⃣6⃣.stateofus.eth"
                contentType: StatusMessage.ContentType.Text
                message: "Test message for a user with emoji + ENS name"
                isContact: false
                isAReply: false
                trustIndicator: StatusContactVerificationIcons.TrustedType.None
                outgoingStatus: StatusMessage.OutgoingStatus.Delivered
            }
            ListElement {
                timestamp: 1719769718000
                senderId: "zq123456790"
                senderDisplayName: "Alice"
                contentType: StatusMessage.ContentType.Text
                message: "Sending message"
                isAReply: false
                isContact: true
                amISender: true
                trustIndicator: StatusContactVerificationIcons.TrustedType.None
                outgoingStatus: StatusMessage.OutgoingStatus.Sending
            }
            ListElement {
                timestamp: 1719769718000
                senderId: "zq123456790"
                senderDisplayName: "Alice"
                contentType: StatusMessage.ContentType.Text
                message: "Sent message"
                isAReply: false
                isContact: true
                amISender: true
                trustIndicator: StatusContactVerificationIcons.TrustedType.None
                outgoingStatus: StatusMessage.OutgoingStatus.Sent
                resendError: ""
            }
            ListElement {
                timestamp: 1719769718000
                senderId: "zq123456790"
                senderDisplayName: "Alice"
                contentType: StatusMessage.ContentType.Text
                message: "Delivered message"
                isAReply: false
                isContact: true
                amISender: true
                trustIndicator: StatusContactVerificationIcons.TrustedType.None
                outgoingStatus: StatusMessage.OutgoingStatus.Delivered
                resendError: ""
            }
            ListElement {
                timestamp: 1719769718000
                senderId: "zq123456790"
                senderDisplayName: "Alice"
                contentType: StatusMessage.ContentType.Text
                message: "Expired message"
                isAReply: false
                isContact: true
                amISender: true
                trustIndicator: StatusContactVerificationIcons.TrustedType.None
                outgoingStatus: StatusMessage.OutgoingStatus.Expired
                resendError: ""
            }
            ListElement {
                timestamp: 1719769718000
                senderId: "zq123456790"
                senderDisplayName: "Alice"
                contentType: StatusMessage.ContentType.Text
                message: "Message with resend error"
                isAReply: false
                isContact: true
                amISender: true
                trustIndicator: StatusContactVerificationIcons.TrustedType.None
                outgoingStatus: StatusMessage.OutgoingStatus.Expired
                resendError: "can't send message on Tuesday"
            }
            ListElement {
                timestamp: 1667937930159
                senderId: "zqdeadbeef"
                senderDisplayName: "replicator.stateofus.eth"
                contentType: StatusMessage.ContentType.Text
                message: "Test message with a link https://github.com/. Hey annyah! 0x16437e05858c1a34f0ae63c9ca960d61a5583d5e
                          this is my wallet address eth:opt:arb:0x16437e05858c1a34f0ae63c9ca960d61a5583d5e,
                          0x75d5673fc25bb4993ea1218d9d415487c3656853"
                isContact: true
                isAReply: true
                trustIndicator: StatusContactVerificationIcons.TrustedType.None
                outgoingStatus: StatusMessage.OutgoingStatus.Delivered
            }
            ListElement {
                timestamp: 1667937930159
                senderId: "zqdeadbeef"
                senderDisplayName: "replicator.stateofus.eth"
                contentType: StatusMessage.ContentType.Text
                message: "Ola!! qwerty.stateofus.eth hey this is my ens name"
                isContact: true
                isAReply: false
                trustIndicator: StatusContactVerificationIcons.TrustedType.None
                outgoingStatus: StatusMessage.OutgoingStatus.Delivered
            }
            ListElement {
                timestamp: 1667937830123
                senderId: "zq123456790"
                senderDisplayName: "Alice"
                contentType: StatusMessage.ContentType.Image
                message: "This message contains images"
                isContact: true
                isAReply: false
                trustIndicator: StatusContactVerificationIcons.TrustedType.None
                outgoingStatus: StatusMessage.OutgoingStatus.Delivered
            }
        }
        readonly property var colorHash: ListModel {
            ListElement { colorId: 13; segmentLength: 5 }
            ListElement { colorId: 31; segmentLength: 5 }
            ListElement { colorId: 10; segmentLength: 1 }
            ListElement { colorId: 2; segmentLength: 5 }
            ListElement { colorId: 26; segmentLength: 2 }
            ListElement { colorId: 19; segmentLength: 4 }
            ListElement { colorId: 28; segmentLength: 3 }
        }
    }

    SplitView {
        orientation: Qt.Vertical
        SplitView.fillWidth: true


        Rectangle {
            SplitView.fillWidth: true
            SplitView.fillHeight: true
            color: Theme.palette.statusAppLayout.rightPanelBackgroundColor
            clip: true

            ListView {
                anchors.margins: 16
                anchors.fill: parent
                spacing: 16
                model: d.messagesModel
                delegate: StatusMessage {
                    width: ListView.view.width
                    timestamp: model.timestamp
                    isAReply: model.isAReply
                    outgoingStatus: model.outgoingStatus
                    resendError: model.outgoingStatus === StatusMessage.OutgoingStatus.Expired ? model.resendError : ""
                    linkAddressAndEnsName: true

                    messageDetails {
                        readonly property bool isEnsVerified: model.senderDisplayName.endsWith(".eth")
                        messageText: model.message
                        contentType: model.contentType
                        amISender: model.amISender
                        sender.id: isEnsVerified ? "" : model.senderId
                        sender.displayName: model.senderDisplayName
                        sender.isContact: model.isContact
                        sender.trustIndicator: model.trustIndicator
                        sender.isEnsVerified: isEnsVerified
                        sender.profileImage {
                            name: model.profileImage || ""
                            colorId: index
                            colorHash: d.colorHash
                        }
                        album: model.contentType === StatusMessage.ContentType.Image ? d.exampleAlbum : []
                        albumCount: model.contentType === StatusMessage.ContentType.Image ? d.exampleAlbum.length : 0
                    }

                    replyDetails {
                        amISender: true
                        sender.id: "0xdeadbeef"
                        sender.profileImage {
                            width: 20
                            height: 20
                            name: ModelsData.icons.dribble
                            colorHash: d.colorHash
                        }
                        messageText: ModelsData.descriptions.mediumLoremIpsum
                    }

                    onSenderNameClicked: logs.logEvent("StatusMessage::senderNameClicked")
                    onProfilePictureClicked: logs.logEvent("StatusMessage::profilePictureClicked")
                    onReplyProfileClicked: logs.logEvent("StatusMessage::replyProfileClicked")
                    onReplyMessageClicked: logs.logEvent("StatusMessage::replyMessageClicked")
                    onResendClicked: logs.logEvent("StatusMessage::resendClicked")
                    onLinkActivated: logs.logEvent("StatusMessage::linkActivated", ["link"], arguments)
                    onImageClicked: logs.logEvent("StatusMessage::imageClicked")
                }
            }
        }

        LogsAndControlsPanel {
            id: logsAndControlsPanel

            SplitView.minimumHeight: 100
            SplitView.preferredHeight: 200

            logsView.logText: logs.logText
        }
    }
}

// category: Components
// status: good
