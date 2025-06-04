import QtQuick 2.15
import QtQuick.Controls 2.15

import StatusQ.Core.Theme 0.1

TabBar {
    id: root

    padding: 1

    contentItem: ListView {
        model: root.contentModel
        currentIndex: root.currentIndex
        clip: true
        spacing: root.spacing
        orientation: ListView.Horizontal
        boundsBehavior: Flickable.StopAtBounds
        flickableDirection: Flickable.AutoFlickIfNeeded
        snapMode: ListView.SnapToItem
    }

    background: Rectangle {
        color: Theme.palette.statusSwitchTab.barBackgroundColor
        radius: Theme.radius
    }
}
