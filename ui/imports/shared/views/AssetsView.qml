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

    property var assets
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
        model: filteredModel
        delegate: delegateLoader
    }

    SortFilterProxyModel {
        id: filteredModel
        sourceModel: !!assets ? assets : null
        filters: [
            ExpressionFilter {
                expression: visibleForNetworkWithPositiveBalance || loading
            }
        ]
    }

    Component {
        id: delegateLoader
        Loader {
            property var modelData: model
            property int index: index
            width: ListView.view.width
            sourceComponent: loading ? loadingTokenDelegate: tokenDelegate
        }
    }

    Component {
        id: loadingTokenDelegate
        LoadingTokenDelegate {
            objectName: "AssetView_LoadingTokenDelegate_" + index
        }
    }

    Component {
        id: tokenDelegate
        TokenDelegate {
            objectName: "AssetView_TokenListItem_" + (!!modelData ? modelData.symbol : "")
            readonly property string balance: !!modelData ? "%1".arg(modelData.enabledNetworkBalance.amount) : "" // Needed for the tests
            errorTooltipText_1: !!modelData && !! networkConnectionStore ? networkConnectionStore.getBlockchainNetworkDownTextForToken(modelData.balances) : ""
            errorTooltipText_2: !!networkConnectionStore ? networkConnectionStore.getMarketNetworkDownText() : ""
            subTitle: !modelData || (!!networkConnectionStore && !networkConnectionStore.noTokenBalanceAvailable) ? "" :  LocaleUtils.currencyAmountToLocaleString(modelData.enabledNetworkBalance)
            errorMode: !!networkConnectionStore ? networkConnectionStore.noBlockchainConnectionAndNoCache && !networkConnectionStore.noMarketConnectionAndNoCache : false
            errorIcon.tooltip.text: !!networkConnectionStore ? networkConnectionStore.noBlockchainConnectionAndNoCacheText : ""
            onClicked: {
                RootStore.getHistoricalDataForToken(modelData.symbol, RootStore.currencyStore.currentCurrency)
                d.selectedAssetIndex = index
                assetClicked(modelData)
            }
            Component.onCompleted: {
                // on Model reset if the detail view is shown, update the data in background.
                if(root.assetDetailsLaunched && index === d.selectedAssetIndex)
                    assetClicked(modelData)
            }
        }
    }
}
