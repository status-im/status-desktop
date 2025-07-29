import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import StatusQ.Core.Theme

import AppLayouts.ActivityCenter.views

import Storybook

ActivityNotificationBaseLayout {
    id: root

    showBaseEditorFields: false
    communityEditorActive: true
    contactEditorActive: false
    activityNotificationComponent: ActivityNotificationCommunityShareAddresses {
        notification: baseEditor.notificationBaseMock
        communityName: communityEditor.communityMock.name
        communityColor: communityEditor.communityMock.color
        communityImage: communityEditor.communityMock.image

        onOpenCommunityClicked: logs.logEvent("ActivityNotificationCommunityShareAddresses::onOpenCommunityClicked")
        onOpenShareAccountsClicked: logs.logEvent("ActivityNotificationCommunityShareAddresses::onOpenShareAccountsClicked")
    }
}
// category: Activity Center
// status: good
