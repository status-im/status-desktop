import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import StatusQ.Core.Theme

import AppLayouts.ActivityCenter.views
import AppLayouts.ActivityCenter.helpers

import Storybook

import utils

ActivityNotificationBaseLayout {
    id: root

    property bool showFullTimestamp

    showBaseEditorFields: false
    communityEditorActive: true
    contactEditorActive: false
    activityNotificationComponent: ActivityNotificationTransferOwnership {
        notification: baseEditor.notificationBaseMock
        type: setType(notification)
        communityName: communityEditor.communityMock.name
        communityColor:  communityEditor.communityMock.color
        showFullTimestamp: root.showFullTimestamp

        onFinaliseOwnershipClicked: logs.logEvent("ActivityNotificationTransferOwnership::onFinaliseOwnershipClicked")
        onNavigateToCommunityClicked: logs.logEvent("ActivityNotificationTransferOwnership::onNavigateToCommunityClicked")
        onCloseActivityCenter: logs.logEvent("ActivityNotificationTransferOwnership::onCloseActivityCenter")
    }

    additionalEditorComponent: ColumnLayout {
        ColumnLayout {
            RadioButton {
                text: "Pending"
                checked: true
                onCheckedChanged: if(checked) baseEditor.notificationBaseMock.notificationType = ActivityCenterTypes.ActivityCenterNotificationType.OwnerTokenReceived
            }

            RadioButton {
                text: "Declined"
                onCheckedChanged: if(checked) baseEditor.notificationBaseMock.notificationType = ActivityCenterTypes.ActivityCenterNotificationType.OwnershipDeclined
            }

            RadioButton {
                text: "Succeded"
                onCheckedChanged: if(checked) baseEditor.notificationBaseMock.notificationType = ActivityCenterTypes.ActivityCenterNotificationType.OwnershipReceived
            }

            RadioButton {
                text: "Failed"
                onCheckedChanged: if(checked) baseEditor.notificationBaseMock.notificationType = ActivityCenterTypes.ActivityCenterNotificationType.OwnershipFailed
            }

            RadioButton {
                text: "No longer control node"
                onCheckedChanged: if(checked) baseEditor.notificationBaseMock.notificationType = ActivityCenterTypes.ActivityCenterNotificationType.OwnershipLost
            }

            Switch {
                text: "Show full timestamp"
                checked: root.showFullTimestamp
                onCheckedChanged: root.showFullTimestamp = checked
            }
        }

    }

    Component.onCompleted: baseEditor.notificationBaseMock.notificationType = ActivityCenterTypes.ActivityCenterNotificationType.OwnerTokenReceived
}
// category: Activity Center
// status: good
// https://www.figma.com/file/qHfFm7C9LwtXpfdbxssCK3/Kuba%E2%8E%9CDesktop---Communities?type=design&node-id=37206%3A86911&mode=design&t=LuuR3YcDBwDkWIBw-1
