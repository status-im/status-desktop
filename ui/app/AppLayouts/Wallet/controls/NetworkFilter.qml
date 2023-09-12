import QtQuick 2.15
import QtQuick.Layouts 1.13

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Core.Utils 0.1
import StatusQ.Components 0.1
import StatusQ.Controls 0.1

import AppLayouts.Wallet.helpers 1.0

import utils 1.0

import "../views"

StatusComboBox {
    id: root

    required property var allNetworks
    required property var layer1Networks
    required property var layer2Networks
    required property var enabledNetworks
    property bool multiSelection: true
    property bool preferredNetworksMode: false
    property var preferredSharingNetworks: []

    /// \c network is a network.model.nim entry
    /// It is called for every toggled network if \c multiSelection is \c true
    /// If \c multiSelection is \c false, it is called only for the selected network when the selection changes
    signal toggleNetwork(var network)

    function setChain(chainId) {
        if(!multiSelection && !!d.currentModel && d.currentModel.count > 0) {
            d.currentModel = NetworkModelHelpers.getLayerNetworkModelByChainId(root.layer1Networks,
                                                                               root.layer2Networks,
                                                                               chainId) ?? root.layer2Networks
            d.currentIndex = NetworkModelHelpers.getChainIndexByChainId(root.layer1Networks,
                                                                        root.layer2Networks,
                                                                        chainId)

            // Notify change:
            root.toggleNetwork(ModelUtils.get(d.currentModel, d.currentIndex))
        }
    }

    QtObject {
        id: d

        readonly property string selectedChainName: NetworkModelHelpers.getChainName(d.currentModel, d.currentIndex)
        readonly property string selectedIconUrl: NetworkModelHelpers.getChainIconUrl(d.currentModel, d.currentIndex)
        readonly property bool allSelected: (!!root.enabledNetworks && !!root.allNetworks) ? root.enabledNetworks.count === root.allNetworks.count :
                                                                                             false
        readonly property bool noneSelected: (!!root.enabledNetworks) ? root.enabledNetworks.count === 0 : false

        // Persist selection between selectPopupLoader reloads
        property var currentModel: layer2Networks
        property int currentIndex: 0
    }

    onMultiSelectionChanged: root.setChain()

    control.padding: 12
    control.spacing: 0
    control.rightPadding: 36
    control.topPadding: 7
    control.popup.width: 430

    size: StatusComboBox.Size.Small

    control.background: Rectangle {
        height: 38
        radius: 8
        color: root.control.hovered ? Theme.palette.baseColor2 : "transparent"
        border.color: Theme.palette.directColor7
    }

    contentItem: RowLayout {
        spacing: 16
        StatusSmartIdenticon {
            Layout.alignment: Qt.AlignVCenter
            asset.height: 24
            asset.width: 24
            asset.isImage: !root.multiSelection
            asset.name: !root.multiSelection ? Style.svg(d.selectedIconUrl) : ""
            active: !root.multiSelection
            visible: active
        }
        StatusBaseText {
            Layout.alignment: Qt.AlignVCenter
            Layout.fillWidth: true
            font.pixelSize: 13
            font.weight: Font.Medium
            elide: Text.ElideRight
            lineHeight: 24
            lineHeightMode: Text.FixedHeight
            verticalAlignment: Text.AlignVCenter
            text: root.multiSelection ? (d.noneSelected ? qsTr("Select networks"): d.allSelected ? qsTr("All networks") : "") : d.selectedChainName
            color: Theme.palette.baseColor1
            visible: !!text
        }
        Row {
            spacing: -4
            visible: !d.allSelected && chainRepeater.count > 0
            Repeater {
                id: chainRepeater
                model: root.multiSelection ? root.enabledNetworks : []
                delegate: StatusRoundedImage {
                    width: 24
                    height: 24
                    visible: image.source !== ""
                    image.source: Style.svg(model.iconUrl)
                    z: index + 1
                }
            }
        }
    }

    control.popup.contentItem: NetworkSelectionView {
        layer1Networks: root.layer1Networks
        layer2Networks: root.layer2Networks
        preferredSharingNetworks: root.preferredSharingNetworks
        preferredNetworksMode: root.preferredNetworksMode

        implicitWidth: contentWidth
        implicitHeight: contentHeight

        singleSelection {
            enabled: !root.multiSelection
            currentModel: d.currentModel
            currentIndex: d.currentIndex
        }

        useEnabledRole: false

        onToggleNetwork: (network, networkModel, index) => {
                             d.currentModel = networkModel
                             d.currentIndex = index
                             root.toggleNetwork(network)
                             if(singleSelection.enabled)
                                control.popup.close()
                         }
    }
}
