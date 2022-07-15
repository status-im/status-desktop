import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

import Status.Application.Navigation
import Status.Controls.Navigation

/// Only one button, squared
NavigationBarSection {
    id: root

    property alias name: button.name
    property alias mutuallyExclusiveGroup: button.mutuallyExclusiveGroup

    // Size of the current button
    implicitHeight: implicitWidth

    NavigationBarButton {
        id: button

        anchors.left: parent.left
        anchors.right: parent.right
        anchors.leftMargin: root.sideMargin
        anchors.rightMargin: root.sideMargin

        selected: root.selected
        onSelectedChanged: root.selected = selected
    }
}
