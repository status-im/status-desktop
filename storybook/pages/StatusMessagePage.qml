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

            ListView {
                anchors.margins: 16
                anchors.fill: parent
                spacing: 16
                model: d.messagesModel
                delegate: StatusMessage {
                    width: ListView.view.width
                    timestamp: model.timestamp
                    messageDetails {
                        readonly property bool isEnsVerified: model.senderDisplayName.endsWith(".eth")
                        messageText: model.message
                        contentType: model.contentType
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
                    }

                    isAReply: model.isAReply
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
