import QtQuick 2.14
import "../../../../../shared"
import "../../../../../shared/panels"
import "../../../../../shared/status"

import utils 1.0

StyledText {
    id: chatTime
    visible: isMessage
    color: Style.current.secondaryText
    text: Utils.formatTime(timestamp)
    font.pixelSize: Style.current.asideTextFontSize
    
    StatusToolTip {
        visible: hhandler.hovered
        text: new Date(parseInt(timestamp, 10)).toLocaleString(Qt.locale(globalSettings.locale))
        maxWidth: 350
    }

    HoverHandler {
        id: hhandler
    }
}
