import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import StatusQ.Core.Theme

import AppLayouts.ActivityCenter.views

import Storybook

ActivityNotificationBaseLayout {
    id: root

    communityEditorActive: true
    contactEditorActive: true
    activityNotificationComponent: ActivityNotificationCommunityInvitation {
        community: communityEditor.communityMock
        contactDetails: conntactEditor.contactDetailsMock
        notification: QtObject {
            readonly property string id: baseEditor.notificationBaseMock.id
            readonly property string author: baseEditor.notificationBaseMock.title
            readonly property string chatId: baseEditor.notificationBaseMock.id
            readonly property string sectionId: "sectionId-123"
            readonly property bool read: baseEditor.notificationBaseMock.read
            readonly property bool dismissed: baseEditor.notificationBaseMock.dismissed
            readonly property bool accepted: baseEditor.notificationBaseMock.accepted
            property double timestamp: baseEditor.notificationBaseMock.timestamp
            property QtObject message: QtObject {
                readonly property string communityId: "communityId-222"
                readonly property string id: "messageID-aaa"
                readonly property string messageText: baseEditor.notificationBaseMock.description
            }
        }

        onSetActiveCommunityRequested: (communityId) =>
                                       logs.logEvent("ActivityNotificationCommunityInvitation::onSetActiveCommunityRequested - " + communityId)
        onSwitchToRequested: (sectionId, chatId, messageId) =>
                             logs.logEvent("ActivityNotificationCommunityInvitation::onSwitchToRequested",
                                           ["sectionId", "chatId", "messageId"],
                                           [sectionId, chatId, messageId])
        onOpenProfilePopup: (contactId) =>
                            logs.logEvent("ActivityNotificationCommunityInvitation::onOpenProfilePopup - " + contactId)
    }
}
// category: Activity Center
// status: good
