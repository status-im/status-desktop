import QtQuick 2.13
import QtQuick.Layouts 1.14

import StatusQ.Controls 0.1
import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1

StatusBaseText {
    id: timestampLabe;
    property alias tooltip: tooltip

    Layout.alignment: Qt.AlignVCenter
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
