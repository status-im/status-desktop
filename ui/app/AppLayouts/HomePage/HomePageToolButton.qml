import QtQuick 2.15
import QtQuick.Controls 2.15

import StatusQ.Core 0.1
import StatusQ.Controls 0.1
import StatusQ.Core.Theme 0.1

AbstractButton {
    id: root

    property string tooltipText: text

    padding: 6
    hoverEnabled: enabled
    implicitWidth: 24
    implicitHeight: 24

    icon.width: 20
    icon.height: 20
    icon.color: hovered ? Theme.palette.primaryColor1 : Theme.palette.primaryColor2
    Behavior on icon.color { ColorAnimation { duration: Theme.AnimationDuration.Fast } }

    opacity: pressed || down ? Theme.pressedOpacity : enabled ? 1 : Theme.disabledOpacity
    Behavior on opacity { NumberAnimation { duration: Theme.AnimationDuration.Fast } }

    background: Rectangle {
        color: Theme.palette.baseColor5
        radius: Theme.halfPadding
    }
    contentItem: Item {
        StatusIcon {
            anchors.centerIn: parent
            width: root.icon.width
            height: root.icon.height
            icon: root.icon.name
            color: root.icon.color
        }
    }
    StatusToolTip {
        visible: !!text && root.hovered
        offset: -(x + width/2 - root.width/2)
        text: root.tooltipText
    }
    HoverHandler {
        cursorShape: hovered ? Qt.PointingHandCursor : undefined
    }
}
