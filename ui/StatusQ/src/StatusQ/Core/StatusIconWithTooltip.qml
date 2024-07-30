import QtQuick 2.13
import QtQuick.Controls 2.15

import StatusQ.Controls 0.1

StatusIcon {
    id: root

    property string tooltipText

    MouseArea {
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
