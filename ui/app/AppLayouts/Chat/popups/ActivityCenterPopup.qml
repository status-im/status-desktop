import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQml.Models 2.13
import QtGraphicalEffects 1.13
import shared 1.0
import shared.popups 1.0

import StatusQ.Controls 0.1
import "../views"
import "../panels"

import utils 1.0

Popup {
    enum Filter {
        All,
        Mentions,
        Replies,
        ContactRequests
    }
    property int currentFilter: ActivityCenterPopup.Filter.All
    property bool hasMentions: false
    property bool hasReplies: false
//    property bool hasContactRequests: false

    property bool hideReadNotifications: false
    property var store
    property var chatSectionModule
    property var messageContextMenu

    readonly property int unreadNotificationsCount : activityCenter.store.activityCenterList.unreadCount

    id: activityCenter
    modal: false

    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
    parent: Overlay.overlay

    dim: true
    Overlay.modeless: MouseArea {}

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
    x: Global.applicationWindow.width - activityCenter.width - Style.current.halfPadding
    onOpened: {
        Global.popupOpened = true
    }
    onClosed: {
        Global.popupOpened = false
    }
    padding: 0

    ActivityCenterPopupTopBarPanel {
        id: activityCenterTopBar
        hasReplies: activityCenter.hasReplies
        hasMentions: activityCenter.hasMentions
        hideReadNotifications: activityCenter.hideReadNotifications
        allBtnHighlighted: activityCenter.currentFilter === ActivityCenterPopup.Filter.All
        mentionsBtnHighlighted: activityCenter.currentFilter === ActivityCenterPopup.Filter.Mentions
        repliesBtnHighlighted: activityCenter.currentFilter === ActivityCenterPopup.Filter.Replies
        onAllBtnClicked: {
            activityCenter.currentFilter = ActivityCenterPopup.Filter.All;
        }
        onRepliesBtnClicked: {
            activityCenter.currentFilter = ActivityCenterPopup.Filter.Replies;
        }
        onMentionsBtnClicked: {
            activityCenter.currentFilter = ActivityCenterPopup.Filter.Mentions;
        }
        onPreferencesClicked: {
            activityCenter.close()
            Global.changeAppSectionBySectionType(Constants.appSection.profile, Constants.settingsSubsection.notifications);
        }
        onMarkAllReadClicked: {
            errorText = activityCenter.store.activityCenterModuleInst.markAllActivityCenterNotificationsRead()
        }
    }

    ScrollView {
        id: scrollView
        anchors.top: activityCenterTopBar.bottom
        anchors.topMargin: 13
        anchors.bottom: parent.bottom
        anchors.bottomMargin: Style.current.smallPadding
        width: parent.width
        clip: true

        ScrollBar.horizontal.policy: ScrollBar.AlwaysOff

        Column {
            id: notificationsContainer
            width: parent.width
            spacing: 0

            // TODO remove this once it is handled by the activity center
//            Repeater {
//                id: contactList
//                model: activityCenter.store.contactRequests

//                delegate: ContactRequest {
//                    visible: !hideReadNotifications &&
//                             (activityCenter.currentFilter === ActivityCenter.Filter.All || activityCenter.currentFilter === ActivityCenter.Filter.ContactRequests)
//                    name: Utils.removeStatusEns(model.name)
//                    address: model.address
//                    localNickname: model.localNickname
//                    identicon: model.thumbnailImage || model.identicon
//                    // TODO set to transparent bg if the notif is read
//                    color: Utils.setColorAlpha(Style.current.blue, 0.1)
//                    radius: 0
//                    profileClick: function (showFooter, userName, fromAuthor, identicon, textParam, nickName) {
//                        Global.openProfilePopup(fromAuthor)
//                    }
//                    onBlockContactActionTriggered: {
//                        blockContactConfirmationDialog.contactName = name
//                        blockContactConfirmationDialog.contactAddress = address
//                        blockContactConfirmationDialog.open()
//                    }
//                }
//            }

            Repeater {
                model: notifDelegateList
            }

            DelegateModelGeneralized {
                id: notifDelegateList

                lessThan: [
                    function(left, right) { return left.timestamp > right.timestamp }
                ]

                model: activityCenter.store.activityCenterList

                delegate: Item {
                    id: notificationDelegate
                    width: parent.width
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
                        property string previousNotificationTimestamp: notificationDelegate.idx === 0 ? "" : activityCenter.store.activityCenterList.getNotificationData(previousNotificationIndex, "timestamp")
                        onPreviousNotificationTimestampChanged: {
                            activityCenter.store.messageStore.prevMsgTimestamp = previousNotificationTimestamp;
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
                            store: activityCenter.store
                            acCurrentFilter: activityCenter.currentFilter
                            chatSectionModule: activityCenter.chatSectionModule
                            messageContextMenu: activityCenter.messageContextMenu
                            hideReadNotifications: activityCenter.hideReadNotifications
                            Connections {
                                target: activityCenter
                                onOpened: activityCenterMessageView.reevaluateItemBadge()
                            }
                            onActivityCenterClose: {
                                activityCenter.close();
                            }
                            Component.onCompleted: {
                                activityCenterMessageView.reevaluateItemBadge()
                            }
                        }
                    }

                    Component {
                        id: groupRequestNotificationComponent

                        ActivityCenterGroupRequest {
                            store: activityCenter.store
                            hideReadNotifications: activityCenter.hideReadNotifications
                            acCurrentFilterAll: activityCenter.currentFilter === ActivityCenter.Filter.All
                        }
                    }
                }
            }

            Item {
                visible: activityCenter.store.activityCenterModuleInst.hasMoreToShow
                width: parent.width
                height: visible ? showMoreBtn.height + showMoreBtn.anchors.topMargin : 0
                StatusButton {
                    id: showMoreBtn
                    text: qsTr("Show more")
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.top: parent.top
                    anchors.topMargin: Style.current.smallPadding
                    onClicked: activityCenter.store.activityCenterModuleInst.loadMoreNotifications()
                }
            }
        }
    }
}
