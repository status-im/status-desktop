import QtQuick 2.14

import StatusQ.Controls 0.1
import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1

StatusBaseText {
    id: root
    property double timestamp: 0

    color: Theme.palette.baseColor1
    font.pixelSize: 10
    visible: !!text
    text: LocaleUtils.formatTime(timestamp, Locale.ShortFormat)
    StatusToolTip {
        id: tooltip
        visible: hhandler.hovered && !!text
        maxWidth: 350
    }
    HoverHandler {
        id: hhandler
        onHoveredChanged: {
            if(hhandler.hovered && timestamp) {
                tooltip.text = LocaleUtils.formatDateTime(timestamp)
            }
        }
    }
}
