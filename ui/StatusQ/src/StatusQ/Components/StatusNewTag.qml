import QtQuick 2.15
import QtGraphicalEffects 1.15

import StatusQ.Components.private 0.1
import StatusQ.Core 0.1
import StatusQ.Controls 0.1
import StatusQ.Core.Theme 0.1

Rectangle {
    id: root

    property alias tooltipText: tip.text
    property alias cursorShape: hoverHandler.cursorShape

    readonly property bool hovered: hoverHandler.hovered

    StatusGradient {
        id: gradient
        anchors.fill: parent
        source: root
    }

    implicitHeight: 20
    implicitWidth: 36
    radius: height/2
    border.width: 0

    StatusBaseText {
        font.pixelSize: 10
        font.weight: Font.DemiBold
        color: Theme.palette.indirectColor4
        anchors.centerIn: parent
        text: qsTr("NEW")
    }

    StatusToolTip {
        id: tip
        visible: hoverHandler.hovered && !!text
        maxWidth: 333
    }

    HoverHandler {
        id: hoverHandler
        enabled: root.visible
    }
}
