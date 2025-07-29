import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import StatusQ.Core.Theme

import AppLayouts.ActivityCenter.views

import Storybook

ActivityNotificationBaseLayout {
    id: root

    communityEditorActive: true
    contactEditorActive: false
    activityNotificationComponent: ActivityNotificationCommunityKicked {
        community: communityEditor.communityMock
        notification: baseEditor.notificationBaseMock

        onSetActiveCommunity: (communityId) =>
                                       logs.logEvent("ActivityNotificationCommunityKicked::onSetActiveCommunityRequested - " + communityId)
    }
}
// category: Activity Center
// status: good
