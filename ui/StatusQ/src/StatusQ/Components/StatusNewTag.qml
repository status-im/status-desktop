import QtQuick 2.15
import QtQml 2.15
import QtGraphicalEffects 1.15

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1

Item {
    id: root

    property alias text: contentText.text
    property alias tooltipText: tooltip.text

    implicitWidth: Math.max(36, contentText.paintedWidth + Theme.padding)
    implicitHeight: 20

    Rectangle {
        width: parent.width
        height: parent.height
        anchors.centerIn: parent
        radius: height / 2

        layer.enabled: true
        layer.effect: LinearGradient {
            cached: true
            start: Qt.point(0, 1.227 * height)
            end: Qt.point(0.9 * width, 0)
            gradient: Gradient {
                GradientStop {
                    position: 0.0
                    color: "#2A799B"
                }
                GradientStop {
                    position: 0.0817
                    color: "#F6B03C"
                }
                GradientStop {
                    position: 1.000
                    color: "#FF33A3"
                }
            }
        }
    }

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
