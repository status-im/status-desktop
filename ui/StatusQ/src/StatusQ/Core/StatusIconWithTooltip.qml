import QtQuick 2.13
import QtQuick.Controls 2.15

import StatusQ.Core 0.1
import StatusQ.Controls 0.1

StatusIcon {
    id: root

    property string tooltipText

    StatusMouseArea {
        id: tooltipSensor
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
    }

    StatusToolTip {
        visible: tooltipSensor.containsMouse && !!text
        text: root.tooltipText
    }
}
