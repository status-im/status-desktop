import QtQuick 2.15
import QtQuick.Controls 2.15

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1

import SortFilterProxyModel 0.2

import utils 1.0

import "../stores/NetworkSelectPopup"
import "../controls"

StatusScrollView {
    id: root

    required property var layer1Networks
    required property var layer2Networks
    property bool useEnabledRole: true
    property SingleSelectionInfo singleSelection: SingleSelectionInfo {}
    property var preferredSharingNetworks: []
    property bool preferredNetworksMode: false

    signal toggleNetwork(var network, var model, int index)

    contentWidth: availableWidth
    padding: 0

    ScrollBar.horizontal.policy: ScrollBar.AlwaysOff

    Column {
        id: content

        width: root.availableWidth
        spacing: 4

        Repeater {
            id: chainRepeater1

            width: parent.width
            height: parent.height

            objectName: "networkSelectPopupChainRepeaterLayer1"
            model: root.layer1Networks

            delegate: NetworkSelectItemDelegate {
                implicitHeight: 48
                implicitWidth: root.width
                radioButtonGroup: radioBtnGroup
                networkModel: chainRepeater1.model
                useEnabledRole: root.useEnabledRole
                singleSelection: root.singleSelection
                onToggleNetwork: root.toggleNetwork(network, model, index)
                preferredNetworksMode: root.preferredNetworksMode
                preferredSharingNetworks: root.preferredSharingNetworks
                allChecked: root.preferredSharingNetworks.length === layer1Networks.count + layer2Networks.count
            }
        }

        StatusBaseText {
            font.pixelSize: Style.current.primaryTextFontSize
            color: Theme.palette.baseColor1
            text: qsTr("Layer 2")
            height: 40
            leftPadding: 16
            topPadding: 10
            verticalAlignment: Text.AlignVCenter

            visible: chainRepeater2.count > 0
        }

        Repeater {
            id: chainRepeater2

            model: root.layer2Networks
            delegate: NetworkSelectItemDelegate {
                implicitHeight: 48
                width: parent.width
                radioButtonGroup: radioBtnGroup
                networkModel: chainRepeater2.model
                useEnabledRole: root.useEnabledRole
                singleSelection: root.singleSelection
                onToggleNetwork: root.toggleNetwork(network, model, index)
                preferredNetworksMode: root.preferredNetworksMode
                preferredSharingNetworks: root.preferredSharingNetworks
                allChecked: root.preferredSharingNetworks.length === layer1Networks.count + layer2Networks.count
            }
        }
    }

    ButtonGroup {
        id: radioBtnGroup
    }
}
