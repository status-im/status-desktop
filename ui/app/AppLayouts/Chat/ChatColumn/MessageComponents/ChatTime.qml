import QtQuick 2.3
import "../../../../../shared"
import "../../../../../imports"

StyledTextEdit {
    id: chatTime
    visible: isMessage
    color: Style.current.darkGrey
    text: Utils.formatTime(timestamp)
    font.pixelSize: 10
    readOnly: true
    selectByMouse: true
}
