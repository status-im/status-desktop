import QtQuick 2.14
import QtQuick.Controls 2.14 as T

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1

T.ScrollBar {
    id: root

    // TODO: add this sizes to Theme
    implicitWidth: 14
    implicitHeight: 14

    background: null

    contentItem: Rectangle {
        color: root.hovered || root.active ? Theme.palette.primaryColor3 : Theme.palette.baseColor2
        opacity: enabled ? 1.0 : 0.0
        radius: Math.min(width, height) / 2

        Behavior on opacity { NumberAnimation { duration: 100 } }
    }
}

