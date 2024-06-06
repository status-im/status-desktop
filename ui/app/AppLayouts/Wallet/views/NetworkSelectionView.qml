import QtQuick 2.15
import QtQuick.Controls 2.15

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

    model: root.flatNetworks

    delegate: NetworkSelectItemDelegate {
        implicitHeight: 48
        implicitWidth: root.width
        radioButtonGroup: radioBtnGroup
        networkModel: root.model
        useEnabledRole: root.useEnabledRole
        singleSelection: root.singleSelection
        onToggleNetwork: (network, model, index) => root.toggleNetwork(network, index)
        preferredNetworksMode: root.preferredNetworksMode
        preferredSharingNetworks: root.preferredSharingNetworks
        allChecked: root.preferredSharingNetworks.length === root.count
        showCheckboxes: root.showCheckboxes
        showRadioButtons: root.showRadioButtons
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

    ButtonGroup {
        id: radioBtnGroup
    }
}
