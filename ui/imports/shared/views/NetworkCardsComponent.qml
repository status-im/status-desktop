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
    id: root

    property var store
    property var bestRoutes
    property var selectedAccount
    property var selectedAsset
    property var allNetworks
    property bool customMode: false
    property double amountToSend: 0
    property double requiredGasInEth: 0
    property bool errorMode: {
        if(customMode) {
            return (d.customAmountToSend > amountToSend) || (d.customAmountToSend < amountToSend) ||
                    (d.customAmountToReceive > amountToSend) || (d.customAmountToReceive < amountToSend)
        }
        else {
            return  !d.thereIsApossibleRoute
        }
    }
    property bool interactive: true
    property var weiToEth: function(wei) {}

    property var reCalculateSuggestedRoute: function() {}

    QtObject {
        id: d
        property double customAmountToSend: 0
        property double customAmountToReceive: 0
        property bool thereIsApossibleRoute: false

        function resetAllSetValues() {
            for(var i = 0; i<fromNetworksRepeater.count; i++) {
                fromNetworksRepeater.itemAt(i).amountToSend = 0
                fromNetworksRepeater.itemAt(i).routeOnNetwork = 0
                toNetworksRepeater.itemAt(i).amountToReceive = 0
                toNetworksRepeater.itemAt(i).routeOnNetwork = 0
            }
        }
    }

    width: 410
    height: visible ? networkCardsLayout.height : 0

    onBestRoutesChanged: {
        canvas.clear()
        canvas.requestPaint()
    }

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
                id: fromNetworksRepeater
                model: root.allNetworks
                StatusCard {
                    id: fromNetwork
                    objectName: model.chainId
                    property double amountToSend: 0
                    property int routeOnNetwork: 0
                    property string tokenBalanceOnChain: selectedAccount && selectedAccount!== undefined && selectedAsset!== undefined ? selectedAccount.getTokenBalanceOnChain(model.chainId, selectedAsset.symbol) : ""
                    property var hasGas: selectedAccount.hasGas(model.chainId, model.nativeCurrencySymbol, requiredGasInEth)
                    primaryText: model.chainName
                    secondaryText: (parseFloat(tokenBalanceOnChain) === 0 && root.amountToSend !== 0) ?
                                       qsTr("No Balance") : !hasGas ? qsTr("No Gas") : LocaleUtils.numberToLocaleString(fromNetwork.amountToSend)
                    tertiaryText: qsTr("BALANCE: ") + LocaleUtils.numberToLocaleString(parseFloat(tokenBalanceOnChain))
                    state: tokenBalanceOnChain === 0 || !hasGas ? "unavailable" : root.errorMode ? "error" : "default"
                    cardIcon.source: Style.svg(model.iconUrl)
                    disabledText: qsTr("Disabled")
                    advancedMode: root.customMode
                    advancedInputText: LocaleUtils.numberToLocaleString(fromNetwork.amountToSend)
                    disabled: store.disabledChainIdsFromList.includes(model.chainId)
                    clickable: root.interactive
                    onClicked: {
                        store.addRemoveDisabledFromChain(model.chainId, disabled)
                        // only recalculate if the a best route was disabled
                        if(root.bestRoutes.length === 0 || routeOnNetwork !== 0 || !disabled)
                            root.reCalculateSuggestedRoute()
                    }
                    onVisibleChanged: {
                        if(visible)
                            disabled = store.disabledChainIdsFromList.includes(model.chainId)
                    }
                    // To-do needed for custom view
//                    onAdvancedInputTextChanged: {
//                        if(selectedNetwork && selectedNetwork.chainName === model.chainName) {
//                            d.customAmountToSend = isNaN(parseFloat(advancedInputText)) ? 0 : parseFloat(advancedInputText)
//                        }
//                    }
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
                id: toNetworksRepeater
                model: root.allNetworks
                StatusCard {
                    id: toCard
                    objectName: model.chainId
                    property int routeOnNetwork: 0
                    property double amountToReceive: 0
                    primaryText: model.chainName
                    secondaryText: LocaleUtils.numberToLocaleString(amountToReceive)
                    tertiaryText: ""
                    // To-do preferred in not something that is supported yet
                    state: root.errorMode ? "error" : "default"
                    // opacity: preferred ? 1 : 0
                    cardIcon.source: Style.svg(model.iconUrl)
                    disabledText: qsTr("Disabled")
                    advancedMode: root.customMode
                    advancedInputText: LocaleUtils.numberToLocaleString(amountToReceive)
                    disabled: store.disabledChainIdsToList.includes(model.chainId)
                    clickable: root.interactive
                    onClicked: {
                        store.addRemoveDisabledToChain(model.chainId, disabled)
                        // only recalculate if the a best route was disabled
                        if(root.bestRoutes.length === 0 || routeOnNetwork !== 0 || !disabled)
                            root.reCalculateSuggestedRoute()
                    }
                    onVisibleChanged: {
                        if(visible)
                            disabled = store.disabledChainIdsToList.includes(model.chainId)
                    }
                    // To-do needed for custom view
//                    onAdvancedInputTextChanged: {
//                        if(selectedNetwork && selectedNetwork.chainName === model.chainName)
//                            d.customAmountToReceive = isNaN(parseFloat(advancedInputText)) ? 0 : parseFloat(advancedInputText)
//                    }
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
            d.resetAllSetValues()
            d.thereIsApossibleRoute = false

            if(bestRoutes === undefined)
                return

            // in case you are drwaing multiple routes we need an offset so that the lines dont overlap
            let yOffsetFrom = 0
            let yOffsetTo = 0
            let xOffset = 0

            // Get the canvas context
            var ctx = getContext("2d");
            for(var i = 0; i< bestRoutes.length; i++) {
                var fromN, toN = null
                for(var j = 0; j<fromNetworksRepeater.count; j++) {
                    if(bestRoutes[i].fromNetwork.chainId === parseInt(fromNetworksRepeater.itemAt(j).objectName) &&
                            !store.disabledChainIdsFromList.includes(bestRoutes[i].fromNetwork.chainId)) {
                        fromN = fromNetworksRepeater.itemAt(j)
                    }
                }
                for(var k = 0; k<toNetworksRepeater.count; k++) {
                    if(bestRoutes[i].toNetwork.chainId === parseInt(toNetworksRepeater.itemAt(k).objectName) &&
                            !store.disabledChainIdsToList.includes(bestRoutes[i].toNetwork.chainId)) {
                        toN = toNetworksRepeater.itemAt(k)
                    }
                }
                if(toN !== null && fromN !== null) {
                    yOffsetFrom = toN.objectName === fromN.objectName  && toN.routeOnNetwork !== 0 ? toN.routeOnNetwork * 10 : 0
                    yOffsetTo = toN.routeOnNetwork * 10
                    xOffset = toN.routeOnNetwork * 10
                    let amountToSend = weiToEth(bestRoutes[i].amountIn)
                    let amountToReceive = weiToEth(bestRoutes[i].amountOut)
                    fromN.amountToSend = amountToSend
                    toN.amountToReceive += amountToReceive
                    fromN.routeOnNetwork += 1
                    toN.routeOnNetwork += 1
                    d.thereIsApossibleRoute = true
                    StatusQUtils.Utils.drawArrow(ctx, fromN.x + fromN.width,
                                                 fromN.y + fromN.cardIconPosition + yOffsetFrom,
                                                 toNetworksLayout.x + toN.x,
                                                 toN.y + toN.cardIconPosition + yOffsetTo,
                                                 '#627EEA', xOffset)
                }
            }
        }
    }
}
