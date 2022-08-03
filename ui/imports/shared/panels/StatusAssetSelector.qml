import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Core.Utils 0.1
import StatusQ.Controls 0.1
import StatusQ.Components 0.1

Item {
    id: root

    property var assets
    property var selectedAsset
    property string defaultToken: ""
    property string userSelectedToken: ""
    property var tokenAssetSourceFn: function (symbol) {
        return ""
    }

    // Define this in the usage to get balance in currency selected by user
    property var getCurrencyBalanceString: function (currencyBalance) { return "" }

    function resetInternal() {
        assets = null
        selectedAsset = null
    }

    implicitWidth: 106
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
    }

    StatusComboBox {
        id: comboBox

        width: parent.width
        height: parent.height

        control.padding: 4
        control.popup.width: 342
        control.popup.x: width - control.popup.width

        model: root.assets

        control.background: Rectangle {
            color: comboBox.control.hovered ? Theme.palette.directColor8 : "transparent"
            radius: 6
        }

        contentItem: RowLayout {
            spacing: 4

            StatusRoundedImage {
                Layout.preferredWidth: 24
                Layout.preferredHeight: 24
                Layout.alignment: Qt.AlignVCenter
                image.source: d.iconSource
                image.onStatusChanged: {
                    if (image.status === Image.Error) {
                        image.source = defaultToken
                    }
                }
            }
            StatusBaseText {
                font.pixelSize: 15
                Layout.maximumWidth: 50
                Layout.alignment: Qt.AlignVCenter
                elide: Text.ElideRight
                verticalAlignment: Text.AlignVCenter
                color: Theme.palette.directColor1
                text: d.text
            }
        }

        delegate: StatusItemDelegate {
            width: comboBox.control.popup.width
            highlighted: index === comboBox.control.highlightedIndex
            padding: 16

            onClicked: {
                // TODO: move this out of StatusQ, this involves dependency on BE code
                // WARNING: Wrong ComboBox value processing. Check `StatusAccountSelector` for more info.
                root.userSelectedToken = symbol
                root.selectedAsset = {name: name, symbol: symbol, totalBalance: totalBalance, totalCurrencyBalance: totalCurrencyBalance, balances: balances}
            }

            // TODO: move this out of StatusQ, this involves dependency on BE code
            // WARNING: Wrong ComboBox value processing. Check `StatusAccountSelector` for more info.
            Component.onCompleted: {
                if ((userSelectedToken === "" && index === 0) || symbol === userSelectedToken)
                    root.selectedAsset = { name: name, symbol: symbol, totalBalance: totalBalance, totalCurrencyBalance: totalCurrencyBalance, balances: balances}
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
    }
}
