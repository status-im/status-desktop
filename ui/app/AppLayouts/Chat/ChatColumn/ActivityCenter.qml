import QtQuick 2.13
import QtQuick.Controls 2.13
import "../../../../shared"
import "../../../../shared/status"
import "../../../../imports"
import "./ChatComponents"
import "../components"

Popup {
    enum Filter {
        All,
        Mentions,
        Replies,
        ContactRequests
    }
    property int currentFilter: ActivityCenter.Filter.All

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

    Column {
        id: notificationsContainer
        anchors.top: activityCenterTopBar.bottom
        anchors.topMargin: 13
        width: parent.width

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

        StyledText {
            text: "Today"
            anchors.left: parent.left
            anchors.leftMargin: Style.current.padding
            font.pixelSize: 15
            bottomPadding: 4
            topPadding: Style.current.halfPadding
            color: Style.current.secondaryText
        }

        Rectangle {
            visible: activityCenter.currentFilter === ActivityCenter.Filter.All || activityCenter.currentFilter === ActivityCenter.Filter.Mentions
            width: parent.width
            height: visible ? childrenRect.height + Style.current.smallPadding : 0
            color: Utils.setColorAlpha(Style.current.blue, 0.1)

            Message {
                id: placeholderMessage
                anchors.right: undefined
                messageId: "placeholderMessage"
                userName: "@vitalik"
                identicon: "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAADIAAAAyCAYAAAAeP4ixAAAAb0lEQVR4Ae3UQQqAIBRF0Wj9ba9Bq6l5JBQqfn/ngDMH3YS3AAB/tO3H+XRG3b9bR/+gVoREI2RapVXpfd5+X5oXERKNkHS+rk3tOpWkeREh0QiZVu91ql2zNC8iJBoh0yqtSqt1slpCghICANDPBc0ESPh0bHkHAAAAAElFTkSuQmCC"
                message: "@roger great question my dude"
                contentType: Constants.messageType
                placeholderMessage: true
            }

            StatusIconButton {
                id: markReadBtn
                icon.name: "double-check"
                iconColor: Style.current.primary
                icon.width: 24
                icon.height: 24
                width: 32
                height: 32
                onClicked: console.log('TODO mark read')
                anchors.right: parent.right
                anchors.rightMargin: 12
                anchors.verticalCenter: placeholderMessage.verticalCenter
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
                name: "status-desktop-ui"
                chatType: Constants.chatTypePublic
                chatId: "status-desktop-ui"
                anchors.top: markReadBtn.bottom
                anchors.topMargin: Style.current.halfPadding
                anchors.left: parent.left
                anchors.leftMargin: 61 // TODO find a way to align with the text of the message
            }
        }

        // TODO add reply placeholder and chaeck if we can do the bubble under
    }
}
