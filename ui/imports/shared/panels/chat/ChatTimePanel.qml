import QtQuick 2.14
import shared 1.0
import shared.panels 1.0
import shared.stores 1.0

import StatusQ.Controls 0.1 as StatusQ
import utils 1.0

StyledText {
    id: chatTime

    property string timestamp

    color: Style.current.secondaryText
    text: LocaleUtils.formatTime(chatTime.timestamp, Locale.ShortFormat)
    font.pixelSize: Style.current.asideTextFontSize

    StatusQ.StatusToolTip {
        visible: hhandler.hovered
        text: LocaleUtils.formatDateTime(chatTime.timestamp)
        maxWidth: 350
    }

    HoverHandler {
        id: hhandler
    }
}
