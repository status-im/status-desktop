import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import StatusQ.Core.Theme

import AppLayouts.ActivityCenter.views

import Storybook

ActivityNotificationBaseLayout {
    id: root

    property bool isBanned: true

    showBaseEditorFields: false
    communityEditorActive: true
    contactEditorActive: false
    activityNotificationComponent: ActivityNotificationCommunityBanUnban {
        notification: baseEditor.notificationBaseMock
        community: communityEditor.communityMock
        banned: root.isBanned

        onSetActiveCommunity: (communityId) =>
                              logs.logEvent("ActivityNotificationCommunityBanUnban::onSetActiveCommunity - " + communityId)
    }

    additionalEditorComponent: ColumnLayout {
        Switch {
            id: isBannedSwitch
            checked: root.isBanned
            text: "Is banned?"
            onCheckedChanged: root.isBanned = checked
        }
    }
}
// category: Activity Center
// status: good
