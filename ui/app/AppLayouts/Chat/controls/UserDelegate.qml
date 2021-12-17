import QtQuick 2.13
import QtQuick.Controls 2.13
import shared 1.0
import shared.panels 1.0

import utils 1.0

import StatusQ.Components 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Core 0.1

Item {
    id: wrapper
    anchors.right: parent.right
    anchors.left: parent.left
    height: rectangle.height + 4

    property string publicKey: ""
    property string name: ""
    property string icon: ""
    property bool isIdenticon: true
    property int userStatus: Constants.userStatus.offline
    property var messageContextMenu
    property bool enableMouseArea: true
    property bool hovered: false
    property color color: {
        if (wrapper.hovered) {
            return Style.current.menuBackgroundHover
        }
        return Style.current.transparent
    }

    Rectangle {
        id: rectangle
        width: parent.width
        height: 40
        radius: 8
        color: wrapper.color

        StatusSmartIdenticon {
            id: contactImage
            anchors.left: parent.left
            anchors.leftMargin: Style.current.padding
            anchors.verticalCenter: parent.verticalCenter
            image: StatusImageSettings {
                width: 28
                height: 28
                source: wrapper.icon
                isIdenticon: wrapper.isIdenticon
            }
            icon: StatusIconSettings {
                width: 28
                height: 28
                letterSize: 15
            }
            name: wrapper.name
        }

        StyledText {
            id: contactInfo
            text: wrapper.name
            anchors.right: parent.right
            anchors.rightMargin: Style.current.smallPadding
            elide: Text.ElideRight
            color: Style.current.textColor
            font.weight: Font.Medium
            font.pixelSize: 15
            anchors.left: contactImage.right
            anchors.leftMargin: Style.current.halfPadding
            anchors.verticalCenter: parent.verticalCenter
        }

        StatusBadge {
            id: statusBadge
            width: 15
            height: 15
            anchors.left: contactImage.right
            anchors.leftMargin: -Style.current.smallPadding
            anchors.bottom: contactImage.bottom
            visible: wrapper.userStatus !== Constants.userStatus.offline
            border.width: 3
            border.color: Theme.palette.statusAppNavBar.backgroundColor
            color: {
                if(wrapper.userStatus === Constants.userStatus.online)
                    return Style.current.green
                else if(wrapper.userStatus === Constants.userStatus.idle)
                    return Style.current.orange
                else if(wrapper.userStatus === Constants.userStatus.doNotDisturb)
                    return Style.current.red

                return "transparent"
            }
        }

        MouseArea {
            enabled: enableMouseArea
            cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
            acceptedButtons: Qt.LeftButton | Qt.RightButton
            anchors.fill: parent
            hoverEnabled: true
            onEntered: {
                wrapper.hovered = true
            }
            onExited: {
                wrapper.hovered = false
            }
            onClicked: {
                if (mouse.button === Qt.LeftButton) {
                    //TODO remove dynamic scoping
                    openProfilePopup(wrapper.name, wrapper.publicKey, wrapper.icon, "", wrapper.name);
                }
                 else if (mouse.button === Qt.RightButton && !!messageContextMenu) {
                    // Set parent, X & Y positions for the messageContextMenu
                    messageContextMenu.parent = rectangle
                    messageContextMenu.setXPosition = function() { return 0}
                    messageContextMenu.setYPosition = function() { return rectangle.height}

                    messageContextMenu.isProfile = true
                    messageContextMenu.myPublicKey = userProfile.pubKey
                    messageContextMenu.selectedUserPublicKey = wrapper.publicKey
                    messageContextMenu.selectedUserDisplayName = wrapper.name
                    messageContextMenu.selectedUserIcon = wrapper.icon
                    messageContextMenu.isSelectedUserIconIdenticon = wrapper.isIdenticon
                    messageContextMenu.popup()
                }
            }
        }
    }
}
