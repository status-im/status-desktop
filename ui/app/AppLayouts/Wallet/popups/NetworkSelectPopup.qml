import QtQuick 2.15
import QtQuick.Controls 2.15
import QtGraphicalEffects 1.0

import StatusQ 0.1
import StatusQ.Core.Theme 0.1
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
    property var selection: []

    signal toggleNetwork(int chainId, int index)

    onSelectionChanged: {
        if (root.selection !== scrollView.selection) {
            scrollView.selection = root.selection
        }
    }

    modal: false

    padding: 4
    implicitWidth: 300

    background: Rectangle {
        radius: Style.current.radius
        color: Style.current.background
        border.color: Style.current.border
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

    contentItem: NetworkSelectorView {
        id: scrollView

        model: root.flatNetworks
        interactive: root.selectionAllowed
        multiSelection: root.multiSelection
        showIndicator: root.showSelectionIndicator
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
}
