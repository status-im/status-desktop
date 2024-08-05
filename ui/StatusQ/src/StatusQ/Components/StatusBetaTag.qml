import QtQuick 2.15

import StatusQ.Core 0.1
import StatusQ.Controls 0.1
import StatusQ.Core.Theme 0.1

Rectangle {
    id: root

    property alias tooltipText: tip.text

    implicitHeight: 20
    implicitWidth: 36
    radius: 4
    color: "transparent"
    border.width: 1
    border.color: Theme.palette.baseColor1

    StatusBaseText {
        id: label
        font.pixelSize: 11
        font.weight: Font.Medium
        color: Theme.palette.baseColor1
        anchors.centerIn: parent
        text: "Beta"
    }

    StatusToolTip {
        id: tip
        visible: hoverHandler.hovered && !!text
    }

    HoverHandler {
        id: hoverHandler
    }
}
