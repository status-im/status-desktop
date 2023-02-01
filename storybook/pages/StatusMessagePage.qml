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

        property var messagesModel: ListModel {
            ListElement {
                timestamp: 1656937930
                senderDisplayName: "simon"
                profileImage: "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAADIAAAAyCAYAAAAeP4ixAAAAlklEQVR4nOzW0QmDQBAG4SSkl7SUQlJGCrElq9F3QdjjVhh/5nv3cFhY9vUIYQiNITSG0BhCExPynn1gWf9bx498P7/
                              nzPcxEzGExhBdJGYihtAYQlO+tUZvqrPbqeudo5iJGEJjCE15a3VtodH3q2ImYgiNITTlTdG1nUZ5a92VITQxITFiJmIIjSE0htAYQrMHAAD//+wwFVpz+yqXAAAAAElFTkSuQmCC"
                contentType: StatusMessage.ContentType.Text
                message:  "Hello, this is awesome! Feels like decentralized Discord!"
                isContact: true
                trustIndicator: StatusContactVerificationIcons.TrustedType.Verified
            }
            ListElement {
                timestamp: 1657937930
                senderDisplayName: "Mark Cuban"
                contentType: StatusMessage.ContentType.Text
                message: "I know a lot of you really seem to get off or be validated by arguing with strangers online but please know it's a complete waste of your time and energy"
                isContact: false
                trustIndicator: StatusContactVerificationIcons.TrustedType.Untrustworthy
            }
        }
        property var colorHash: ListModel {
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
                anchors.margins: 50
                anchors.fill: parent
                spacing: 16
                model: d.messagesModel
                delegate: StatusMessage {
                    width: ListView.view.width
                    timestamp: model.timestamp
                    messageDetails: StatusMessageDetails {
                        messageText: model.message
                        contentType: model.contentType
                        sender.displayName: model.senderDisplayName
                        sender.isContact: model.isContact
                        sender.trustIndicator: model.trustIndicator
                        sender.profileImage: StatusProfileImageSettings {
                            width: 40
                            height: 40
                            name: model.profileImage || ""
                            colorId: 1
                            colorHash: d.colorHash
                        }
                    }
                    onSenderNameClicked: logs.logEvent("StatusMessage::onSenderNameClicked(): ")
                    onProfilePictureClicked: logs.logEvent("StatusMessage::profilePictureClicked(): ")
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

    Pane {
        SplitView.minimumWidth: 300
        SplitView.preferredWidth: 300
    }
}
