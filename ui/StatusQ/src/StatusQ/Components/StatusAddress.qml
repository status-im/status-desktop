import QtQuick 2.14

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1

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
        maxWidth = width
        expanded = actualWidth <= maxWidth
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: root.expandable ? Qt.PointingHandCursor : Qt.arrowCursor
        enabled: root.expandable

        onClicked: {
            if (root.expanded) {
                width = root.width = root.maxWidth
            } else {
                width = root.width = root.actualWidth
            }
            root.expanded = !root.expanded
        }
    }
}
