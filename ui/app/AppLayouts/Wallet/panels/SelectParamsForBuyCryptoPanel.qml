﻿import QtQuick 2.15
import QtQuick.Layouts 1.15

import StatusQ.Core 0.1
import StatusQ.Core.Utils 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Popups 0.1
import StatusQ.Components 0.1
import StatusQ.Components.private 0.1

import AppLayouts.Wallet.controls 1.0

import utils 1.0

ColumnLayout {
    id: root

    // required properties
    required property var assetsModel
    required property var selectedProvider
    required property string selectedTokenKey
    required property int selectedNetworkChainId
    required property var filteredFlatNetworksModel

    signal networkSelected(int chainId)
    signal tokenSelected(string tokensKey)

    onSelectedTokenKeyChanged: assetSelector.update()
    onSelectedNetworkChainIdChanged: assetSelector.update()

    spacing: 20

    StatusListItem {
        objectName: "selectParamsForBuyCryptoPanelHeader"
        Layout.fillWidth: true
        Layout.alignment: Qt.AlignLeft
        leftPadding: 0
        rightPadding: 0

        title: qsTr("Buy via %1").arg(!!root.selectedProvider ? root.selectedProvider.name: "")
        subTitle: qsTr("Select which network and asset")
        statusListItemTitle.color: Theme.palette.directColor1
        asset.name: !!root.selectedProvider ? root.selectedProvider.logoUrl: ""
        asset.isImage: true
        color: Theme.palette.transparent
        enabled: false
    }

    StatusMenuSeparator {
        Layout.fillWidth: true
    }

    ColumnLayout {
        Layout.fillWidth: true
        spacing: 8

        StatusBaseText {
            text: qsTr("Select network")
            color: Theme.palette.directColor1
            font.pixelSize: 15
            lineHeight: 22
            lineHeightMode: Text.FixedHeight
            verticalAlignment: Text.AlignVCenter
        }
        NetworkFilter {
            objectName: "networkFilter"
            Layout.fillWidth: true
            control.popup.width: parent.width
            multiSelection: false
            showSelectionIndicator: false
            flatNetworks: root.filteredFlatNetworksModel
            selection: [root.selectedNetworkChainId]
            onSelectionChanged: root.networkSelected(selection[0])
        }
    }

    ColumnLayout {
        Layout.fillWidth: true
        spacing: 8

        StatusBaseText {
            text: qsTr("Select asset")
            color: Theme.palette.directColor1
            font.pixelSize: 15
            lineHeight: 22
            lineHeightMode: Text.FixedHeight
            verticalAlignment: Text.AlignVCenter
        }

        AssetSelectorCompact {
            id: assetSelector

            objectName: "assetSelector"

            Layout.fillWidth: true

            model: root.assetsModel
            sectionProperty: "sectionName"

            onSelected: root.tokenSelected(key)

            function update() {
                Qt.callLater(()=> {
                    if (!root.assetsModel || !root.selectedTokenKey
                        || root.selectedNetworkChainId === -1)
                        return

                    const entry = ModelUtils.getByKey(root.assetsModel,
                                                      "tokensKey", root.selectedTokenKey)
                    if (entry) {
                        assetSelector.setCustom(entry.name, entry.symbol,
                                                entry.iconSource, entry.tokensKey)
                        root.tokenSelected(entry.tokensKey)
                    } else {
                        assetSelector.reset()
                        root.tokenSelected("")
                    }
                })
            }
        }
    }
}
