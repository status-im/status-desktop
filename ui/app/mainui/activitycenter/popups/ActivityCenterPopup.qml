import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQml.Models 2.13
import QtGraphicalEffects 1.13

import StatusQ.Core 0.1
import StatusQ.Controls 0.1

import shared 1.0
import shared.popups 1.0
import shared.views.chat 1.0

import utils 1.0

import "../views"
import "../panels"

Popup {
    id: root

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
    property bool hasMentions: false
    property bool hasReplies: false
//    property bool hasContactRequests: false

    property bool hideReadNotifications: false
    property var store
    property var chatSectionModule
    property var messageContextMenu: MessageContextMenuView {
        store: root.store
        reactionModel: root.store.emojiReactionsModel
    }

    readonly property int unreadNotificationsCount : root.store.activityCenterList.unreadCount

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
    onOpened: {
        Global.popupOpened = true
    }
    onClosed: {
        Global.popupOpened = false
    }
    padding: 0

    ActivityCenterPopupTopBarPanel {
        id: activityCenterTopBar
        width: parent.width
        hasReplies: root.hasReplies
        hasMentions: root.hasMentions
        hideReadNotifications: root.hideReadNotifications
        currentActivityCategory: root.currentActivityCategory
        onCategoryTriggered: {
            root.currentActivityCategory = category;
        }
        onMarkAllReadClicked: {
            errorText = root.store.activityCenterModuleInst.markAllActivityCenterNotificationsRead()
        }
    }

   // TODO: replace with StatusListView
    StatusScrollView {
        id: scrollView
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: activityCenterTopBar.bottom
        anchors.topMargin: 13
        anchors.bottom: parent.bottom
        anchors.bottomMargin: Style.current.smallPadding
        width: parent.width

        ScrollBar.horizontal.policy: ScrollBar.AlwaysOff

        Column {
            id: notificationsContainer
            width: scrollView.availableWidth
            spacing: 0

            Repeater {
                model: notifDelegateList
            }

            DelegateModelGeneralized {
                id: notifDelegateList

                lessThan: [
                    function(left, right) { return left.timestamp > right.timestamp }
                ]

                model: root.store.activityCenterList

                delegate: Item {
                    id: notificationDelegate
                    width: parent.availableWidth
                    height: notifLoader.active ? childrenRect.height : 0

                    property int idx: DelegateModel.itemsIndex

                    Component.onCompleted: {
                        switch (model.notificationType) {
                        case Constants.activityCenterNotificationTypeMention:
                            if (!hasMentions) {
                                hasMentions = true
                            }
                            break

                        case Constants.activityCenterNotificationTypeReply:
                            if (!hasReplies) {
                                hasReplies = true
                            }
                            break
                        }
                    }

                    Loader {
                        property int previousNotificationIndex: {
                            if (notificationDelegate.idx === 0) {
                                return 0
                            }

                            // This is used in order to have access to the previous message and determine the timestamp
                            // we can't rely on the index because the sequence of messages is not ordered on the nim side
                            if (notificationDelegate.idx < notifDelegateList.items.count - 1) {
                                return notifDelegateList.items.get(notificationDelegate.idx - 1).model.index
                            }
                            return -1;
                        }
                        readonly property string previousNotificationTimestamp: notificationDelegate.idx === 0 ? "" :
                                                       root.store.activityCenterList.getNotificationData(previousNotificationIndex, "timestamp")
                        onPreviousNotificationTimestampChanged: {
                            root.store.messageStore.prevMsgTimestamp = previousNotificationTimestamp;
                        }

                        id: notifLoader
                        anchors.top: parent.top
                        active: !!sourceComponent
                        width: parent.width
                        sourceComponent: {
                            switch (model.notificationType) {
                            case Constants.activityCenterNotificationTypeOneToOne:
                            case Constants.activityCenterNotificationTypeMention:
                            case Constants.activityCenterNotificationTypeReply: return messageNotificationComponent
                            case Constants.activityCenterNotificationTypeGroupRequest: return groupRequestNotificationComponent
                            default: return null
                            }
                        }
                        onLoaded: {
                            if (model.notificationType === Constants.activityCenterNotificationTypeReply ||
                                    model.notificationType === Constants.activityCenterNotificationTypeGroupRequest) {
                                item.previousNotificationIndex = Qt.binding(() => notifLoader.previousNotificationIndex);
                                item.previousNotificationTimestamp = Qt.binding(() => notifLoader.previousNotificationTimestamp);
                            }
                        }
                    }

                    Component {
                        id: messageNotificationComponent

                        ActivityCenterMessageComponentView {
                            id: activityCenterMessageView
                            store: root.store
                            acCurrentActivityCategory: root.currentActivityCategory
                            chatSectionModule: root.chatSectionModule
                            messageContextMenu: root.messageContextMenu
                            hideReadNotifications: root.hideReadNotifications
                            Connections {
                                target: root
                                onOpened: activityCenterMessageView.reevaluateItemBadge()
                            }
                            onActivityCenterClose: {
                                root.close();
                            }
                            Component.onCompleted: {
                                activityCenterMessageView.reevaluateItemBadge()
                            }
                        }
                    }

                    Component {
                        id: groupRequestNotificationComponent

                        ActivityCenterGroupRequest {
                            store: root.store
                            hideReadNotifications: root.hideReadNotifications
                            acCurrentActivityCategoryAll: root.currentActivityCategory === ActivityCenter.ActivityCategory.All
                        }
                    }
                }
            }

            Item {
                visible: root.store.activityCenterModuleInst.hasMoreToShow
                width: parent.width
                height: visible ? showMoreBtn.height + showMoreBtn.anchors.topMargin : 0
                StatusButton {
                    id: showMoreBtn
                    text: qsTr("Show more")
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.top: parent.top
                    anchors.topMargin: Style.current.smallPadding
                    onClicked: root.store.activityCenterModuleInst.loadMoreNotifications()
                }
            }
        }
    }
}
