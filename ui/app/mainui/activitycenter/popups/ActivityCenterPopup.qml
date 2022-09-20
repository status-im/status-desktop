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
    property int mentionsCount: 0
    property int repliesCount: 0
    property int contactRequestsCount: 0
    property bool hideReadNotifications: false

    property var store
    property var chatSectionModule
    property var messageContextMenu: MessageContextMenuView {
        store: root.store
        reactionModel: root.store.emojiReactionsModel
    }

    readonly property int unreadNotificationsCount : root.store.unreadNotificationsCount

    function filterActivityCategories(notificationType) {
        switch (root.currentActivityCategory) {
        case ActivityCenterPopup.ActivityCategory.All:
            return true
        case ActivityCenterPopup.ActivityCategory.Mentions:
            return notificationType === Constants.activityCenterNotificationTypeMention
        case ActivityCenterPopup.ActivityCategory.Replies:
            return notificationType === Constants.activityCenterNotificationTypeReply
        case ActivityCenterPopup.ActivityCategory.ContactRequests:
            return notificationType === Constants.activityCenterNotificationTypeContactRequest
        default:
            return false
        }
    }

    function calcNotificationType(notificationType, cnt) {
        switch (notificationType) {
        case Constants.activityCenterNotificationTypeMention:
            root.mentionsCount += cnt
            break;
        case Constants.activityCenterNotificationTypeReply:
            root.repliesCount += cnt
            break;
        case Constants.activityCenterNotificationTypeContactRequest:
            root.contactRequestsCount += cnt
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
    dim: true
    modal: false
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
    parent: Overlay.overlay

    Overlay.modeless: MouseArea {
        onClicked: activityCenter.close()
    }

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
        model: root.store.activityCenterList

        delegate: Item {
            Component.onCompleted: calcNotificationType(model.notificationType, 1)
            Component.onDestruction: calcNotificationType(model.notificationType, -1)
        }
    }

    ActivityCenterPopupTopBarPanel {
        id: activityCenterTopBar
        width: parent.width
        unreadNotificationsCount: root.unreadNotificationsCount
        hasReplies: root.repliesCount > 0
        hasMentions: root.mentionsCount > 0
        hasContactRequests: root.contactRequestsCount > 0
        hideReadNotifications: root.hideReadNotifications
        currentActivityCategory: root.currentActivityCategory
        onCategoryTriggered: root.currentActivityCategory = category
        onMarkAllReadClicked: errorText = root.store.activityCenterModuleInst.markAllActivityCenterNotificationsRead()
        onShowHideReadNotifications: root.hideReadNotifications = hideReadNotifications
    }

    StatusListView {
        id: listView
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: activityCenterTopBar.bottom
        anchors.bottom: parent.bottom
        anchors.margins: Style.current.smallPadding

        model: SortFilterProxyModel {
            sourceModel: root.store.activityCenterList

            filters: ExpressionFilter { expression: filterActivityCategories(model.notificationType) &&
                                                    !(root.hideReadNotifications && model.read) }
        }

        delegate: DelegateChooser {
            role: "notificationType"

            DelegateChoice {
                roleValue: Constants.activityCenterNotificationTypeMention

                ActivityNotificationMention {
                    store: root.store
                    notification: model
                    messageContextMenu: root.messageContextMenu
                    previousNotificationIndex: Math.max(0, index - 1)
                    onActivityCenterClose: root.close()
                }
            }
            DelegateChoice {
                roleValue: Constants.activityCenterNotificationTypeReply

                ActivityNotificationReply {
                    store: root.store
                    notification: model
                    messageContextMenu: root.messageContextMenu
                    previousNotificationIndex: Math.max(0, index - 1)
                    onActivityCenterClose: root.close()
                }
            }
            DelegateChoice {
                roleValue: Constants.activityCenterNotificationTypeContactRequest

                ActivityNotificationContactRequest {
                    store: root.store
                    notification: model
                    messageContextMenu: root.messageContextMenu
                    previousNotificationIndex: Math.max(0, index - 1)
                    onActivityCenterClose: root.close()
                }
            }
        }
    }
}
