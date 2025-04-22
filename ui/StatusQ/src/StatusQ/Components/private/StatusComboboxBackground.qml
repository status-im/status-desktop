import QtQuick 2.15

import StatusQ.Core.Theme 0.1

Rectangle {
    id: root

    required property bool active // hovered or down

    border.width: 1
    border.color: Theme.palette.directColor7
    radius: Theme.radius
    color: root.active ? Theme.palette.directColor8 : "transparent"
    HoverHandler {
        cursorShape: root.enabled ? Qt.PointingHandCursor : undefined
    }
}
