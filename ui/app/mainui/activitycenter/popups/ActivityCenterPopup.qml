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

    onOpened: {
        Global.popupOpened = true
    }
    onClosed: {
        Global.popupOpened = false
    }

    modal: false

    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
    parent: Overlay.overlay

    dim: true
    Overlay.modeless: MouseArea {
        onClicked: activityCenter.close()
    }

    width: 560
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
    x: Global.applicationWindow.width - root.width - Style.current.halfPadding
    padding: 0

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

            filters: ExpressionFilter { expression: filterActivityCategories(model.notificationType) && !(root.hideReadNotifications && model.read) }
        }

        delegate: DelegateChooser {
            role: "notificationType"

            DelegateChoice {
                roleValue: Constants.activityCenterNotificationTypeMention

                ActivityNotificationMention {
                    store: root.store
                    notification: model
                    Component.onCompleted: root.mentionsCount++
                    Component.onDestruction: root.mentionsCount--
                }
            }
            DelegateChoice {
                roleValue: Constants.activityCenterNotificationTypeReply

                ActivityNotificationReply {
                    store: root.store
                    notification: model
                    Component.onCompleted: root.repliesCount++
                    Component.onDestruction: root.repliesCount--
                }
            }
            DelegateChoice {
                roleValue: Constants.activityCenterNotificationTypeContactRequest

                ActivityNotificationContactRequest {
                    store: root.store
                    notification: model
                    Component.onCompleted: root.contactRequestsCount++
                    Component.onDestruction: root.contactRequestsCount--
                }
            }
        }
    }
}

//                         id: notifLoader
//                         anchors.top: parent.top
//                         active: !!sourceComponent
//                         width: parent.width
//                         sourceComponent: {
//                             switch (model.notificationType) {
//                             case Constants.activityCenterNotificationTypeOneToOne:
//                             case Constants.activityCenterNotificationTypeMention:
//                             case Constants.activityCenterNotificationTypeReply: return messageNotificationComponent
//                             case Constants.activityCenterNotificationTypeGroupRequest: return groupRequestNotificationComponent
//                             default: return null
//                             }
//                         }
//                         onLoaded: {
//                             if (model.notificationType === Constants.activityCenterNotificationTypeReply ||
//                                     model.notificationType === Constants.activityCenterNotificationTypeGroupRequest) {
//                                 item.previousNotificationIndex = Qt.binding(() => notifLoader.previousNotificationIndex);
//                                 item.previousNotificationTimestamp = Qt.binding(() => notifLoader.previousNotificationTimestamp);
//                             }
//                         }
//                     }

//                     Component {
//                         id: messageNotificationComponent

//                         ActivityCenterMessageComponentView {
//                             id: activityCenterMessageView
//                             store: root.store
//                             acCurrentActivityCategory: root.currentActivityCategory
//                             chatSectionModule: root.chatSectionModule
//                             messageContextMenu: root.messageContextMenu
//                             hideReadNotifications: root.hideReadNotifications
//                             Connections {
//                                 target: root
//                                 onOpened: activityCenterMessageView.reevaluateItemBadge()
//                             }
//                             onActivityCenterClose: {
//                                 root.close();
//                             }
//                             Component.onCompleted: {
//                                 activityCenterMessageView.reevaluateItemBadge()
//                             }
//                         }
//                     }

//                     Component {
//                         id: groupRequestNotificationComponent

//                         ActivityCenterGroupRequest {
//                             store: root.store
//                             hideReadNotifications: root.hideReadNotifications
//                             acCurrentActivityCategoryAll: root.currentActivityCategory === ActivityCenter.ActivityCategory.All
//                         }
//                     }
//                 }
//             }

