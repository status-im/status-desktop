import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtGraphicalEffects 1.15

import StatusQ 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1
import StatusQ.Popups.Dialog 0.1

import SortFilterProxyModel 0.2

import utils 1.0

import "../controls"
import "../views"

Popup {
    id: root

    required property var flatNetworks

    property bool showSelectionIndicator: true
    property bool selectionAllowed: true
    property bool multiSelection: false
    property bool showManageNetworksButton: false
    property bool showNewTag: false
    property var selection: []

    signal toggleNetwork(int chainId, int index)
    signal manageNetworksClicked()

    onSelectionChanged: {
        if (root.selection !== scrollView.selection) {
            scrollView.selection = root.selection
        }
    }

    modal: false

    padding: 4
    implicitWidth: 300

    background: Rectangle {
        radius: Theme.radius
        color: Theme.palette.background
        border.color: Theme.palette.border
        layer.enabled: true
        layer.effect: DropShadow {
            verticalOffset: 3
            radius: 8
            samples: 15
            fast: true
            cached: true
            color: "#22000000"
        }
    }

    contentItem: ColumnLayout {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: 4

        NetworkSelectorView {
            id: scrollView
            Layout.fillWidth: true

            model: root.flatNetworks
            interactive: root.selectionAllowed
            multiSelection: root.multiSelection
            showIndicator: root.showSelectionIndicator
            showNewTag: root.showNewTag
            selection: root.selection

            onSelectionChanged: {
                if (root.selection !== scrollView.selection) {
                    root.selection = scrollView.selection
                }
            }

            onToggleNetwork: {
                if (!root.multiSelection && root.closePolicy !== Popup.NoAutoClose)
                    root.close()
                root.toggleNetwork(chainId, index)
            }
        }

        StatusButton {
            id: manageNetworksButton
            visible: root.showManageNetworksButton
            Layout.fillWidth: true
            Layout.margins: 4

            icon.name: "settings"
            text: qsTr("Manage networks")
            isOutline: true
            onClicked: root.manageNetworksClicked()
        }
    }
}
