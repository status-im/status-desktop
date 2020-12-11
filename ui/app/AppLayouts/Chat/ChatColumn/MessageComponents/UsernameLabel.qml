import QtQuick 2.3
import "../../../../../shared"
import "../../../../../imports"

Item {
    id: root
    height: childrenRect.height
    width: chatName.width + (ensOrAlias.visible ? ensOrAlias.width + ensOrAlias.anchors.leftMargin : 0)
    property alias label: chatName
    visible: isMessage && authorCurrentMsg != authorPrevMsg

    StyledTextEdit {
        id: chatName
        text: {
            if (isCurrentUser) {
                return qsTr("You")
            }

            if (localName !== "") {
                return localName
            }

            if (userName !== "") {
                return Utils.removeStatusEns(userName)
            }
            return Utils.removeStatusEns(alias)
        }
        color: text.startsWith("@") || isCurrentUser || localName !== "" ? Style.current.blue : Style.current.secondaryText
        font.weight: Font.Medium
        font.pixelSize: Style.current.secondaryTextFontSize
        readOnly: true
        wrapMode: Text.WordWrap
        selectByMouse: true
        MouseArea {
            cursorShape: Qt.PointingHandCursor
            acceptedButtons: Qt.LeftButton | Qt.RightButton
            anchors.fill: parent
            hoverEnabled: true
            onEntered: {
                parent.font.underline = true
            }
            onExited: {
                parent.font.underline = false
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
