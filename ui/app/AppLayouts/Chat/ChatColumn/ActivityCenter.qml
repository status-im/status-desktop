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

        StyledText {
            text: "Today"
            anchors.left: parent.left
            anchors.leftMargin: Style.current.padding
            font.pixelSize: 15
            color: Style.current.secondaryText
            height: implicitHeight + 4
        }

        ContactRequest {
            name: "@alice.eth"
            address: "0x04db719bf99bee817c97cab909c682d43e1ffa58c4f24edaa0cb7e97e6779dbfd44f430d9a4777e0faa45d74bdbe70240cbea9db8e2cf9a8111374ef4f5d50ac24"
            identicon: "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAADIAAAAyCAYAAAAeP4ixAAAAb0lEQVR4Ae3UQQqAIBRF0Wj9ba9Bq6l5JBQqfn/ngDMH3YS3AAB/tO3H+XRG3b9bR/+gVoREI2RapVXpfd5+X5oXERKNkHS+rk3tOpWkeREh0QiZVu91ql2zNC8iJBoh0yqtSqt1slpCghICANDPBc0ESPh0bHkHAAAAAElFTkSuQmCC"
            // TODO set to transparent bg if the notif is read
            color: Utils.setColorAlpha(Style.current.blue, 0.1)
            radius: 0
        }

        ContactRequest {
            name: "@bob.eth"
            address: "0x04db719bf99bee817c97cab909c682d43e1ffa58c4f24edaa0cb7e97e6779dbfd44f430d9a4777e0faa45d74bdbe70240cbea9db8e2cf9a8111374ef4f5d50ac24"
            identicon: "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAADIAAAAyCAYAAAAeP4ixAAAAjUlEQVR4nOzWwQmEUAwG4V2xF+sTLEOwPqvRBhSUEBh/5jt6eDIEQoZfCENoDKExhMYQmpiQsevhbV+Pq+/ztPw7/hczEUNoDKEpb5C77fRWdZvFTMQQGkNoHt9a3bdT9f2YiRhCY4iaxEzEEBpDaMq3Vjdvra8yhCYmJEbMRAyhMYTGEBpDaM4AAAD//8vbFGZ2G0s4AAAAAElFTkSuQmCC"
            // TODO set to transparent bg if the notif is read
            color: Utils.setColorAlpha(Style.current.blue, 0.1)
            radius: 0
        }

        Rectangle {
            width: parent.width
            height: childrenRect.height + Style.current.smallPadding
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
