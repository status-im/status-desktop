import QtQuick 2.3
import shared.controls 1.0
import shared 1.0
import shared.panels 1.0

import utils 1.0

Item {
    id: root
    property bool isHovered: false
    height: childrenRect.height
    width: chatName.width + (ensOrAlias.visible ? ensOrAlias.width + ensOrAlias.anchors.leftMargin : 0)
    property alias label: chatName

    property var messageContextMenu
    property string displayName
    property string localName
    property bool amISender

    signal clickMessage(bool isProfileClick)

    StyledTextEdit {
        id: chatName
        text: root.amISender ? qsTr("You") : displayName
        color: text.startsWith("@") || root.amISender || localName !== "" ? Style.current.blue : Style.current.secondaryText
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
                if (!!root.messageContextMenu) {
                    // Set parent, X & Y positions for the messageContextMenu
                    root.messageContextMenu.parent = root
                    root.messageContextMenu.setXPosition = function() { return 0}
                    root.messageContextMenu.setYPosition = function() { return root.height + 4}
                }
                root.clickMessage(true);
            }
        }
    }

    StyledText {
        id: ensOrAlias
        visible: localName !== "" && displayName.startsWith("@")
        text: displayName
        color: Style.current.secondaryText
        font.pixelSize: chatName.font.pixelSize
        anchors.left: chatName.right
        anchors.leftMargin: chatName.visible ? Style.dp(4) : 0
    }
}
