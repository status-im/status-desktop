import QtQuick 2.14
import "../../../../../shared"
import "../../../../../shared/status"
import "../../../../../imports"

StyledText {
    property bool formatDateTime: false
    id: chatTime
    visible: isMessage
    color: isImage ? Style.current.white : Style.current.darkGrey
    text: formatDateTime ? Utils.formatDateTime(timestamp, appSettings.locale) : Utils.formatTime(timestamp, appSettings.locale)
    font.pixelSize: Style.current.asideTextFontSize
    
    StatusToolTip {
        visible: hhandler.hovered
        text: new Date(parseInt(timestamp, 10)).toLocaleString(Qt.locale(appSettings.locale))
        width: 350
    }

    HoverHandler {
        id: hhandler
    }
}
