import QtQuick 2.14
import QtQuick.Controls 2.14
import QtGraphicalEffects 1.13

import StatusQ.Core 0.1
import StatusQ.Components 0.1
import StatusQ.Core.Theme 0.1

TabButton {
    id: root

    property int fontPixelSize: 15
    property bool showBetaTag: false

    contentItem: Item {
        height: 36
        MouseArea {
            id: sensor
            hoverEnabled: true
            anchors.fill: parent

            cursorShape: Qt.PointingHandCursor
            onPressed: mouse.accepted = false
            onReleased: mouse.accepted = false

            Row {
                anchors.centerIn: parent
                spacing: 8

                StatusBaseText {
                    id: label
                    text: root.text
                    color: root.checked ?
                               Theme.palette.statusSwitchTab.selectedTextColor :
                               Theme.palette.statusSwitchTab.textColor
                    font.weight: Font.Medium
                    font.pixelSize: root.fontPixelSize
                }

                StatusBetaTag {
                    visible: root.showBetaTag
                }
            }
        }
    }

    background: Rectangle {
        id: controlBackground
        implicitHeight: 36
        implicitWidth: 148
        color: root.checked ?
            Theme.palette.statusSwitchTab.buttonBackgroundColor :
            "transparent"
        radius: 8
        layer.enabled: true
        layer.effect: DropShadow {
            horizontalOffset: 0
            verticalOffset: 0
            radius: 10
            samples: 25
            spread: 0
            color: Theme.palette.dropShadow
        }
    }
}
