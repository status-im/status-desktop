import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import StatusQ.Core.Theme

import AppLayouts.ActivityCenter.views

import Storybook

ActivityNotificationBaseLayout {
    id: root

    showBaseEditorFields: true
    communityEditorActive: false
    contactEditorActive: false
    activityNotificationComponent: ActivityNotificationNewsMessage {
        notification: QtObject {
            property string newsTitle: baseEditor.notificationBaseMock.title
            property string newsDescription: baseEditor.notificationBaseMock.description
            property double timestamp: baseEditor.notificationBaseMock.timestamp
            property bool read: baseEditor.notificationBaseMock.read
            property bool dismissed: baseEditor.notificationBaseMock.dismissed
            property bool accepted: baseEditor.notificationBaseMock.accepted
        }

        onReadMoreClicked: logs.logEvent("ActivityNotificationNewsMessage::onReadMoreClicked")
    }
}
// category: Activity Center
// status: good
// https://www.figma.com/design/17fc13UBFvInrLgNUKJJg5/Kuba%E2%8E%9CDesktop?node-id=39555-95032&m=dev
