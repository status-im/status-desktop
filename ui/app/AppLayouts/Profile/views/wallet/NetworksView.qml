import QtQuick 2.15

import shared.status 1.0
import shared.popups 1.0
import shared.panels 1.0

import StatusQ.Controls 0.1
import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Components 0.1
import StatusQ.Popups.Dialog 0.1
import utils 1.0

import SortFilterProxyModel 0.2

import "../../stores"
import "../../controls"

Item {
    id: root
    signal goBack

    property WalletStore walletStore
    signal editNetwork(var network)

    Column {
        id: column
        anchors.top: parent.top
        anchors.left: parent.left
        width: parent.width
        spacing: 0

        Repeater {
            id: layer1List
            model: SortFilterProxyModel {
                sourceModel: walletStore.combinedNetworks
                filters: ValueFilter {
                    roleName: "layer"
                    value: 1
                }
            }
            delegate: WalletNetworkDelegate {
                objectName: "walletNetworkDelegate_" + network.chainName + '_' + network.chainId
                network: areTestNetworksEnabled ? model.test: model.prod
                areTestNetworksEnabled: walletStore.areTestNetworksEnabled
                onClicked: editNetwork(walletStore.getNetworkData(model))
            }
        }

        Separator {
            height: Theme.padding
        }

        StatusSectionHeadline {
            leftPadding: Theme.padding
            rightPadding: Theme.padding
            text: qsTr("Layer 2")
            topPadding: Theme.smallPadding
            bottomPadding: Theme.smallPadding
        }

        Repeater {
            id: layer2List
            model: SortFilterProxyModel {
                sourceModel: walletStore.combinedNetworks
                filters: ValueFilter {
                    roleName: "layer"
                    value: 2
                }
            }
            delegate: WalletNetworkDelegate {
                objectName: "walletNetworkDelegate_" + network.chainName + '_' + network.chainId
                network: areTestNetworksEnabled ? model.test: model.prod
                areTestNetworksEnabled: walletStore.areTestNetworksEnabled
                onClicked: editNetwork(walletStore.getNetworkData(model))
            }
        }

        Separator {
            height: Theme.padding
        }

        StatusSectionHeadline {
            leftPadding: Theme.padding
            rightPadding: Theme.padding
            text: qsTr("Advanced")
            topPadding: Theme.smallPadding
            bottomPadding: Theme.smallPadding
        }

        StatusListItem {
            width: parent.width
            asset.name: "settings"
            asset.color: Theme.palette.warningColor1
            asset.bgColor: Theme.palette.warningColor3
            title: qsTr("Testnet mode")
            subTitle: qsTr("Switch entire Status app to testnet only mode")
            onClicked: testnetSwitch.onToggled()
            components: [
                StatusSwitch {
                    id: testnetSwitch
                    objectName: "testnetModeSwitch"
                    checked: walletStore.areTestNetworksEnabled
                    onToggled: {
                        checked = Qt.binding(() => walletStore.areTestNetworksEnabled)
                        Global.openTestnetPopup()
                    }
                }
            ]
        }
    }
}
