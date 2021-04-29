import QtQuick 2.3
import "../../../../../shared"
import "../../../../../imports"

Item {
    id: root
    property bool isHovered: false
    height: childrenRect.height
    width: chatName.width + (ensOrAlias.visible ? ensOrAlias.width + ensOrAlias.anchors.leftMargin : 0)
    property alias label: chatName
    visible: isMessage && authorCurrentMsg != authorPrevMsg

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
                clickMessage(true)
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
