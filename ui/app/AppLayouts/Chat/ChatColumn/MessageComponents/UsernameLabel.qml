import QtQuick 2.3
import "../../../../../shared"
import "../../../../../imports"

StyledTextEdit {
    id: chatName
    visible: isMessage && authorCurrentMsg != authorPrevMsg
    height: this.visible ? 18 : 0
    text: !isCurrentUser ? userName : qsTr("You")
    font.bold: true
    font.pixelSize: 14
    readOnly: true
    wrapMode: Text.WordWrap
    selectByMouse: true
    MouseArea {
        cursorShape: Qt.PointingHandCursor
        anchors.fill: parent
        onClicked: {
            clickMessage()
        }
    }
}
