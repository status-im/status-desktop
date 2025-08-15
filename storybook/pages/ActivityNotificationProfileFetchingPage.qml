import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import StatusQ.Core.Theme

import AppLayouts.ActivityCenter.views
import AppLayouts.ActivityCenter.helpers

import Storybook

ActivityNotificationBaseLayout {
    id: root

    showBaseEditorFields: false
    communityEditorActive: false
    contactEditorActive: false
    activityNotificationComponent: ActivityNotificationProfileFetching {
        notification: baseEditor.notificationBaseMock
        type: setType(notification)

        onTryAgainClicked: logs.logEvent("ActivityNotificationProfileFetching::onTryAgainClicked")
    }

    additionalEditorComponent: ColumnLayout {
        Label {
            text: "States:"
            font.bold: true
        }
        RadioButton {
            checked: true
            text: "Is fetching?"            
            onCheckedChanged: baseEditor.notificationBaseMock.notificationType = ActivityCenterTypes.ActivityCenterNotificationType.BackupSyncingFetching
        }

        RadioButton {
            text: "Success"
            onCheckedChanged: baseEditor.notificationBaseMock.notificationType = ActivityCenterTypes.ActivityCenterNotificationType.BackupSyncingSuccess
        }

        RadioButton {
            text: "Partial Failure?"
            onCheckedChanged: baseEditor.notificationBaseMock.notificationType = ActivityCenterTypes.ActivityCenterNotificationType.BackupSyncingPartialFailure
        }

        RadioButton {
            text: "Failure"
            onCheckedChanged: baseEditor.notificationBaseMock.notificationType = ActivityCenterTypes.ActivityCenterNotificationType.BackupSyncingFailure
        }
    }

    Component.onCompleted: baseEditor.notificationBaseMock.notificationType = ActivityCenterTypes.ActivityCenterNotificationType.BackupSyncingFetching
}
// category: Activity Center
// status: good
