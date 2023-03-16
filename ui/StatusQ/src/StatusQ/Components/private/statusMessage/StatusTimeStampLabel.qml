import QtQuick 2.14

import StatusQ.Controls 0.1
import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1

StatusBaseText {
    id: root
    property double timestamp: 0
    property bool showFullTimestamp

    color: Theme.palette.baseColor1
    font.pixelSize: 10
    visible: !!text
    text: showFullTimestamp ? LocaleUtils.formatDateTime(timestamp) : LocaleUtils.formatRelativeTimestamp(timestamp)
    StatusToolTip {
        id: tooltip
        visible: hhandler.hovered && !!text
        maxWidth: 350
    }
    HoverHandler {
        id: hhandler
        enabled: !root.showFullTimestamp
        onHoveredChanged: {
            if(hhandler.hovered && timestamp) {
                tooltip.text = LocaleUtils.formatDateTime(timestamp)
            }
        }
    }
}
