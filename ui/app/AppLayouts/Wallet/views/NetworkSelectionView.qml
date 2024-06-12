import QtQuick 2.15
import QtQuick.Controls 2.15

import StatusQ 0.1
import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1

import SortFilterProxyModel 0.2

import utils 1.0

import "../stores/NetworkSelectPopup"
import "../controls"

StatusListView {
    id: root

    required property var flatNetworks
    property bool useEnabledRole: true
    property SingleSelectionInfo singleSelection: SingleSelectionInfo {}
    property var preferredSharingNetworks: []
    property bool preferredNetworksMode: false
    property bool showCheckboxes: true
    property bool showRadioButtons: true

    signal toggleNetwork(var network, int index)

    /// Mirrors Nim's UxEnabledState enum from networks/item.nim
    enum UxEnabledState {
        Enabled,
        AllEnabled,
        Disabled
    }

    model: root.flatNetworks

    delegate: NetworkSelectItemDelegate {
        id: delegateItem

        required property var model
        readonly property int multiSelectCheckState: {
            if(root.preferredNetworksMode) {
                return root.preferredSharingNetworks.length === root.count ? 
                            Qt.PartiallyChecked :
                            root.preferredSharingNetworks.includes(model.chainId.toString()) ? Qt.Checked : Qt.Unchecked
            }
            else if(root.useEnabledRole) {
                return model.isEnabled ? Qt.Checked : Qt.Unchecked
            } else if (model.enabledState === NetworkSelectionView.UxEnabledState.Enabled) {
                return Qt.Checked
            } else {
                if( model.enabledState === NetworkSelectionView.UxEnabledState.AllEnabled) {
                    return Qt.PartiallyChecked
                } else {
                    return Qt.Unchecked
                }
            }
        }

        readonly property int singleSelectCheckState: {
            if (root.singleSelection.currentModel === root.model && root.singleSelection.currentIndex === model.index)
                return Qt.Checked
            return Qt.Unchecked
        }


        implicitHeight: 48
        implicitWidth: root.width
        title: model.chainName
        iconUrl: Style.svg(model.iconUrl)
        showIndicator: (multiSelection && root.showCheckboxes) || (!multiSelection && root.showRadioButtons)
        multiSelection: !root.singleSelection.enabled
                
        Binding on checkState {
            when: root.singleSelection.enabled
            value: singleSelectCheckState
        }

        Binding on checkState {
            when: !root.singleSelection.enabled
            value: multiSelectCheckState
        }

        nextCheckState: checkState
        onToggled: {
            if(!root.singleSelection.enabled) {
                Qt.callLater(root.toggleNetwork, delegateItem.model, delegateItem.model.index)
            } else if(!checkState !== Qt.Checked) {   // Don't allow uncheck
                checkState = checkState === Qt.Checked ? Qt.Unchecked : Qt.Checked
                root.toggleNetwork(delegateItem.model, model.index)
            }
        }
    }

    section {
        property: "layer"
        delegate: Loader {
            required property int section
            width: parent.width
            sourceComponent: section === 2 ? layer2text: null

            Component {
                id: layer2text
                StatusBaseText {
                    width: parent.width
                    color: Theme.palette.baseColor1
                    text: qsTr("Layer 2")
                    height: 40
                    leftPadding: 16
                    topPadding: 10
                    verticalAlignment: Text.AlignVCenter
                }
            }
        }
    }
}
