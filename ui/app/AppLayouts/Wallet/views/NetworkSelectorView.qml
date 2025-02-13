import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQml 2.15
import QtQml.Models 2.15

import StatusQ 0.1
import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Core.Utils 0.1

import utils 1.0

import "../controls"

StatusListView {
    id: root
    /**
      Model is expected to be sorted by layer
      Expected model structure:
        chainName      [string]          - chain long name. e.g. "Ethereum" or "Optimism"
        chainId        [int]             - chain unique identifier
        iconUrl        [string]          - SVG icon name. e.g. "network/Network=Ethereum"
        layer          [int]             - chain layer. e.g. 1 or 2
        isTest         [bool]            - true if the chain is a testnet
    **/
    property bool showIndicator: true
    property bool multiSelection: false
    property bool interactive: true
    property bool showNewChainIcon: false

    /**
        The list selected of chain ids
        It is a read/write property
        WARNING: Update the array, not the internal content
    **/
    property var selection: []

    signal toggleNetwork(int chainId, int index)
    
    objectName: "networkSelectorList"
    
    onSelectionChanged:  d.reprocessSelection()
    onMultiSelectionChanged: d.reprocessSelection()
    Component.onCompleted: d.reprocessSelection()

    implicitWidth: 300
    implicitHeight: contentHeight

    spacing: 4
    delegate: NetworkSelectItemDelegate {
        id: delegateItem

        required property var model
        required property int index

        readonly property bool inSelection: root.selection.includes(model.chainId)

        objectName: "networkSelectorDelegate_" + model.chainName
        height: 48
        width: ListView.view.width
        title: model.chainName
        iconUrl: Theme.svg(model.iconUrl)
        showIndicator: root.showIndicator
        multiSelection: root.multiSelection
        interactive: root.interactive
        showNewIcon: root.showNewChainIcon && Constants.chains.newChains.indexOf(model.chainId) >= 0

        checkState: inSelection ? (d.allSelected && root.interactive ? Qt.PartiallyChecked  : Qt.Checked) : Qt.Unchecked
        nextCheckState: checkState
        onToggled: {
            d.onToggled(checkState, model.chainId)
            root.toggleNetwork(model.chainId, index)
        }
    
        Binding on checkState {
            when: root.multiSelection && d.allSelected && root.interactive
            value: Qt.PartiallyChecked
            restoreMode: Binding.RestoreBindingOrValue
        }

        Binding on checkState {
            value: inSelection ? (d.allSelected && root.interactive ? Qt.PartiallyChecked  : Qt.Checked) : Qt.Unchecked
        }
    }

    QtObject {
        id: d
        readonly property int networksCount: root.model.ModelCount.count
        onNetworksCountChanged: d.reprocessSelection()
        readonly property bool allSelected: root.selection.length === networksCount

        function onToggled(initialState, chainId) {  
            let selection = root.selection
            if (initialState === Qt.Unchecked && initialState !== Qt.PartiallyChecked) {
                if (!root.multiSelection)
                    selection = []

                selection.push(chainId)
            } else if (root.multiSelection) {
                selection = selection.filter((id) => id !== chainId)
            }

            root.selection = [...selection]
        }

        function reprocessSelection() {
            let selection = root.selection

            if (d.networksCount === 0) {
                selection = []
            } else {
                if (!root.multiSelection) {
                    // One and only one chain must be selected
                    if (selection.length === 0) {
                        selection = [ModelUtils.get(root.model, 0, "chainId")]
                    } else if (selection.length > 1) {
                        console.warn("Warning: Multi-selection is disabled, but multiple items are selected. Automatically selecting the first inserted item.")
                        selection = [selection[0]]
                    }
                }
            }

            if (root.selection.sort().join(',') !== selection.sort().join(',')) {
                root.selection = [...selection]
            }
        }
    }
}
