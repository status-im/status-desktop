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

    property var assets: null
    signal tokenSelected(string symbol)
    signal tokenHovered(string symbol, bool hovered)
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
        spacing: 8

        StatusBaseText {
            id: label
            elide: Text.ElideRight
            text: qsTr("Token to send")
            font.pixelSize: 13
            color: Theme.palette.directColor1
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: tokenList.height

            color: Theme.palette.indirectColor1
            radius: 8

            StatusListView {
                id: tokenList

                width: parent.width
                height: tokenList.contentHeight

                header: SearchBoxWithRightIcon {
                    width: parent.width
                    placeholderText: qsTr("Search for token or enter token address")
                    onTextChanged: Qt.callLater(d.updateSearchText, text)
                }

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
                    onTokenSelected: root.tokenSelected(symbol)
                    onTokenHovered: root.tokenHovered(symbol, hovered)
                }
            }
        }
    }
}
