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
    activityNotificationComponent: ActivityNotificationNewKeypairFromPairedDevice {
        notification: QtObject {
            readonly property string id: baseEditor.notificationBaseMock.id
            readonly property double timestamp: baseEditor.notificationBaseMock.timestamp
            readonly property bool read: baseEditor.notificationBaseMock.read
            readonly property bool dismissed: baseEditor.notificationBaseMock.dismissed
            readonly property bool accepted: baseEditor.notificationBaseMock.accepted
            readonly property var message: QtObject {
                readonly property string unparsedText: baseEditor.notificationBaseMock.title
            }

        }
    }
}
// category: Activity Center
// status: good
