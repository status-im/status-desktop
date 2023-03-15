import QtQuick 2.13
import QtQuick.Controls 2.14

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1
import StatusQ.Components 0.1

import SortFilterProxyModel 0.2

import utils 1.0

import "../stores"
import shared.controls 1.0

Item {
    id: root

    property var account
    property var networkConnectionStore
    property bool assetDetailsLaunched: false

    signal assetClicked(var token)

    QtObject {
        id: d
        property int selectedAssetIndex: -1
    }

    height: assetListView.height

    StatusListView {
        id: assetListView
        objectName: "assetViewStatusListView"
        anchors.fill: parent
        // To-do: will try to move the loading tokens to the nim side under this task https://github.com/status-im/status-desktop/issues/9648
        model: RootStore.tokensLoading || networkConnectionStore.noBlockchainConnWithoutCache ? Constants.dummyModelItems : filteredModel
        delegate: RootStore.tokensLoading || networkConnectionStore.noBlockchainConnWithoutCache ? loadingTokenDelegate : tokenDelegate
    }

    SortFilterProxyModel {
        id: filteredModel
        sourceModel: account.assets
        filters: [
            ExpressionFilter {
                expression: visibleForNetworkWithPositiveBalance
            }
        ]
    }

    Component {
        id: loadingTokenDelegate
        LoadingTokenDelegate {
            width: ListView.view.width
        }
    }

    Component {
        id: tokenDelegate
        TokenDelegate {
            objectName: "AssetView_TokenListItem_" + symbol
            readonly property string balance: "%1".arg(enabledNetworkBalance.amount) // Needed for the tests
            errorTooltipText_1: networkConnectionStore.getBlockchainNetworkDownTextForToken(balances)
            errorTooltipText_2: networkConnectionStore.getMarketNetworkDownText()
            width: ListView.view.width
            onClicked: {
                RootStore.getHistoricalDataForToken(symbol, RootStore.currencyStore.currentCurrency)
                d.selectedAssetIndex = index
                assetClicked(model)
            }
            Component.onCompleted: {
                // on Model reset if the detail view is shown, update the data in background.
                if(root.assetDetailsLaunched && index === d.selectedAssetIndex)
                    assetClicked(model)
            }
        }
    }
}
