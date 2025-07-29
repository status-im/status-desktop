import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import StatusQ.Controls
import StatusQ.Components
import StatusQ.Core.Theme

import AppLayouts.ActivityCenter.views
import utils

import Storybook

SplitView {
    id: root

    SplitView {
        orientation: Qt.Vertical
        SplitView.fillWidth: true

        Logs { id: logs }


        QtObject {
            id: notificationMock

            readonly property string id: editor.notificationBaseMock.id
            readonly property string author: editor.notificationBaseMock.title
            readonly property string chatId: editor.notificationBaseMock.id
            readonly property int chatType: isCommunityType.checked ? Constants.chatType.communityChat : Constants.chatType.privateGroupChat
            readonly property string sectionId: "sectionId-123"
            readonly property bool read: editor.notificationBaseMock.read
            readonly property bool dismissed: editor.notificationBaseMock.dismissed
            readonly property bool accepted: editor.notificationBaseMock.accepted
            property double timestamp: editor.notificationBaseMock.timestamp
            property QtObject message: QtObject {
                readonly property string communityId: "communityId-222"
                readonly property string messageText: editor.notificationBaseMock.description
                property bool amISender: true
                property int contentType: StatusMessage.ContentType.Text // Sticker / Unknown / Image ...
                property string messageImage: ""
                property string albumMessageImages: ""
                property int albumImagesCount: 0
            }
        }

        QtObject {
            id: contactDetailsMock

            readonly property string localNickname: editor.notificationBaseMock.title
            readonly property string name: contactName.text
            readonly property string alias: contactAlias.text
            readonly property string compressedPubKey: "zQ3...Ww4PG2"
            readonly property bool isContact: true
        }

        QtObject {
            id: channelMock

            readonly property string name: channelName.text
            readonly property string icon: ""
            readonly property string emoji: channelEmoji.checked ? "👩‍💻" : "🧩"
            readonly property string color: channelColor.checked ? "yellow" : "lightblue"
        }

        Item {
            SplitView.fillHeight: true
            SplitView.fillWidth: true

            ActivityNotificationMention {
                id: notification

                function updateContactDetails() {
                    notification.contactDetails = contactDetailsMock
                }

                anchors.centerIn: parent
                width: editor.leftPanelMaxWidth
                height: implicitHeight
                backgroundColor: Theme.palette.primaryColor3

                notification: notificationMock
                contactsModel: QtObject {}
                contactDetails: contactDetailsMock
                community: communityEditor.communityMock
                channel: channelMock

                onSetActiveCommunity: (communityId) => {
                                          logs.logEvent("ActivityNotificationMention::onSetActiveCommunity: " + communityId) }
                onSwitchToRequested: (sectionId, chatId, messageId) => {
                                         logs.logEvent("ActivityNotificationMention::onSwitchToRequested",
                                                       ["sectionId", "chatId", "messageId"],
                                                       [sectionId, chatId, messageId]) }
                onMarkActivityCenterNotificationReadRequested: (notificationId) => {
                                                                   logs.logEvent("ActivityNotificationMention::onMarkActivityCenterNotificationReadRequested: " + notificationId ) }
                onMarkActivityCenterNotificationUnreadRequested: (notificationId) => {
                                                                     logs.logEvent("ActivityNotificationMention::onMarkActivityCenterNotificationUnreadRequested: " + notificationId ) }
                onCloseActivityCenter: logs.logEvent("ActivityNotificationMention::onCloseActivityCenter" )
            }

        }

        LogsAndControlsPanel {
            SplitView.minimumHeight: 100
            SplitView.preferredHeight: 160

            logsView.logText: logs.logText
        }
    }

    Pane {
        SplitView.minimumWidth: 300
        SplitView.preferredWidth: 300

        ActivityNotificationBaseEditor {
            id: editor

            // Contact related properties:
            Label {
                Layout.fillWidth: true
                Layout.topMargin: 8
                text: "Contact Name:"
                font.weight: Font.Bold
            }

            TextField {
                id: contactName
                Layout.fillWidth: true
                text: "Anna"
            }

            Label {
                Layout.fillWidth: true
                Layout.topMargin: 8
                text: "Alias:"
                font.weight: Font.Bold
            }

            TextField {
                id: contactAlias
                Layout.fillWidth: true
                text: "ui-dev"
            }

            Label {
                Layout.fillWidth: true
                Layout.topMargin: 8
                text: "Community or Group Chat"
                font.weight: Font.Bold
            }

            Switch {
                id: isCommunityType
                checked: true
            }


            ActivityNotificationCommunityEditor {
                id: communityEditor
            }

            // Channel related properties
            Label {
                Layout.fillWidth: true
                Layout.topMargin: 8
                text: "Channel name:"
                font.weight: Font.Bold
            }

            TextField {
                id: channelName
                Layout.fillWidth: true
                text: "General"
            }

            Label {
                Layout.fillWidth: true
                Layout.topMargin: 8
                text: "Emoji 1 or Emoji 2"
                font.weight: Font.Bold
            }

            Switch {
                id: channelEmoji
                checked: true
            }

            Label {
                Layout.fillWidth: true
                Layout.topMargin: 8
                text: "Orange or Purple"
                font.weight: Font.Bold
            }

            Switch {
                id: channelColor
                checked: true
            }
        }
    }
}

// category: Activity Center
// https://www.figma.com/design/17fc13UBFvInrLgNUKJJg5/Kuba----Desktop-Legacy?node-id=1424-327759&m=dev
