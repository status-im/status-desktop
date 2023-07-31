import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13

import SortFilterProxyModel 0.2

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Core.Utils 0.1
import StatusQ.Controls 0.1
import StatusQ.Components 0.1
import StatusQ.Core.Backpressure 1.0

import shared.controls 1.0
import utils 1.0

import "../controls"

Item {
    id: root

    property var assets
    property var selectedAsset
    property string defaultToken
    property string currentCurrencySymbol
    property string placeholderText
    property var hoveredToken

    property var tokenAssetSourceFn: function (symbol) {
        return ""
    }
    property var searchTokenSymbolByAddressFn: function (address) {
        return ""
    }
    property var getNetworkIcon: function(chainId){
        return ""
    }

    function resetInternal() {
        assets = null
        selectedAsset = null
    }

    implicitWidth: comboBox.width
    implicitHeight: comboBox.implicitHeight

    onSelectedAssetChanged: {
        if (selectedAsset && selectedAsset.symbol) {
            d.iconSource = tokenAssetSourceFn(selectedAsset.symbol)
            d.text = selectedAsset.symbol
        }
    }

    onHoveredTokenChanged: {
        if (hoveredToken && hoveredToken.symbol) {
            d.iconSource = tokenAssetSourceFn(hoveredToken.symbol)
            d.text = hoveredToken.symbol
        }
    }

    QtObject {
        id: d
        property string iconSource: ""
        property string text: ""
        property string searchString
        readonly property bool isTokenSelected: !!root.selectedAsset || !!root.hoveredToken

        readonly property var updateSearchText: Backpressure.debounce(root, 1000, function(inputText) {
            d.searchString = inputText
        })
    }

    StatusComboBox {
        id: comboBox
        objectName: "assetSelectorButton"

        control.padding: 4
        control.popup.width: 492
        control.popup.x: -root.x
        control.popup.verticalPadding: 0

        popupContentItemObjectName: "assetSelectorList"

        model : SortFilterProxyModel {
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

        control.background: Rectangle {
            color: "transparent"
            border.width: d.isTokenSelected ? 0 : 1
            border.color: d.isTokenSelected ? "transparent" : Theme.palette.directColor7
            radius: 12
        }

        contentItem: RowLayout {
            id: rowLayout
            StatusRoundedImage {
                Layout.preferredWidth: 21
                Layout.preferredHeight: 21
                Layout.alignment: Qt.AlignVCenter | Qt.AlignLeft
                visible: !!d.iconSource
                image.source: d.iconSource
                image.onStatusChanged: {
                    if (image.status === Image.Error) {
                        image.source = defaultToken
                    }
                }
            }
            StatusBaseText {
                Layout.alignment: Qt.AlignVCenter
                font.pixelSize: 28
                elide: Text.ElideRight
                verticalAlignment: Text.AlignVCenter
                color: Theme.palette.miscColor1
                text: d.text
                visible: d.isTokenSelected
            }
            StatusIcon {
                Layout.leftMargin: -3
                Layout.alignment: Qt.AlignVCenter
                Layout.preferredWidth: 16
                Layout.preferredHeight: 16
                icon: "chevron-down"
                color: Theme.palette.miscColor1
                visible: d.isTokenSelected
            }
            StatusBaseText {
                Layout.alignment: Qt.AlignCenter
                visible: !d.isTokenSelected
                font.pixelSize: 15
                font.weight: Font.Medium
                verticalAlignment: Text.AlignVCenter
                color: Theme.palette.baseColor1
                elide: Qt.ElideRight
                text: placeholderText
            }
        }

        control.indicator: null

        delegate: TokenBalancePerChainDelegate {
            objectName: "AssetSelector_ItemDelegate_" + symbol
            width: comboBox.control.popup.width
            getNetworkIcon: root.getNetworkIcon
            onTokenSelected: {
                selectedAsset = selectedToken
                comboBox.control.popup.close()
            }
        }

        Component.onCompleted: {
            control.currentIndex = -1
            control.popup.contentItem.header = searchBox
        }

        control.popup.onOpened: {
            control.currentIndex = -1
        }
    }

    Component {
        id: searchBox
        StatusInput {
            width: parent.width
            input.showBackground: false
            placeholderText: qsTr("Search for token or enter token address")
            onTextChanged: Qt.callLater(d.updateSearchText, text)
            input.clearable: true
            input.implicitHeight: 56
            input.rightComponent: StatusFlatRoundButton {
                icon.name: "search"
                type: StatusFlatRoundButton.Type.Secondary
                enabled: false
            }
            Rectangle {
                anchors.bottom: parent.bottom
                height: 1
                width: parent.width
                color: Theme.palette.baseColor2
            }
        }
    }
}
