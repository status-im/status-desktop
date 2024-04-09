import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import StatusQ 0.1
import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Core.Utils 0.1
import StatusQ.Components 0.1
import StatusQ.Controls 0.1

import SortFilterProxyModel 0.2

import AppLayouts.Wallet.helpers 1.0

import utils 1.0

import "../views"

StatusComboBox {
    id: root

    required property var flatNetworks
    property bool multiSelection: true
    property bool preferredNetworksMode: false
    property var preferredSharingNetworks: []

    /// \c network is a network.model.nim entry
    /// It is called for every toggled network if \c multiSelection is \c true
    /// If \c multiSelection is \c false, it is called only for the selected network when the selection changes
    signal toggleNetwork(var network)

    function setChain(chainId) {
        if(!multiSelection && !!root.flatNetworks && root.flatNetworks.count > 0) {
            d.currentIndex = NetworkModelHelpers.getChainIndexByChainId(root.flatNetworks, chainId)
            if(d.currentIndex == -1)
                d.currentIndex = NetworkModelHelpers.getChainIndexForFirstLayer2Network(root.flatNetworks)

            // Notify change:
            root.toggleNetwork(ModelUtils.get(root.flatNetworks, d.currentIndex))
        }
    }

    QtObject {
        id: d

        readonly property string selectedChainName: NetworkModelHelpers.getChainName(root.flatNetworks, d.currentIndex)
        readonly property string selectedIconUrl: NetworkModelHelpers.getChainIconUrl(root.flatNetworks, d.currentIndex)
        readonly property bool allSelected: enabledFlatNetworks.count === root.flatNetworks.count
        readonly property bool noneSelected: enabledFlatNetworks.count === 0

        // Persist selection between selectPopupLoader reloads
        property int currentIndex: 0

        property SortFilterProxyModel enabledFlatNetworks: SortFilterProxyModel {
            sourceModel: root.flatNetworks
            filters: ValueFilter { roleName: "isEnabled"; value: true; enabled: !root.preferredNetworksMode}
        }
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
        HoverHandler {
            cursorShape: root.enabled ? Qt.PointingHandCursor : undefined
        }
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
                model: root.preferredNetworksMode ? root.flatNetworks: root.multiSelection ? d.enabledFlatNetworks: []
                delegate: StatusRoundedImage {
                    width: 24
                    height: 24
                    image.source: Style.svg(model.iconUrl)
                    z: index + 1
                    visible: root.preferredNetworksMode ? root.preferredSharingNetworks.includes(model.chainId.toString()): image.source !== ""
                }
            }
        }
    }

    control.popup.contentItem: NetworkSelectionView {
        flatNetworks: root.flatNetworks
        preferredSharingNetworks: root.preferredSharingNetworks
        preferredNetworksMode: root.preferredNetworksMode

        implicitWidth: contentWidth
        implicitHeight: contentHeight

        singleSelection {
            enabled: !root.multiSelection
            currentModel: root.flatNetworks
            currentIndex: d.currentIndex
        }

        useEnabledRole: false

        onToggleNetwork: (network, index) => {
                             d.currentIndex = index
                             root.toggleNetwork(network)
                             if(singleSelection.enabled)
                                control.popup.close()
                         }
    }
}
