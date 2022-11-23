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

Item {
    id: root

    property var assets
    property var selectedAsset
    property string defaultToken: ""
    property string userSelectedToken: ""
    property var tokenAssetSourceFn: function (symbol) {
        return ""
    }
    property var searchTokenSymbolByAddressFn: function (address) {
        return ""
    }

    // Define this in the usage to get balance in currency selected by user
    property var getCurrencyBalanceString: function (currencyBalance) { return "" }
    property string placeholderText

    function resetInternal() {
        assets = null
        selectedAsset = null
    }

    implicitWidth: comboBox.width
    implicitHeight: comboBox.implicitHeight

    onSelectedAssetChanged: {
        if (selectedAsset && selectedAsset.symbol) {
            d.iconSource = tokenAssetSourceFn(selectedAsset.symbol.toUpperCase())
            d.text = selectedAsset.symbol.toUpperCase()
        }
    }

    QtObject {
        id: d
        property string iconSource: ""
        property string text: ""
        property string searchString

        readonly property var updateSearchText: Backpressure.debounce(root, 1000, function(inputText) {
            d.searchString = inputText
        })
    }

    StatusComboBox {
        id: comboBox
        objectName: "assetSelectorButton"
        width: control.width
        height: parent.height

        control.padding: 4
        control.popup.width: 342
        control.popup.height: 416
        control.popup.x: width - control.popup.width
        
        popupContentItemObjectName: "assetSelectorList"

        model : SortFilterProxyModel {
            sourceModel: root.assets
            filters: [
                ExpressionFilter {
                    expression: {
                        var tokenSymbolByAddress = searchTokenSymbolByAddressFn(d.searchString)
                        return symbol.startsWith(d.searchString.toUpperCase()) || name.toUpperCase().startsWith(d.searchString.toUpperCase()) || (tokenSymbolByAddress!=="" && symbol.startsWith(tokenSymbolByAddress))
                    }
                }
            ]
        }

        control.background: Rectangle {
            color: "transparent"
            border.width: 1
            border.color: comboBox.control.hovered ? Theme.palette.primaryColor2 : Theme.palette.directColor8
            radius: 16
            width: rowLayout.width
            implicitHeight: 48
        }

        contentItem: RowLayout {
            id: rowLayout
            spacing: 8
            StatusBaseText {
                Layout.leftMargin: 8
                Layout.alignment: Qt.AlignVCenter
                font.pixelSize: 15
                elide: Text.ElideRight
                verticalAlignment: Text.AlignVCenter
                color: !!root.selectedAsset ? Theme.palette.directColor1: Theme.palette.baseColor1
                font.weight: Font.Medium
                text: !!root.selectedAsset ? d.text : placeholderText
            }
            StatusRoundedImage {
                Layout.preferredWidth: 40
                Layout.preferredHeight: 40
                Layout.alignment: Qt.AlignVCenter
                visible: !!d.iconSource
                image.source: d.iconSource
                image.onStatusChanged: {
                    if (image.status === Image.Error) {
                        image.source = defaultToken
                    }
                }
            }
            Item {
                width: 8
                height: 0
            }
        }

        control.indicator: null

        delegate: StatusItemDelegate {
            width: comboBox.control.popup.width
            highlighted: index === comboBox.control.highlightedIndex
            padding: 16
            objectName: "AssetSelector_ItemDelegate_" + symbol
            onClicked: {
                // WARNING: Wrong ComboBox value processing. Check `StatusAccountSelector` for more info.
                root.userSelectedToken = symbol
                root.selectedAsset = {name: name, symbol: symbol, totalBalance: totalBalance, totalCurrencyBalance: totalCurrencyBalance, balances: balances, decimals: decimals}
            }

            // WARNING: Wrong ComboBox value processing. Check `StatusAccountSelector` for more info.
            Component.onCompleted: {
                if (symbol === userSelectedToken)
                    root.selectedAsset = { name: name, symbol: symbol, totalBalance: totalBalance, totalCurrencyBalance: totalCurrencyBalance, balances: balances, decimals: decimals}
            }

            contentItem: RowLayout {
                spacing: 0

                StatusRoundedImage {
                    image.source: root.tokenAssetSourceFn(symbol.toUpperCase())
                    image.onStatusChanged: {
                        if (image.status === Image.Error) {
                            image.source = defaultToken
                        }
                    }
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.leftMargin: 12
                    spacing: 0

                    RowLayout {
                        Layout.fillWidth: true

                        StatusBaseText {
                            Layout.fillWidth: true
                            text: symbol.toUpperCase()
                            font.pixelSize: 15
                            color: Theme.palette.directColor1
                        }
                        StatusBaseText {
                            Layout.fillWidth: true
                            horizontalAlignment: Text.AlignRight
                            font.pixelSize: 15
                            text: parseFloat(totalBalance).toLocaleCurrencyString(Qt.locale(), symbol)
                        }
                    }
                    RowLayout {
                        Layout.fillWidth: true
                        StatusBaseText {
                            Layout.fillWidth: true
                            elide: Text.ElideRight
                            text: name
                            color: Theme.palette.baseColor1
                            font.pixelSize: 15
                        }
                        StatusBaseText {
                            Layout.fillWidth: true
                            horizontalAlignment: Text.AlignRight
                            font.pixelSize: 15
                            text: getCurrencyBalanceString(totalCurrencyBalance)
                            color: Theme.palette.baseColor1
                        }
                    }
                }
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
            leftPadding: 0
            rightPadding: 0
            input.rightComponent: StatusIcon {
                width: 24
                height: 24
                color: Theme.palette.baseColor1
                icon: "search"
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
