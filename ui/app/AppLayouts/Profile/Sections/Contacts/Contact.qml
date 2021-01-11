import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
import "../../../../../imports"
import "../../../../../shared"
import "../../../../../shared/status"

Rectangle {
    property string name: "Jotaro Kujo"
    property string address: "0x04d8c07dd137bd1b73a6f51df148b4f77ddaa11209d36e43d8344c0a7d6db1cad6085f27cfb75dd3ae21d86ceffebe4cf8a35b9ce8d26baa19dc264efe6d8f221b"
    property string identicon: "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNk+A8AAQUBAScY42YAAAAASUVORK5CYII="
    property string localNickname: "JoJo"
    property bool selectable: false
    property var profileClick: function() {}
    property bool isContact: true
    property bool isBlocked: false
    property string searchStr: ""
    signal blockContactActionTriggered(name: string, address: string)
    signal removeContactActionTriggered(address: string)
    id: container

    visible: isContact && (searchStr == "" || name.includes(searchStr))
    height: visible ? 64 : 0
    anchors.right: parent.right
    anchors.left: parent.left
    border.width: 0
    radius: Style.current.radius
    color: Style.current.transparent

    StatusImageIdenticon {
        id: accountImage
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        source: identicon
    }

    StyledText {
        id: usernameText
        text: name
        elide: Text.ElideRight
        anchors.right: parent.right
        anchors.rightMargin: Style.current.padding
        font.pixelSize: 17
        anchors.top: accountImage.top
        anchors.topMargin: Style.current.smallPadding
        anchors.left: accountImage.right
        anchors.leftMargin: Style.current.padding
    }

    Rectangle {
        property int iconSize: 14
        id: menuButton
        height: 32
        width: 32
        anchors.top: usernameText.top
        anchors.verticalCenter: parent.verticalCenter
        anchors.right: parent.right
        radius: 8
        color: "transparent"

        SVGImage {
            source: "../../../../img/dots-icon.svg"
            width: 18
            height: 4
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
        }

        MouseArea {
            id: mouseArea
            property bool menuOpened: false
            cursorShape: Qt.PointingHandCursor
            anchors.fill: parent
            hoverEnabled: true
            onExited: {
                menuButton.color = "transparent"
            }
            onEntered: {
                menuButton.color = Style.current.border
            }
            onClicked: {
              menuOpened = true
              contactContextMenu.popup()
            }

            PopupMenu {
                id: contactContextMenu
                hasArrow: false
                onClosed: {
                    mouseArea.menuOpened = false
                }
                Action {
                    icon.source: "../../../../img/profileActive.svg"
                    icon.width: menuButton.iconSize
                    icon.height: menuButton.iconSize
                    text: qsTrId("view-profile")
                    onTriggered: profileClick(true, name, address, identicon, "", localNickname)
                    enabled: true
                }
                Action {
                    icon.source: "../../../../img/message.svg"
                    icon.width: menuButton.iconSize
                    icon.height: menuButton.iconSize
                    text: qsTrId("send-message")
                    onTriggered: {
                      tabBar.currentIndex = 0
                      chatsModel.joinChat(address, Constants.chatTypeOneToOne)
                    }
                    enabled: !container.isBlocked
                }
                Action {
                    icon.source: "../../../../img/block-icon.svg"
                    icon.width: menuButton.iconSize
                    icon.height: menuButton.iconSize
                    text: qsTrId("block-user")
                    enabled: !container.isBlocked
                    onTriggered: {
                      container.blockContactActionTriggered(name, address)
                    }
                }
                Action {
                    icon.source: "../../../../img/remove-contact.svg"
                    icon.width: menuButton.iconSize
                    icon.height: menuButton.iconSize
                    icon.color: Style.current.red
                    text: qsTrId("remove-contact")
                    enabled: container.isContact
                    onTriggered: {
                      container.removeContactActionTriggered(address)
                    }
                }
                Action {
                    icon.source: "../../../../img/block-icon.svg"
                    icon.width: menuButton.iconSize
                    icon.height: menuButton.iconSize
                    icon.color: Style.current.red
                    //% "Unblock User"
                    text: qsTrId("unblock-user")
                    enabled: container.isBlocked
                    onTriggered: {
                      profileModel.contacts.unblockContact(address)
                      contactContextMenu.close()
                    }
                }
            }
        }
    }

    StatusRadioButton {
        visible: selectable
        anchors.top: parent.top
        anchors.topMargin: Style.current.smallPadding
        anchors.right: parent.right
        ButtonGroup.group: contactGroup
    }
}
