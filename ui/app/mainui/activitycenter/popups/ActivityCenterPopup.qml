import QtQuick 2.14
import QtQuick.Controls 2.14
import QtGraphicalEffects 1.13
import Qt.labs.qmlmodels 1.0

import StatusQ.Core 0.1
import StatusQ.Controls 0.1

import SortFilterProxyModel 0.2

import shared 1.0
import shared.popups 1.0
import shared.views.chat 1.0

import utils 1.0

import "../views"
import "../panels"
import "../stores"

Popup {
    id: root

   // NOTE: temporary enum until we have different categories on UI and status-go sides
    enum ActivityCategory {
        All,
        Admin,
        Mentions,
        Replies,
        ContactRequests,
        IdentityVerification,
        Transactions,
        Membership,
        System
    }
    property int currentActivityCategory: ActivityCenterPopup.ActivityCategory.All
    property int adminCount: 0
    property int mentionsCount: 0
    property int repliesCount: 0
    property int contactRequestsCount: 0
    property int identityRequestsCount: 0
    property int membershipCount: 0

    property ActivityCenterStore activityCenterStore
    property var store

    readonly property int unreadNotificationsCount: root.activityCenterStore.unreadNotificationsCount

    function filterActivityCategories(notificationType) {
        switch (root.currentActivityCategory) {
        case ActivityCenterPopup.ActivityCategory.All:
            return true
        case ActivityCenterPopup.ActivityCategory.Admin:
            return notificationType === Constants.activityCenterNotificationTypeCommunityMembershipRequest
        case ActivityCenterPopup.ActivityCategory.Mentions:
            return notificationType === Constants.activityCenterNotificationTypeMention
        case ActivityCenterPopup.ActivityCategory.Replies:
            return notificationType === Constants.activityCenterNotificationTypeReply
        case ActivityCenterPopup.ActivityCategory.ContactRequests:
            return notificationType === Constants.activityCenterNotificationTypeContactRequest
        case ActivityCenterPopup.ActivityCategory.IdentityVerification:
            return notificationType === Constants.activityCenterNotificationTypeContactVerification
        case ActivityCenterPopup.ActivityCategory.Membership:
            return notificationType === Constants.activityCenterNotificationTypeCommunityInvitation ||
                   notificationType === Constants.activityCenterNotificationTypeCommunityMembershipRequest ||
                   notificationType === Constants.activityCenterNotificationTypeCommunityRequest ||
                   notificationType === Constants.activityCenterNotificationTypeCommunityKicked
        default:
            return false
        }
    }

    function calcNotificationType(notificationType, cnt) {
        switch (notificationType) {
        case Constants.activityCenterNotificationTypeMention:
            root.mentionsCount += cnt;
            break;
        case Constants.activityCenterNotificationTypeReply:
            root.repliesCount += cnt;
            break;
        case Constants.activityCenterNotificationTypeContactRequest:
            root.contactRequestsCount += cnt;
            break;
        case Constants.activityCenterNotificationTypeContactVerification:
            root.identityRequestsCount += cnt;
            break;
        case Constants.activityCenterNotificationTypeCommunityInvitation:
            root.membershipCount += cnt;
            break;
        case Constants.activityCenterNotificationTypeCommunityMembershipRequest:
            // NOTE: not a typo, membership requests are shown in both categories
            root.membershipCount += cnt;
            root.adminCount += cnt;
            break;
        case Constants.activityCenterNotificationTypeCommunityRequest:
            root.membershipCount += cnt;
            break;
        case Constants.ActivityCenterNotificationTypeCommunityKicked:
            root.membershipCount += cnt;
            break;
        default:
            break;
        }
    }

    onOpened: {
        Global.popupOpened = true
    }
    onClosed: {
        Global.popupOpened = false
    }

    x: Global.applicationWindow.width - root.width - Style.current.halfPadding
    width: 560
    padding: 0
    modal: false
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
    parent: Overlay.overlay

    Overlay.modeless: null

    background: Rectangle {
        color: Style.current.background
        radius: Style.current.radius
        layer.enabled: true
        layer.effect: DropShadow {
            verticalOffset: 3
            radius: Style.current.radius
            samples: 15
            fast: true
            cached: true
            color: Style.current.dropShadow
        }
    }

    Repeater {
        id: notificationTypeCounter
        model: root.activityCenterStore.activityCenterList

        delegate: Item {
            Component.onCompleted: calcNotificationType(model.notificationType, 1)
            Component.onDestruction: calcNotificationType(model.notificationType, -1)
        }
    }

    ActivityCenterPopupTopBarPanel {
        id: activityCenterTopBar
        width: parent.width
        unreadNotificationsCount: root.unreadNotificationsCount
        hasAdmin: root.adminCount > 0
        hasReplies: root.repliesCount > 0
        hasMentions: root.mentionsCount > 0
        hasContactRequests: root.contactRequestsCount > 0
        hasIdentityRequests: root.identityRequestsCount > 0
        hasMembership: root.membershipCount > 0
        hideReadNotifications: activityCenterStore.hideReadNotifications
        currentActivityCategory: root.currentActivityCategory
        onCategoryTriggered: root.currentActivityCategory = category
        onMarkAllReadClicked: root.activityCenterStore.markAllActivityCenterNotificationsRead()
        onShowHideReadNotifications: activityCenterStore.hideReadNotifications = hideReadNotifications
    }

    StatusListView {
        id: listView
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: activityCenterTopBar.bottom
        anchors.bottom: parent.bottom
        anchors.margins: Style.current.smallPadding
        spacing: 1

        model: SortFilterProxyModel {
            sourceModel: root.activityCenterStore.activityCenterList

            filters: ExpressionFilter { expression: filterActivityCategories(model.notificationType) &&
                                                    !(activityCenterStore.hideReadNotifications && model.read) }

            sorters: [
                RoleSorter {
                    roleName: "timestamp"
                    sortOrder: Qt.DescendingOrder
                }
            ]
        }

        delegate: Loader {
            width: listView.availableWidth

            property int filteredIndex: index
            property var notification: model

            sourceComponent: {
                switch (model.notificationType) {
                    case Constants.activityCenterNotificationTypeMention:
                        return mentionNotificationComponent
                    case Constants.activityCenterNotificationTypeReply:
                        return replyNotificationComponent
                    case Constants.activityCenterNotificationTypeContactRequest:
                        return contactRequestNotificationComponent
                    case Constants.activityCenterNotificationTypeContactVerification:
                        return verificationRequestNotificationComponent
                    case Constants.activityCenterNotificationTypeCommunityInvitation:
                        return communityInvitationNotificationComponent
                    case Constants.activityCenterNotificationTypeCommunityMembershipRequest:
                        return membershipRequestNotificationComponent
                    case Constants.activityCenterNotificationTypeCommunityRequest:
                        return communityRequestNotificationComponent
                    case Constants.activityCenterNotificationTypeCommunityKicked:
                        return communityKickedNotificationComponent
                    default:
                        return null
                }
            }
        }
    }

    Component {
        id: mentionNotificationComponent

        ActivityNotificationMention {
            filteredIndex: parent.filteredIndex
            notification: parent.notification
            store: root.store
            activityCenterStore: root.activityCenterStore
            onCloseActivityCenter: root.close()
        }
    }
    Component {
        id: replyNotificationComponent

        ActivityNotificationReply {
            filteredIndex: parent.filteredIndex
            notification: parent.notification
            store: root.store
            activityCenterStore: root.activityCenterStore
            onCloseActivityCenter: root.close()
        }
    }
    Component {
        id: contactRequestNotificationComponent

        ActivityNotificationContactRequest {
            filteredIndex: parent.filteredIndex
            notification: parent.notification
            store: root.store
            activityCenterStore: root.activityCenterStore
            onCloseActivityCenter: root.close()
        }
    }
    Component {
        id: verificationRequestNotificationComponent

        ActivityNotificationContactVerification {
            filteredIndex: parent.filteredIndex
            notification: parent.notification
            store: root.store
            activityCenterStore: root.activityCenterStore
            onCloseActivityCenter: root.close()
        }
    }
    Component {
        id: communityInvitationNotificationComponent

        ActivityNotificationCommunityInvitation {
            filteredIndex: parent.filteredIndex
            notification: parent.notification
            store: root.store
            activityCenterStore: root.activityCenterStore
            onCloseActivityCenter: root.close()
        }
    }
    Component {
        id: membershipRequestNotificationComponent

        ActivityNotificationCommunityMembershipRequest {
            filteredIndex: parent.filteredIndex
            notification: parent.notification
            store: root.store
            activityCenterStore: root.activityCenterStore
            onCloseActivityCenter: root.close()
        }
    }
    Component {
        id: communityRequestNotificationComponent

        ActivityNotificationCommunityRequest {
            filteredIndex: parent.filteredIndex
            notification: parent.notification
            store: root.store
            activityCenterStore: root.activityCenterStore
            onCloseActivityCenter: root.close()
        }
    }
    Component {
        id: communityKickedNotificationComponent

        ActivityNotificationCommunityKicked {
            filteredIndex: parent.filteredIndex
            notification: parent.notification
            store: root.store
            activityCenterStore: root.activityCenterStore
            onCloseActivityCenter: root.close()
        }
    }
}
