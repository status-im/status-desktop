import QtQuick 2.3
import "../../../../../shared"
import "../../../../../imports"

StyledTextEdit {
    id: chatName
    visible: isMessage && authorCurrentMsg != authorPrevMsg
    height: this.visible ? 18 : 0
    //% "You"
    text: !isCurrentUser ? Utils.removeStatusEns(userName) : qsTrId("You")
    color: (userName.startsWith("@") || isCurrentUser) ? Style.current.blue : Style.current.textColor
    font.bold: true
    font.pixelSize: 14
    readOnly: true
    wrapMode: Text.WordWrap
    selectByMouse: true
    MouseArea {
        cursorShape: Qt.PointingHandCursor
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        anchors.fill: parent
        onClicked: {
            clickMessage(true)
        }
    }
}
