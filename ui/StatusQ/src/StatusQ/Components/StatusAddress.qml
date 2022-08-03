import QtQuick 2.14

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1

/// Forces size, hard to reuse it
StatusBaseText {
    id: root 

    property bool expandable: false
    property bool expanded: false
    readonly property real actualWidth: implicitWidth
    property real maxWidth: width

    font.family: Theme.palette.monoFont.name
    font.pixelSize: 13
    elide: Text.ElideMiddle
    color: Theme.palette.baseColor1

    Component.onCompleted: {
        expanded = actualWidth <= maxWidth
    }

    MouseArea {
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
