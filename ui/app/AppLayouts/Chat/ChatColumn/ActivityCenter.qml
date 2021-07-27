import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQml.Models 2.13
import "../../../../shared"
import "../../../../shared/status"
import "../../../../imports"
import "./ChatComponents"
import "../components"
import "./MessageComponents"

Popup {
    enum Filter {
        All,
        Mentions,
        Replies,
        ContactRequests
    }
    property int currentFilter: ActivityCenter.Filter.All
    property bool hasMentions: false
    property bool hasReplies: false
//    property bool hasContactRequests: false

    property bool hideReadNotifications: false

    id: activityCenter
    modal: true

    Overlay.modal: Rectangle {
        color: Qt.rgba(0, 0, 0, 0.4)
    }
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
    parent: Overlay.overlay
    width: 560
    background: Rectangle {
        color: Style.current.background
        radius: Style.current.radius
    }
    x: applicationWindow.width - activityCenter.width - Style.current.halfPadding
    onOpened: {
        popupOpened = true
    }
    onClosed: {
        popupOpened = false
    }
    padding: 0

    ActivityCenterTopBar {
        id: activityCenterTopBar
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

            property Component profilePopupComponent: ProfilePopup {
                id: profilePopup
                onClosed: destroy()
            }

            // TODO remove this once it is handled by the activity center
//            Repeater {
//                id: contactList
//                model: profileModel.contacts.contactRequests

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
//                        var popup = profilePopupComponent.createObject(contactList);
//                        popup.openPopup(showFooter, userName, fromAuthor, identicon, textParam, nickName);
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

                model: chatsModel.activityNotificationList

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
                        property string previousNotificationTimestamp: notificationDelegate.idx === 0 ? "" : chatsModel.activityNotificationList.getNotificationData(previousNotificationIndex, "timestamp")


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
                    }

                    Component {
                        id: messageNotificationComponent

                        ActivityCenterMessageComponent {}
                    }

                    Component {
                        id: groupRequestNotificationComponent

                        ActivityCenterGroupRequest {}
                    }
                }
            }

            Item {
                visible: chatsModel.activityNotificationList.hasMoreToShow
                width: parent.width
                height: visible ? showMoreBtn.height + showMoreBtn.anchors.topMargin : 0
                StatusButton {
                    id: showMoreBtn
                    //% "Show more"
                    text: qsTrId("show-more")
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.top: parent.top
                    anchors.topMargin: Style.current.smallPadding
                    onClicked: chatsModel.activityNotificationList.loadMoreNotifications()
                }
            }
        }
    }
}
