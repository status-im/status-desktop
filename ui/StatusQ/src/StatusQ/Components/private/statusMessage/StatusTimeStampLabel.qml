import QtQuick 2.14

import StatusQ.Controls 0.1
import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1

StatusBaseText {
    property alias tooltip: tooltip

    color: Theme.palette.baseColor1
    font.pixelSize: 10
    visible: !!text
    StatusToolTip {
        id: tooltip
        visible: hhandler.hovered && !!text
        maxWidth: 350
    }
    HoverHandler {
        id: hhandler
    }
}
