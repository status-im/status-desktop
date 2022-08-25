import QtQuick 2.13
import QtQuick.Controls 2.14

import StatusQ.Core 0.1
import StatusQ.Controls 0.1
import StatusQ.Components 0.1

import SortFilterProxyModel 0.2

import utils 1.0

import "../stores"

Item {
    id: root

    property var account
    property bool assetDetailsLaunched: false

    signal assetClicked(var token)

    QtObject {
        id: d
        readonly property var alwaysVisible : ["ETH", "SNT", "DAI", "STT"]
        property int selectedAssetIndex: -1
    }

    height: assetListView.height

    StatusListView {
        id: assetListView
        objectName: "assetViewStatusListView"
        anchors.fill: parent
        model: SortFilterProxyModel {
            sourceModel: account.assets
            filters: [
                ExpressionFilter {
                    expression: d.alwaysVisible.includes(symbol) || (networkVisible && enabledNetworkBalance > 0)
                }
            ]
        }
        delegate: StatusListItem {
            readonly property int balance: enabledNetworkBalance // Needed for the tests
            objectName: "AssetView_TokenListItem_" + symbol
            width: parent.width
            title: name
            subTitle: qsTr("%1 %2").arg(Utils.toLocaleString(enabledNetworkBalance, RootStore.locale, {"currency": true})).arg(symbol)
            image.source: symbol ? Style.png("tokens/" + symbol) : ""
            components: [
                StatusBaseText {
                    font.pixelSize: 15
                    font.strikeout: false
                    text: enabledNetworkCurrencyBalance.toLocaleCurrencyString(Qt.locale(), RootStore.currencyStore.currentCurrencySymbol)
                }
            ]
            onClicked: {
                d.selectedAssetIndex = index
                assetClicked(model)
            }
            Component.onCompleted: {
                // on Model reset if the detail view is shown, update the data in background.
                if(root.assetDetailsLaunched && index === d.selectedAssetIndex)
                    assetClicked(model)
            }
        }

        ScrollBar.vertical: ScrollBar { policy: ScrollBar.AsNeeded }
    }
}
