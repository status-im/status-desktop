import QtQuick 2.15
import QtQuick.Controls 2.15
import QtGraphicalEffects 1.15

import StatusQ.Core 0.1
import StatusQ.Components 0.1
import StatusQ.Core.Theme 0.1

TabButton {
    id: root

    property bool showBetaTag: false

    implicitHeight: 36
    implicitWidth: 148

    font.pixelSize: 15

    contentItem: Item {
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
                font.pixelSize: root.font.pixelSize
            }

            StatusBetaTag {
                visible: root.showBetaTag
                fgColor: root.checked ? Theme.palette.statusSwitchTab.selectedTextColor
                                      : Theme.palette.baseColor1
                cursorShape: hovered ? Qt.PointingHandCursor : undefined
            }
        }
    }

    background: Rectangle {
        color: root.checked ? Theme.palette.statusSwitchTab.buttonBackgroundColor
                            : "transparent"
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

        HoverHandler {
            cursorShape: hovered ? Qt.PointingHandCursor : undefined
        }
    }
}
