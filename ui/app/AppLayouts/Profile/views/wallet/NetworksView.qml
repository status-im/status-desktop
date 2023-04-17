import QtQuick 2.13
import SortFilterProxyModel 0.2

import shared.status 1.0
import StatusQ.Controls 0.1
import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import utils 1.0

import "../../stores"
import "../../controls"

Item {
    id: root
    signal goBack

    property WalletStore walletStore

    Column {
        id: column
        anchors.top: parent.top
        anchors.left: parent.left
        width: parent.width

        Repeater {
            id: layer1List
            model: SortFilterProxyModel {
                sourceModel: walletStore.networks
                filters: ValueFilter {
                    roleName: "layer"
                    value: 1
                }
            }
            delegate: WalletNetworkDelegate {
                network: model
            }
        }

        StatusSectionHeadline {
            leftPadding: Style.current.padding
            rightPadding: Style.current.padding
            text: qsTr("Layer 2")
            topPadding: Style.current.bigPadding
            bottomPadding: Style.current.padding
        }

        Repeater {
            id: layer2List
            model: SortFilterProxyModel {
                sourceModel: walletStore.networks
                filters: ValueFilter {
                    roleName: "layer"
                    value: 2
                }
            }
            delegate: WalletNetworkDelegate {
                network: model
            }
        }
    }
}
