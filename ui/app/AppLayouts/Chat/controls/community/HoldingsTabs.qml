import QtQuick 2.14

import StatusQ.Core 0.1
import StatusQ.Components 0.1
import StatusQ.Controls 0.1


Item {
    property alias addButtonEnabled: addButton.enabled
    property alias tabLabels: tabLabelsRepeater.model

    property alias currentIndex: tabBar.currentIndex
    property alias sourceComponent: tabsLoader.sourceComponent

    readonly property alias item: tabsLoader.item

    signal addClicked

    StatusSwitchTabBar {
        id: tabBar

        anchors.top: parent.top
        anchors.right: parent.right
        anchors.left: parent.left

        height: 36 // by design

        Repeater {
            id: tabLabelsRepeater

            StatusSwitchTabButton {
                text: modelData
                fontPixelSize: 13
            }
        }
    }

    Loader {
        id: tabsLoader

        anchors.top: tabBar.bottom
        anchors.right: parent.right
        anchors.left: parent.left
        anchors.topMargin: 16
    }

    StatusButton {
        id: addButton

        text: qsTr("Add")
        height: 44

        anchors.bottom: parent.bottom
        anchors.right: parent.right
        anchors.left: parent.left

        onClicked: addClicked()
    }
}
