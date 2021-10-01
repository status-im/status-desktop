import QtQuick 2.3
import "../../../../shared"

import utils 1.0

Item {
    id: root
    property bool isHovered: false
    height: childrenRect.height
    width: chatName.width + (ensOrAlias.visible ? ensOrAlias.width + ensOrAlias.anchors.leftMargin : 0)
    property alias label: chatName
    property var messageContextMenu
    property bool isCurrentUser: false
    property string userName: ""
    property string localName: ""
    property string displayUserName: ""
    signal clickMessage(bool isProfileClick)
    //TODO remove dynamic scoping
    //visible: isMessage && authorCurrentMsg != authorPrevMsg

    StyledTextEdit {
        id: chatName
        text: displayUserName
        color: text.startsWith("@") || isCurrentUser || localName !== "" ? Style.current.blue : Style.current.secondaryText
        font.weight: Font.Medium
        font.pixelSize: Style.current.secondaryTextFontSize
        font.underline: root.isHovered
        readOnly: true
        wrapMode: Text.WordWrap
        selectByMouse: true
        MouseArea {
            cursorShape: Qt.PointingHandCursor
            acceptedButtons: Qt.LeftButton | Qt.RightButton
            anchors.fill: parent
            hoverEnabled: true
            onEntered: {
                root.isHovered = true
            }
            onExited: {
                root.isHovered = false
            }
            onClicked: {
                if (!!messageContextMenu) {
                    // Set parent, X & Y positions for the messageContextMenu
                    messageContextMenu.parent = root
                    messageContextMenu.setXPosition = function() { return 0}
                    messageContextMenu.setYPosition = function() { return root.height + 4}
                }
                root.clickMessage(true);
            }
        }
    }

    StyledText {
        id: ensOrAlias
        visible: localName !== "" && userName.startsWith("@")
        text: userName
        color: Style.current.secondaryText
        font.pixelSize: chatName.font.pixelSize
        anchors.left: chatName.right
        anchors.leftMargin: chatName.visible ? 4 : 0
    }
}
