import QtQuick 2.14

import StatusQ.Controls 0.1


Item {
    id: root

    property int mode: HoldingsTabs.Mode.Add
    property alias tabLabels: tabLabelsRepeater.model
    property alias sourceComponent: tabsLoader.sourceComponent
    property alias addOrUpdateButtonEnabled: addOrUpdateButton.enabled

    property alias currentIndex: tabBar.currentIndex
    readonly property alias item: tabsLoader.item

    signal addClicked
    signal updateClicked
    signal removeClicked

    enum Mode {
        Add, Update
    }

    function setCurrentIndex(index) {
        tabBar.setCurrentIndex(index)
    }

    QtObject {
        id: d

        // values from design
        readonly property int tabBarHeight: 36
        readonly property int tabBarFontPixelSize: 13
        readonly property int contentTopMargin: 16
        readonly property int buttonsHeight: 44
        readonly property int buttonsSpacing: 8
    }

    StatusSwitchTabBar {
        id: tabBar

        anchors.top: parent.top
        anchors.right: parent.right
        anchors.left: parent.left

        height: d.tabBarHeight

        Repeater {
            id: tabLabelsRepeater

            StatusSwitchTabButton {
                text: modelData
                fontPixelSize: d.tabBarFontPixelSize
            }
        }
    }

    Loader {
        id: tabsLoader

        anchors.top: tabBar.bottom
        anchors.right: parent.right
        anchors.left: parent.left
        anchors.topMargin: d.contentTopMargin
    }

    Column {
        spacing: d.buttonsSpacing

        anchors.bottom: parent.bottom
        anchors.right: parent.right
        anchors.left: parent.left

        StatusButton {
            id: addOrUpdateButton

            text: (root.mode === HoldingsTabs.Mode.Add ? qsTr("Add") : qsTr("Update"))
            height: d.buttonsHeight
            width: parent.width
            onClicked: root.mode === HoldingsTabs.Mode.Add
                       ? root.addClicked() : root.updateClicked()
        }

        StatusFlatButton {
            text: qsTr("Remove")
            height: d.buttonsHeight
            width: parent.width
            visible: root.mode === HoldingsTabs.Mode.Update
            type: StatusBaseButton.Type.Danger

            onClicked: root.removeClicked()
        }
    }
}
