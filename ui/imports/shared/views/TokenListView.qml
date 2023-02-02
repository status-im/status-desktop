import QtQuick 2.13
import QtQuick.Layouts 1.14

import SortFilterProxyModel 0.2

import StatusQ.Controls 0.1
import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Components 0.1

import utils 1.0

import "../controls"

Item {
    id: root

    property var assets: []
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

    implicitWidth: contentLayout.implicitWidth
    implicitHeight: contentLayout.implicitHeight

    ColumnLayout {
        id: contentLayout

        anchors.fill: parent

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: headerColumn.height

            color: Theme.palette.indirectColor1
            radius: 8

            Column {
                id: headerColumn

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

        StatusListView {
            id: tokenList

            Layout.fillWidth: true
            Layout.preferredHeight: 396

            model: SortFilterProxyModel {
                sourceModel: root.assets
                filters: [
                    ExpressionFilter {
                        expression: {
                            var tokenSymbolByAddress = searchTokenSymbolByAddressFn(d.searchString)
                            tokenList.positionViewAtBeginning()
                            return visibleForNetwork && (
                                symbol.startsWith(d.searchString.toUpperCase()) || name.toUpperCase().startsWith(d.searchString.toUpperCase()) || (tokenSymbolByAddress!=="" && symbol.startsWith(tokenSymbolByAddress))
                            )
                        }
                    }
                ]
            }
            delegate: TokenBalancePerChainDelegate {
                width: ListView.view.width
                getNetworkIcon: root.getNetworkIcon
                onTokenSelected: root.tokenSelected(selectedToken)
            }
        }
    }
}
