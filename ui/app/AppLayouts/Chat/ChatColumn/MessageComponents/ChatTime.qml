import QtQuick 2.3
import "../../../../../shared"
import "../../../../../imports"

StyledTextEdit {
    property bool formatDateTime: false
    id: chatTime
    visible: isMessage
    color: isImage ? Style.current.white : Style.current.darkGrey
    text: formatDateTime ? Utils.formatDateTime(timestamp, appSettings.locale) : Utils.formatTime(timestamp, appSettings.locale)
    font.pixelSize: Style.current.asideTextFontSize
    readOnly: true
    selectByMouse: true
}
