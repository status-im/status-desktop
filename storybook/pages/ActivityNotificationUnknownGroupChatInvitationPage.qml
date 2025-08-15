import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import StatusQ.Core.Theme

import AppLayouts.ActivityCenter.views

import Storybook

import utils

ActivityNotificationBaseLayout {
    id: root

    property bool groupColorBlue: false
    property bool emoji1: false

    showBaseEditorFields: true
    communityEditorActive: false
    contactEditorActive: true
    activityNotificationComponent: ActivityNotificationUnknownGroupChatInvitation {
        notification:         QtObject {
            id: notificationMock

            readonly property string id: baseEditor.notificationBaseMock.id
            readonly property string name: baseEditor.notificationBaseMock.title
            readonly property string author: baseEditor.notificationBaseMock.title
            readonly property string chatId: baseEditor.notificationBaseMock.id
            readonly property int chatType: Constants.chatType.privateGroupChat
            readonly property bool read: baseEditor.notificationBaseMock.read
            readonly property bool dismissed: baseEditor.notificationBaseMock.dismissed
            readonly property bool accepted: baseEditor.notificationBaseMock.accepted
            property double timestamp: baseEditor.notificationBaseMock.timestamp
        }
        group: QtObject {
            readonly property string name: baseEditor.notificationBaseMock.title
            readonly property string icon: ""
            readonly property string emoji: root.emoji1 ? "👩‍💻" : "🧩"
            readonly property string color: root.groupColorBlue ? "lightblue" : "yellow"
        }
        contactDetails: conntactEditor.contactDetailsMock

        onAcceptActivityCenterNotificationRequested: (communityId) =>
                                                     logs.logEvent("ActivityNotificationUnknownGroupChatInvitation::onAcceptActivityCenterNotificationRequested - " + communityId)
        onDismissActivityCenterNotificationRequested: (communityId) =>
                                                      logs.logEvent("ActivityNotificationUnknownGroupChatInvitation::onDismissActivityCenterNotificationRequested - " + communityId)

        onOpenProfilePopup: (contactId) =>
                            logs.logEvent("ActivityNotificationUnknownGroupChatInvitation::onDismissActivityCenterNotificationRequested::onOpenProfilePopup " + contactId)
    }

    additionalEditorComponent: ColumnLayout {
        Label {
            Layout.fillWidth: true
            Layout.topMargin: 8
            text: "Emoji 1 or Emoji 2"
            font.weight: Font.Bold
        }

        Switch {
            id: groupEmoji
            checked: root.emoji1
            onCheckedChanged: root.emoji1 = checked
        }

        Label {
            Layout.fillWidth: true
            Layout.topMargin: 8
            text: "Yellow or Blue"
            font.weight: Font.Bold
        }

        Switch {
            id: groupColor
            checked: root.groupColorBlue
            onCheckedChanged: root.groupColorBlue = checked
        }
    }
}
// category: Activity Center
// status: good
