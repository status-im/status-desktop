import QtQuick 2.15
import QtQml 2.15

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Components.private 0.1
import StatusQ.Controls 0.1

Rectangle {
    id: root

    property alias text: contentText.text
    property alias tooltipText: tooltip.text

    implicitWidth: Math.max(36, contentText.paintedWidth + Theme.padding)
    implicitHeight: 20
    radius: height / 2

    gradient: StatusNewItemGradient {}

    StatusBaseText {
        id: contentText
        anchors.fill: parent
        horizontalAlignment: Qt.AlignHCenter
        verticalAlignment: Qt.AlignVCenter
        font.pixelSize: Theme.asideTextFontSize
        font.bold: true
        text: qsTr("NEW")
        color: Theme.palette.background
    }

    HoverHandler {
        id: hoverHandler
        cursorShape: Qt.PointingHandCursor
        enabled: !!root.tooltipText
    }

    StatusToolTip {
        id: tooltip
        objectName: "tooltip"
        visible: hoverHandler.hovered
    }
}
