import QtQuick 2.14
import shared 1.0
import shared.panels 1.0
import shared.stores 1.0

import StatusQ.Controls 0.1 as StatusQ
import utils 1.0

StyledText {
    id: chatTime
    color: Style.current.secondaryText
    property string timestamp
    text: Utils.formatTime(chatTime.timestamp)
    font.pixelSize: Style.current.asideTextFontSize

    StatusQ.StatusToolTip {
        visible: hhandler.hovered
        text: new Date(parseInt(chatTime.timestamp, 10)).toLocaleString(Qt.locale(RootStore.locale))
        maxWidth: 350
    }

    HoverHandler {
        id: hhandler
    }
}
