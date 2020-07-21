
import QtQuick 2.3
import "../../../../../shared"
import "../../../../../imports"

StyledText {
    id: retryLbl
    color: Style.current.red
    text: qsTr("Resend")
    font.pixelSize: 12
    visible: isCurrentUser && (timeout || isExpired)
    MouseArea {
        cursorShape: Qt.PointingHandCursor
        anchors.fill: parent
        onClicked: {
            chatsModel.resendMessage(chatId, messageId)
        }
    }
}