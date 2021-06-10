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
    property bool hasContactRequests: contactList.count > 0

    id: activityCenter
    modal: true

    Overlay.modal: Rectangle {
        color: Qt.rgba(0, 0, 0, 0.4)
    }
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
    parent: Overlay.overlay
    width: 560
    height: chatColumnLayout.height - (chatTopBarContent.height * 2) // TODO get screen size
    background: Rectangle {
        color: Style.current.background
        radius: Style.current.radius
    }
    y: chatTopBarContent.height
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
            Repeater {
                id: contactList
                model: profileModel.contacts.contactRequests

                delegate: ContactRequest {
                    visible: activityCenter.currentFilter === ActivityCenter.Filter.All || activityCenter.currentFilter === ActivityCenter.Filter.ContactRequests
                    name: Utils.removeStatusEns(model.name)
                    address: model.address
                    localNickname: model.localNickname
                    identicon: model.thumbnailImage || model.identicon
                    // TODO set to transparent bg if the notif is read
                    color: Utils.setColorAlpha(Style.current.blue, 0.1)
                    radius: 0
                    profileClick: function (showFooter, userName, fromAuthor, identicon, textParam, nickName) {
                        var popup = profilePopupComponent.createObject(contactList);
                        popup.openPopup(showFooter, userName, fromAuthor, identicon, textParam, nickName);
                    }
                    onBlockContactActionTriggered: {
                        blockContactConfirmationDialog.contactName = name
                        blockContactConfirmationDialog.contactAddress = address
                        blockContactConfirmationDialog.open()
                    }
                }
            }

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
                        case Constants.acitivtyCenterNotificationTypeMention:
                            if (!hasMentions) {
                                hasMentions = true
                            }
                            break

                        case Constants.acitivtyCenterNotificationTypeReply:
                            if (!hasReplies) {
                                hasReplies = true
                            }
                            break

                        }
                    }

                    Loader {
                        id: notifLoader
                        anchors.top: parent.top
                        active: !!sourceComponent
                        width: parent.width
                        height: active && item.visible ? item.height : 0
                        sourceComponent: {
                            switch (model.notificationType) {
                            case Constants.acitivtyCenterNotificationTypeMention:return messageNotificationComponent
                            case Constants.acitivtyCenterNotificationTypeReply: return messageNotificationComponent
                            default: return null
                            }
                        }
                    }

                    Component {
                        id: messageNotificationComponent

                        Rectangle {
                            visible: activityCenter.currentFilter === ActivityCenter.Filter.All ||
                                     (model.notificationType === Constants.acitivtyCenterNotificationTypeMention && activityCenter.currentFilter === ActivityCenter.Filter.Mentions) ||
                                     (model.notificationType === Constants.acitivtyCenterNotificationTypeReply && activityCenter.currentFilter === ActivityCenter.Filter.Replies)
                            width: parent.width
                            height: childrenRect.height + Style.current.smallPadding
                            color: model.read ? Style.current.transparent : Utils.setColorAlpha(Style.current.blue, 0.1)

                            Message {
                                id: notificationMessage
                                anchors.right: undefined
                                fromAuthor: model.message.fromAuthor
                                chatId: model.message.chatId
                                userName: model.message.userName
                                alias: model.message.alias
                                localName: model.message.localName
                                message: model.message.message
                                plainText: model.message.plainText
                                identicon: model.message.identicon
                                isCurrentUser: model.message.isCurrentUser
                                timestamp: model.message.timestamp
                                sticker: model.message.sticker
                                contentType: model.message.contentType
                                outgoingStatus: model.message.outgoingStatus
                                responseTo: model.message.responseTo
                                imageClick: imagePopup.openPopup.bind(imagePopup)
                                messageId: model.message.messageId
                                linkUrls: model.message.linkUrls
                                communityId: model.message.communityId
                                hasMention: model.message.hasMention
                                stickerPackId: model.message.stickerPackId
                                pinnedBy: model.message.pinnedBy
                                pinnedMessage: model.message.isPinned
                                activityCenterMessage: true
                                clickMessage: function (isProfileClick) {
                                    if (isProfileClick) {
                                        const pk = model.message.fromAuthor
                                        const userProfileImage = appMain.getProfileImage(pk)
                                        return openProfilePopup(chatsModel.userNameOrAlias(pk), pk, userProfileImage || utilsModel.generateIdenticon(pk))
                                    }

                                    activityCenter.close()
                                    chatsModel.setActiveChannel(model.message.chatId)
                                    positionAtMessage(model.message.messageId)
                                }

                                prevMessageIndex: {
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
                                prevMsgTimestamp: notificationDelegate.idx === 0 ? "" : chatsModel.activityNotificationList.getNotificationData(prevMessageIndex, "timestamp")
                            }

                            StatusIconButton {
                                id: markReadBtn
                                icon.name: "double-check"
                                iconColor: Style.current.primary
                                icon.width: 24
                                icon.height: 24
                                width: 32
                                height: 32
                                onClicked: chatsModel.activityNotificationList.markActivityCenterNotificationRead(model.id)
                                anchors.right: parent.right
                                anchors.rightMargin: 12
                                anchors.verticalCenter: notificationMessage.verticalCenter
                                z: 52

                                StatusToolTip {
                                    visible: markReadBtn.hovered
                                    text: qsTr("Mark as Read")
                                    orientation: "left"
                                    x: - width - Style.current.padding
                                    y: markReadBtn.height / 2 - height / 2 + 4
                                }
                            }

                            ActivityChannelBadge {
                                id: badge
                                name: model.name
                                chatId: model.chatId
                                notificationType: model.notificationType
                                responseTo: model.message.responseTo
                                anchors.top: notificationMessage.bottom
                                anchors.left: parent.left
                                anchors.leftMargin: 61 // TODO find a way to align with the text of the message
                            }
                        }
                    }
                }
            }

            Item {
                visible: chatsModel.activityNotificationList.hasMoreToShow
                width: parent.width
                height: visible ? showMoreBtn.height + showMoreBtn.anchors.topMargin : 0
                StatusButton {
                    id: showMoreBtn
                    text: qsTr("Show more")
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.top: parent.top
                    anchors.topMargin: Style.current.smallPadding
                    onClicked: chatsModel.activityNotificationList.loadMoreNotifications()
                }
            }
        }
    }
}
