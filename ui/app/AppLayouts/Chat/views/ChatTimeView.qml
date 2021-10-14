import QtQuick 2.14
import "../../../../shared"
import "../../../../shared/panels"

import StatusQ.Controls 0.1 as StatusQ
import utils 1.0

StyledText {
    id: chatTime
    property string timestamp
    visible: chatTime.messageStore.isMessage
    color: Style.current.secondaryText
    text: Utils.formatTime(timestamp)
    font.pixelSize: Style.current.asideTextFontSize
    
    StatusQ.StatusToolTip {
        visible: hhandler.hovered
        text: new Date(parseInt(timestamp, 10)).toLocaleString(Qt.locale(globalSettings.locale))
        maxWidth: 350
    }

    HoverHandler {
        id: hhandler
    }
}
