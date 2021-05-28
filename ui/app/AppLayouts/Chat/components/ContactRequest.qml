import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
import "../../../../imports"
import "../../../../shared"
import "../../../../shared/status"

Rectangle {
    property string name
    property string address
    property string identicon
    property string localNickname
    property var profileClick: function() {}
    signal blockContactActionTriggered(name: string, address: string)
    property bool isHovered: false
    id: container

    height: visible ? 64 : 0
    anchors.right: parent.right
    anchors.left: parent.left
    border.width: 0
    radius: Style.current.radius
    color: isHovered ? Style.current.backgroundHover : Style.current.transparent

    StatusImageIdenticon {
        id: accountImage
        anchors.left: parent.left
        anchors.leftMargin: Style.current.padding
        anchors.verticalCenter: parent.verticalCenter
        source: identicon
    }

    StyledText {
        id: usernameText
        text: name
        elide: Text.ElideRight
        font.pixelSize: 17
        anchors.top: accountImage.top
        anchors.topMargin: Style.current.smallPadding
        anchors.left: accountImage.right
        anchors.leftMargin: Style.current.padding
        anchors.right: declineBtn.left
        anchors.rightMargin: Style.current.padding
    }

    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.RightButton
        onClicked: {
            if (mouse.button === Qt.RightButton) {
                contactContextMenu.popup()
                return
            }
        }
    }

    HoverHandler {
        onHoveredChanged: container.isHovered = hovered
    }

    StatusIconButton {
        id: declineBtn
        icon.name: "close"
        onClicked: profileModel.contacts.rejectContactRequest(container.address)
        width: 32
        height: 32
        padding: 6
        iconColor: Style.current.danger
        hoveredIconColor: Style.current.danger
        highlightedBackgroundColor: Utils.setColorAlpha(Style.current.danger, 0.1)
        anchors.right: acceptBtn.left
        anchors.rightMargin: Style.current.halfPadding
        anchors.verticalCenter: parent.verticalCenter
    }

    StatusIconButton {
        id: acceptBtn
        icon.name: "check-circle"
        onClicked: {
            chatsModel.joinPrivateChat(container.address, "")
            profileModel.contacts.addContact(container.address)
        }
        width: 32
        height: 32
        padding: 6
        iconColor: Style.current.success
        hoveredIconColor: Style.current.success
        highlightedBackgroundColor: Utils.setColorAlpha(Style.current.success, 0.1)
        anchors.right: menuButton.left
        anchors.rightMargin: Style.current.halfPadding
        anchors.verticalCenter: parent.verticalCenter
    }

    StatusContextMenuButton {
        property int iconSize: 14
        id: menuButton
        anchors.verticalCenter: parent.verticalCenter
        anchors.right: parent.right
        anchors.rightMargin: Style.current.padding
        MouseArea {
            id: mouseArea
            cursorShape: Qt.PointingHandCursor
            anchors.fill: parent

            onClicked: {
                contactContextMenu.popup()
            }

            PopupMenu {
                id: contactContextMenu
                hasArrow: false
                Action {
                    icon.source: "../../../img/profileActive.svg"
                    icon.width: menuButton.iconSize
                    icon.height: menuButton.iconSize
                    //% "View Profile"
                    text: qsTrId("view-profile")
                    onTriggered: profileClick(true, name, address, identicon, "", localNickname)
                    enabled: true
                }
                Separator {}
                Action {
                    icon.source: "../../../img/block-icon.svg"
                    icon.width: menuButton.iconSize
                    icon.height: menuButton.iconSize
                    icon.color: Style.current.danger
                    text: qsTr("Decline and block")
                    onTriggered: container.blockContactActionTriggered(name, address)
                }
            }
        }
    }
}
