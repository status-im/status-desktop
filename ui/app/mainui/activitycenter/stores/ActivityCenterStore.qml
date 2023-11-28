import QtQuick 2.15

import shared 1.0

QtObject {
    id: root

    enum ActivityCenterGroup {
        All = 0,
        Mentions = 1,
        Replies = 2,
        Membership = 3,
        Admin = 4,
        ContactRequests = 5,
        IdentityVerification = 6,
        Transactions = 7,
        System = 8
    }

    enum ActivityCenterNotificationType {
        NoType = 0,
        NewOneToOne = 1,
        NewPrivateGroupChat = 2,
        Mention = 3,
        Reply = 4,
        ContactRequest = 5,
        CommunityInvitation = 6,
        CommunityRequest = 7,
        CommunityMembershipRequest = 8,
        CommunityKicked = 9,
        ContactVerification = 10,
        ContactRemoved = 11,
        NewKeypairAddedToPairedDevice = 12,
        OwnerTokenReceived = 13,
        OwnershipReceived = 14,
        OwnershipLost = 15,
        OwnershipFailed = 16,
        OwnershipDeclined = 17,
        ShareAccounts = 18
    }

    enum ActivityCenterReadType {
        Read = 1,
        Unread = 2,
        All = 3
    }

    enum ActivityCenterMembershipStatus {
        None = 0,
        Pending = 1,
        Accepted = 2,
        Declined = 3,
        AcceptedPending = 4,
        DeclinedPending = 5
    }

    enum ActivityCenterContactRequestState {
        Pending = 1,
        Accepted = 2,
        Dismissed = 3
    }

    readonly property var activityCenterModuleInst: activityCenterModule
    readonly property var activityCenterNotifications: activityCenterModuleInst.activityNotificationsModel

    readonly property int unreadNotificationsCount: activityCenterModuleInst.unreadActivityCenterNotificationsCount
    readonly property bool hasUnseenNotifications: activityCenterModuleInst.hasUnseenActivityCenterNotifications
    readonly property int activeNotificationGroup: activityCenterModuleInst.activeNotificationGroup
    readonly property int activityCenterReadType: activityCenterModuleInst.activityCenterReadType

    readonly property int adminCount: activityCenterModuleInst.adminCount
    readonly property int mentionsCount: activityCenterModuleInst.mentionsCount
    readonly property int repliesCount: activityCenterModuleInst.repliesCount
    readonly property int contactRequestsCount: activityCenterModuleInst.contactRequestsCount
    readonly property int identityVerificationCount: activityCenterModuleInst.identityVerificationCount
    readonly property int membershipCount: activityCenterModuleInst.membershipCount

    function markAllActivityCenterNotificationsRead() {
        root.activityCenterModuleInst.markAllActivityCenterNotificationsRead()
    }

    function markActivityCenterNotificationRead(notification) {
        root.activityCenterModuleInst.markActivityCenterNotificationRead(notification.id)
    }

    function markActivityCenterNotificationUnread(notification) {
        root.activityCenterModuleInst.markActivityCenterNotificationUnread(notification.id)
    }

    function markAsSeenActivityCenterNotifications() {
        root.activityCenterModuleInst.markAsSeenActivityCenterNotifications()
    }

    function switchTo(notification) {
        root.activityCenterModuleInst.switchTo(notification.sectionId, notification.chatId, notification.message.id)
    }

    function setActiveNotificationGroup(group) {
        root.activityCenterModuleInst.setActiveNotificationGroup(group)
    }

    function setActivityCenterReadType(readType) {
        root.activityCenterModuleInst.setActivityCenterReadType(readType)
    }

    function fetchActivityCenterNotifications() {
        root.activityCenterModuleInst.fetchActivityCenterNotifications()
    }
}
