import QtQuick 2.13

import SortFilterProxyModel 0.2

import StatusQ.Controls 0.1
import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Components 0.1

import utils 1.0

import "../controls"

Rectangle {
    id: root

    property var assets: []
    property string currentCurrencySymbol
    signal tokenSelected(var selectedToken)
    property var searchTokenSymbolByAddressFn: function (address) {
        return ""
    }
    property var getNetworkIcon: function(chainId){}

    QtObject {
        id: d
        property string searchString
        readonly property var updateSearchText: Backpressure.debounce(root, 1000, function(inputText) {
            d.searchString = inputText
        })
    }

    height: visible ? tokenList.height: 0
    color: Theme.palette.indirectColor1
    radius: 8

    StatusListView {
        id: tokenList
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        width: parent.width
        height: Math.min(433, tokenList.contentHeight)

        model: SortFilterProxyModel {
            sourceModel: root.assets
            filters: [
                ExpressionFilter {
                    expression: {
                        var tokenSymbolByAddress = searchTokenSymbolByAddressFn(d.searchString)
                        return visibleForNetwork && (
                            symbol.startsWith(d.searchString.toUpperCase()) || name.toUpperCase().startsWith(d.searchString.toUpperCase()) || (tokenSymbolByAddress!=="" && symbol.startsWith(tokenSymbolByAddress))
                        )
                    }
                }
            ]
        }
        delegate: TokenBalancePerChainDelegate {
            width: ListView.view.width
            currentCurrencySymbol: root.currentCurrencySymbol
            getNetworkIcon: root.getNetworkIcon
            onTokenSelected: root.tokenSelected(selectedToken)
        }
        headerPositioning: ListView.OverlayHeader
        header: Rectangle {
            width: parent.width
            height: childrenRect.height
            color: Theme.palette.indirectColor1
            radius: 8
            z: 2
            Column {
                width: parent.width
                Item {
                    height: 5
                    width: parent.width
                }
                StatusInput {
                    height: 50
                    width: parent.width
                    input.showBackground: false
                    placeholderText: qsTr("Search for token or enter token address")
                    input.rightComponent: StatusIcon {
                        icon: "search"
                        height: 17
                        color: Theme.palette.baseColor1
                    }
                    onTextChanged: Qt.callLater(d.updateSearchText, text)
                }
                Rectangle {
                    height: 1
                    width: parent.width
                    color: Theme.palette.baseColor3
                }
            }
        }
    }
}
