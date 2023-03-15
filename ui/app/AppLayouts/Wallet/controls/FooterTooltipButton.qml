import QtQuick 2.14

import StatusQ.Controls 0.1

Item {
    property alias button: button
    property alias text: button.text
    property alias icon: button.icon.name
    property alias tooltipText: tooltip.text

    implicitWidth: button.width
    implicitHeight: button.height

    StatusFlatButton {
        id: button
        anchors.centerIn: parent
    }
    MouseArea {
        id: mouseArea
        anchors.fill: button
        hoverEnabled: !button.enabled
        enabled: !button.enabled
        cursorShape: Qt.PointingHandCursor
    }
    StatusToolTip {
        id: tooltip
        visible: mouseArea.containsMouse
    }
}
