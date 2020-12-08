import QtQuick 2.3
import "../../../../../shared"
import "../../../../../imports"

Item {
    id: root
    height: childrenRect.height
    width: chatName.width + ensOrAlias.width + ensOrAlias.anchors.leftMargin
    property string userName: ""
    property string localName: ""
    property string alias: ""
    property alias label: chatName
    visible: isMessage && authorCurrentMsg != authorPrevMsg

    StyledTextEdit {
        id: chatName
        text: {
            if (isCurrentUser) {
                return qsTr("You")
            }

            if (root.localName !== "") {
                return root.localName
            }

            if (root.userName !== "") {
                return Utils.removeStatusEns(root.userName)
            }
            return Utils.removeStatusEns(root.alias)
        }
        color: text.startsWith("@") || isCurrentUser || root.localName !== "" ? Style.current.blue : Style.current.secondaryText
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
        visible: root.localName !== "" && root.userName.startsWith("@")
        text: root.userName
        color: Style.current.secondaryText
        font.pixelSize: chatName.font.pixelSize
        anchors.left: chatName.right
        anchors.leftMargin: chatName.visible ? 4 : 0
    }
}
