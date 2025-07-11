import QtQuick

import StatusQ.Core
import StatusQ.Core.Theme
import StatusQ.Controls

/// Forces size, hard to reuse it
StatusBaseText {
    id: root 

    property bool expandable: false
    property bool expanded: false
    readonly property real actualWidth: implicitWidth
    property real maxWidth: width

    font.family: Theme.monoFont.name
    font.pixelSize: Theme.additionalTextSize
    elide: Text.ElideMiddle
    color: Theme.palette.baseColor1

    Component.onCompleted: {
        expanded = actualWidth <= maxWidth
    }

    StatusMouseArea {
        anchors.fill: parent
        cursorShape: root.expandable ? Qt.PointingHandCursor : Qt.arrowCursor
        enabled: root.expandable

        onClicked: {
            if (root.expanded) {
                root.width = root.maxWidth
            } else {
                root.width = root.actualWidth
            }
            root.expanded = !root.expanded
        }
    }
}
