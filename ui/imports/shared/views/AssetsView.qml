import QtQuick 2.13
import QtQuick.Controls 2.14

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
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
            readonly property string balance: enabledNetworkBalance // Needed for the tests
            objectName: "AssetView_TokenListItem_" + symbol
            width: ListView.view.width
            title: name
            subTitle: `${enabledNetworkBalance} ${symbol}`
            asset.name: symbol ? Style.png("tokens/" + symbol) : ""
            asset.isImage: true
            components: [
                Column {
                    id: valueColumn
                    property string textColor: Math.sign(Number(changePct24hour)) === 0 ? Theme.palette.baseColor1 :
                                               Math.sign(Number(changePct24hour)) === -1 ? Theme.palette.dangerColor1 :
                                                                                           Theme.palette.successColor1
                    StatusBaseText {
                        anchors.right: parent.right
                        font.pixelSize: 15
                        font.strikeout: false
                        text: enabledNetworkCurrencyBalance.toLocaleCurrencyString(Qt.locale(), RootStore.currencyStore.currentCurrencySymbol)
                    }
                    Row {
                        anchors.horizontalCenter: parent.horizontalCenter
                        spacing: 8
                        StatusBaseText {
                            id: change24HourText
                            font.pixelSize: 15
                            font.strikeout: false
                            color: valueColumn.textColor
                            text: currencyPrice.toLocaleCurrencyString(Qt.locale(), RootStore.currencyStore.currentCurrencySymbol)
                        }
                        Rectangle {
                            width: 1
                            height: change24HourText.implicitHeight
                            color: Theme.palette.directColor9
                        }
                        StatusBaseText {
                            font.pixelSize: 15
                            font.strikeout: false
                            color: valueColumn.textColor
                            text: changePct24hour !== "" ? "%1%".arg(changePct24hour) : "---"
                        }
                    }
                }
            ]
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

        ScrollBar.vertical: ScrollBar { policy: ScrollBar.AsNeeded }
    }
}
