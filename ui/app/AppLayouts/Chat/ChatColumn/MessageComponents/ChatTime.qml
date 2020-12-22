import QtQuick 2.3
import "../../../../../shared"
import "../../../../../imports"

StyledTextEdit {
    property bool formatDateTime: false
    id: chatTime
    visible: isMessage
    color: Style.current.darkGrey
    text: formatDateTime ? Utils.formatDateTime(timestamp) : Utils.formatTime(timestamp)
    font.pixelSize: Style.current.asideTextFontSize
    readOnly: true
    selectByMouse: true
}
