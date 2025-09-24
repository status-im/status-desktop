import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import StatusQ.Core.Theme

import AppLayouts.ActivityCenter.views
import AppLayouts.ActivityCenter.helpers

import Storybook

ActivityNotificationBaseLayout {
    id: root

    property bool isPendingState: true
    property bool isAcceptedState
    property bool isDeclinedState

    showBaseEditorFields: false
    communityEditorActive: true
    contactEditorActive: false
    activityNotificationComponent: ActivityNotificationCommunityRequest {
        community: communityEditor.communityMock
        notification: QtObject {
            readonly property string id: baseEditor.notificationBaseMock.id
            readonly property string communityId: baseEditor.notificationBaseMock.communityId
            readonly property double timestamp: baseEditor.notificationBaseMock.timestamp
            readonly property bool read: baseEditor.notificationBaseMock.read
            readonly property bool dismissed: baseEditor.notificationBaseMock.dismissed
            readonly property bool accepted: baseEditor.notificationBaseMock.accepted
            readonly property int membershipStatus: updateRequestState(root.isPendingState,
                                                                       root.isAcceptedState,
                                                                       root.isDeclinedState)

            function updateRequestState(isPendingState, isAcceptedState, isDeclinedState) {
                if(isPendingState) {
                    return ActivityCenterTypes.ActivityCenterMembershipStatus.Pending
                }

                if(isAcceptedState) {
                    return ActivityCenterTypes.ActivityCenterMembershipStatus.Accepted
                }

                if(isDeclinedState) {
                    return ActivityCenterTypes.ActivityCenterMembershipStatus.Declined
                }
                return ActivityCenterTypes.ActivityCenterMembershipStatus.None
            }
        }

        onSetActiveCommunityRequested: (notificationId, communityId) =>
                                       logs.logEvent("ActivityNotificationCommunityRequest::onSetActiveCommunityRequested - " + communityId)
    }

    additionalEditorComponent: ColumnLayout {
        RadioButton {
            id: isPending
            checked: root.isPendingState
            text: "Is pending request?"
            onCheckedChanged: root.isPendingState = checked
        }

        RadioButton {
            id: isAccepted
            checked: root.isAcceptedState
            text: "Is accepted request?"
            onCheckedChanged: root.isAcceptedState = checked
        }

        RadioButton {
            id: isDismissed
            checked: root.isDeclinedState
            text: "Is declined request?"
            onCheckedChanged: root.isDeclinedState = checked
        }
    }
}
// category: Activity Center
// status: good
