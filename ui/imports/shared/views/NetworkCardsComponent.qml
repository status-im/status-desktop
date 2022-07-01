import QtQuick 2.13
import QtQuick.Layouts 1.13

import utils 1.0

import StatusQ.Controls 0.1
import StatusQ.Popups 0.1
import StatusQ.Components 0.1
import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Core.Utils 0.1 as StatusQUtils

Item {
    id: networkCardsComponent

    property var assets
    property var store
    property string locale: ""
    property var selectedAsset
    property var suggestedRoutes
    property bool customMode: false
    property var selectedNetwork
    property var selectedAccount
    property var allNetworks
    property double amountToSend: 0
    property double requiredGasInEth: 0
    property bool errorMode: (d.customAmountToSend > amountToSend) ||
                             (d.customAmountToSend < amountToSend) ||
                             (d.customAmountToReceive > amountToSend) ||
                             (d.customAmountToReceive < amountToSend)

    signal reCalculateSuggestedRoute(var disabled)

    QtObject {
        id: d
        property var selectedFromNetwork
        property var selectedToNetwork
        property double customAmountToSend: 0
        property double customAmountToReceive: 0

        function getBalance(chainID) {
            for(var i=0; i< selectedAsset.balances.count; i++) {
                if(selectedAsset.balances.rowData(i, "chainId") === chainID.toString()) {
                    return selectedAsset.balances.rowData(i, "balance")
                }
            }
        }

        onSelectedFromNetworkChanged: {
            canvas.clear()
            canvas.requestPaint()
        }

        onSelectedToNetworkChanged: {
            canvas.clear()
            canvas.requestPaint()
        }
    }

    width: 410
    height: networkCardsLayout.height

    RowLayout {
        id: networkCardsLayout
        width: parent.width
        ColumnLayout {
            id: fromNetworksLayout
            Layout.alignment: Qt.AlignLeft | Qt.AlignTop
            spacing: 12
            StatusBaseText {
                font.pixelSize: 10
                color: Theme.palette.baseColor1
                text: qsTr("Your Balances").toUpperCase()
            }
            Repeater {
                model: networkCardsComponent.allNetworks
                StatusCard {
                    id: fromNetwork
                    property var tokenBalanceOnChain: Utils.toLocaleString(parseFloat(d.getBalance(model.chainId)).toFixed(4), locale, {"currency": true})
                    property var hasGas: assets.hasGas(model.chainId, model.nativeCurrencySymbol, requiredGasInEth + parseFloat(amountToSend))
                    primaryText: model.chainName
                    secondaryText: (parseFloat(tokenBalanceOnChain) === 0 && amountToSend !== 0) ?
                                   qsTr("No Balance") : !hasGas ? qsTr("No Gas") :
                                   (selectedNetwork && selectedNetwork.chainName === model.chainName) ?
                                   amountToSend: 0
                    tertiaryText: qsTr("BALANCE: ") + tokenBalanceOnChain
                    state: tokenBalanceOnChain === 0 || !hasGas ? "unavailable" : networkCardsComponent.errorMode ? "error" : "default"
                    cardIcon.source: Style.png(model.iconUrl)
                    disabledText: qsTr("Disabled")
                    advancedMode: networkCardsComponent.customMode
                    advancedInputText: (selectedNetwork && selectedNetwork.chainName === model.chainName) ? amountToSend: 0
                    Component.onCompleted: {
                        disabled = store.checkIfDisabledByUser(model.chainId)
                        if(selectedNetwork && selectedNetwork.chainName === model.chainName)
                            d.selectedFromNetwork = this
                    }
                    Connections {
                        target: networkCardsComponent
                        onSelectedNetworkChanged: {
                            if(selectedNetwork.chainName === model.chainName) {
                                d.selectedFromNetwork = fromNetwork
                            }
                        }
                    }
                    onClicked: {
                        store.addRemoveDisabledChain(suggestedRoutes, model.chainId, disabled)
                        reCalculateSuggestedRoute(store.disabledChainIds)
                    }
                    onAdvancedInputTextChanged: {
                        if(selectedNetwork && selectedNetwork.chainName === model.chainName) {
                            d.customAmountToSend = isNaN(parseFloat(advancedInputText)) ? 0 : parseFloat(advancedInputText)
                        }
                    }
                }
            }
        }
        ColumnLayout {
            id: toNetworksLayout
            Layout.alignment: Qt.AlignRight | Qt.AlignTop
            spacing: 12
            StatusBaseText {
                Layout.alignment: Qt.AlignRight
                Layout.maximumWidth: 70
                font.pixelSize: 10
                color: Theme.palette.baseColor1
                text: selectedAccount.address
                elide: Text.ElideMiddle
            }
            Repeater {
                model: networkCardsComponent.allNetworks
                StatusCard {
                    id: toCard
                    primaryText: model.chainName
                    secondaryText: (selectedNetwork && selectedNetwork.chainName === model.chainName) ? amountToSend: 0
                    tertiaryText: ""
                    // To-do preferred in not something that is supported yet
                    state: networkCardsComponent.errorMode ? "error" : "default"
                    // opacity: preferred ? 1 : 0
                    cardIcon.source: Style.png(model.iconUrl)
                    disabledText: qsTr("Disabled")
                    advancedMode: networkCardsComponent.customMode
                    advancedInputText: (selectedNetwork && selectedNetwork.chainName === model.chainName) ? amountToSend: 0
                    Component.onCompleted: {
                        disabled = store.checkIfDisabledByUser(model.chainId)
                        if(selectedNetwork && selectedNetwork.chainName === model.chainName)
                            d.selectedToNetwork = this
                    }
                    Connections {
                        target: networkCardsComponent
                        onSelectedNetworkChanged: {
                            if(selectedNetwork && selectedNetwork.chainName === model.chainName)
                                d.selectedToNetwork = toCard
                        }
                    }
                    onClicked: {
                        store.addRemoveDisabledChain(suggestedRoutes, model.chainId, disabled)
                        reCalculateSuggestedRoute(store.disabledChainIds)
                    }
                    onAdvancedInputTextChanged: {
                        if(selectedNetwork && selectedNetwork.chainName === model.chainName)
                            d.customAmountToReceive = isNaN(parseFloat(advancedInputText)) ? 0 : parseFloat(advancedInputText)
                    }
                }
            }
        }
    }

    Canvas {
        id: canvas
        x: networkCardsLayout.x + fromNetworksLayout.x
        y: networkCardsLayout.y
        width: networkCardsLayout.width
        height: networkCardsLayout.height

        function clear() {
            if(available) {
            var ctx = getContext("2d");
            if(ctx)
                ctx.reset()
            }
        }

        onPaint: {
            if(d.selectedFromNetwork && d.selectedToNetwork) {
                // Get the canvas context
                var ctx = getContext("2d");
                StatusQUtils.Utils.drawArrow(ctx, d.selectedFromNetwork.x + d.selectedFromNetwork.width,
                                             d.selectedFromNetwork.y + d.selectedFromNetwork.height/2,
                                             toNetworksLayout.x + d.selectedToNetwork.x,
                                             d.selectedToNetwork.y + d.selectedToNetwork.height/2,
                                             '#627EEA')
            }
        }
    }
}
