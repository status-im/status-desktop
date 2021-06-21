import QtQuick 2.14

import StatusQ.Core.Theme 0.1

Column {
    spacing: 0

    property real topPadding: 0
    property real bottomPadding: 0

    width: 480

    Item {
        id: topPaddingItem
        height: parent.topPadding
        width: parent.width
    }

    Rectangle {
        id: divider
        color: Theme.palette.baseColor2
        height: 1
        width: parent.width
    }

    Item {
        id: bottomPaddingItem
        height: parent.bottomPadding
        width: parent.width
    }
}
