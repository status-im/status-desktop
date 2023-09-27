import QtQuick 2.13
import QtQuick.Layouts 1.13

import utils 1.0

import StatusQ.Controls 0.1
import StatusQ.Popups 0.1
import StatusQ.Components 0.1
import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Core.Utils 0.1 as StatusQUtils

import "../controls"

Item {
    id: root

    property var store
    readonly property var currencyStore: store.currencyStore
    property string receiverIdentityText
    property var selectedAsset
    property bool customMode: false
    property double amountToSend
    property int minSendCryptoDecimals: 0
    property int minReceiveCryptoDecimals: 0
    property bool errorMode: d.customAmountToSend > root.amountToSend
    property bool interactive: true
    property var weiToEth: function(wei) {}
    property var reCalculateSuggestedRoute: function() {}
    property int errorType: Constants.NoError
    property bool isLoading

    QtObject {
        id: d
        property double customAmountToSend: 0
        readonly property string selectedSymbol: !!selectedAsset ? selectedAsset.symbol : ""

        function resetAllSetValues() {
            for(var i = 0; i<fromNetworksRepeater.count; i++) {
                fromNetworksRepeater.itemAt(i).routeOnNetwork = 0
                toNetworksRepeater.itemAt(i).routeOnNetwork = 0
                toNetworksRepeater.itemAt(i).bentLine = 0
            }
        }

        function calculateCustomAmounts() {
            d.customAmountToSend = 0
            for(var i = 0; i<fromNetworksRepeater.count; i++) {
                if(fromNetworksRepeater.itemAt(i).locked) {
                    let amountEntered = fromNetworksRepeater.itemAt(i).advancedInputCurrencyAmount
                    d.customAmountToSend += isNaN(amountEntered) ? 0 : amountEntered
                }
            }
        }

        function draw() {
            canvas.clear()
            canvas.requestPaint()
        }
    }

    onVisibleChanged: if(visible) d.draw()
    onErrorModeChanged: if(errorMode) d.draw()

    height: visible ? networkCardsLayout.height : 0

    RowLayout {
        id: networkCardsLayout
        width: parent.width
        ColumnLayout {
            id: fromNetworksLayout
            Layout.alignment: Qt.AlignLeft | Qt.AlignTop
            spacing: 12
            StatusBaseText {
                Layout.maximumWidth: 100
                elide: Text.ElideRight
                font.pixelSize: 10
                color: Theme.palette.baseColor1
                text: qsTr("Your Balances").toUpperCase()
            }
            Repeater {
                id: fromNetworksRepeater
                model: store.fromNetworksModel
                StatusCard {
                    id: fromNetwork
                    locale: LocaleUtils.userInputLocale
                    objectName: model.chainId
                    property double advancedInputCurrencyAmount: selectedAsset !== undefined && advancedInput.valid ? LocaleUtils.numberFromLocaleString(advancedInput.text, LocaleUtils.userInputLocale) : 0.0
                    property var tokenBalance: model.tokenBalance
                    onTokenBalanceChanged: maxAdvancedValue = model.tokenBalance.amount
                    property var toNetworks: model.toNetworks
                    property int routeOnNetwork: 0
                    onToNetworksChanged: d.draw()

                    primaryText: model.chainName
                    secondaryText: (model.tokenBalance.amount === 0 && root.amountToSend > 0) ?
                                    qsTr("No Balance") : !model.hasGas ? qsTr("No Gas") : root.currencyStore.formatCurrencyAmount(advancedInputCurrencyAmount, d.selectedSymbol, {"minDecimals": root.minSendCryptoDecimals})
                    tertiaryText: root.errorMode && advancedInputCurrencyAmount > 0 ? qsTr("EXCEEDS SEND AMOUNT"): qsTr("BALANCE: ") + root.currencyStore.formatCurrencyAmount(model.tokenBalance.amount, d.selectedSymbol)
                    locked: model.locked
                    preCalculatedAdvancedText: {
                        if(locked && model.lockedAmount) {
                            let amount = root.weiToEth(parseInt(model.lockedAmount, 16))
                            return LocaleUtils.numberToLocaleString(amount, -1, LocaleUtils.userInputLocale)
                        }
                        else return LocaleUtils.numberToLocaleString(root.weiToEth(model.amountIn), -1, LocaleUtils.userInputLocale)
                    }
                    maxAdvancedValue: tokenBalance.amount
                    state: (model.tokenBalance.amount === 0 && root.amountToSend > 0) || !model.hasGas ? "unavailable" :
                           (root.errorMode || !advancedInput.valid) && advancedInputCurrencyAmount > 0 ? "error" : "default"
                    cardIcon.source: Style.svg(model.iconUrl)
                    disabledText: qsTr("Disabled")
                    disableText: qsTr("Disable")
                    enableText: qsTr("Enable")
                    advancedMode: root.customMode
                    disabled: !model.isEnabled
                    clickable: root.interactive
                    onClicked: {
                        store.toggleFromDisabledChains(model.chainId)
                        root.reCalculateSuggestedRoute()
                    }
                    onLockCard: {
                        let amount = lock ? (advancedInputCurrencyAmount * Math.pow(10, root.selectedAsset.decimals)).toString(16) : ""
                        store.lockCard(model.chainId, amount, lock)
                        d.calculateCustomAmounts()
                        root.reCalculateSuggestedRoute()
                    }
                }
            }
        }
        BalanceExceeded {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter
            errorType: root.errorType
            visible: root.errorType === Constants.NoRoute
        }
        ColumnLayout {
            id: toNetworksLayout
            Layout.alignment: Qt.AlignRight | Qt.AlignTop
            spacing: 12

            RowLayout {
                Layout.alignment: Qt.AlignRight | Qt.AlignTop
                Layout.maximumWidth: 160

                StatusBaseText {
                    id: receiverIdentityText

                    text: root.receiverIdentityText
                    Layout.fillWidth: true

                    font.pixelSize: 10
                    color: Theme.palette.baseColor1
                    elide: Text.ElideMiddle
                    horizontalAlignment: Text.AlignRight
                }
                StatusBaseText {
                    font.pixelSize: receiverIdentityText.font.pixelSize
                    color: receiverIdentityText.color
                    text: qsTr("WILL RECEIVE")
                }
            }

            Repeater {
                id: toNetworksRepeater
                model: store.toNetworksModel
                StatusCard {
                    id: toCard
                    locale: LocaleUtils.userInputLocale
                    objectName: model.chainId
                    property bool preferred: model.isPreferred
                    property int bentLine: 0
                    property int routeOnNetwork: 0
                    primaryText: model.chainName
                    secondaryText: root.currencyStore.formatCurrencyAmount(root.weiToEth(model.amountOut), d.selectedSymbol, {"minDecimals": root.minReceiveCryptoDecimals})
                    tertiaryText: state === "unpreferred"  ? qsTr("UNPREFERRED") : ""
                    state: !preferred ? "unpreferred" : "default"
                    opacity: preferred || store.showUnPreferredChains ? 1 : 0
                    cardIcon.source: Style.svg(model.iconUrl)
                    disabledText: qsTr("Disabled")
                    disableText:  qsTr("Disable")
                    enableText: qsTr("Enable")
                    disabled: !model.isEnabled
                    clickable: root.interactive
                    loading: root.isLoading
                    onClicked: {
                        store.toggleToDisabledChains(model.chainId)
                        root.reCalculateSuggestedRoute()
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
            d.resetAllSetValues()

            // in case you are drawing multiple routes we need an offset so that the lines dont overlap
            let yOffsetFrom = 0
            let yOffsetTo = 0
            let xOffset = 0

            // Get the canvas context
            var ctx = getContext("2d");
            for(var j = 0; j<fromNetworksRepeater.count; j++) {
                var fromN, toN = null
                fromN = fromNetworksRepeater.itemAt(j)
                const toNetworks = fromN.toNetworks.split(":")
                for(var i = 0; i<toNetworks.length; i++) {
                    for(var k = 0; k<toNetworksRepeater.count; k++) {
                        if(toNetworks[i] === toNetworksRepeater.itemAt(k).objectName && !toNetworksRepeater.itemAt(k).disabled) {
                            toN = toNetworksRepeater.itemAt(k)
                            yOffsetFrom = toN.objectName === fromN.objectName  && toN.routeOnNetwork !== 0 ? toN.routeOnNetwork * 16 : 0
                            yOffsetTo = toN.routeOnNetwork * 16
                            xOffset = (fromN.y - toN.y > 0 ? -1 : 1) * toN.bentLine * 16
                            fromN.routeOnNetwork += 1
                            toN.routeOnNetwork += 1
                            toN.bentLine = toN.objectName !== fromN.objectName
                            let routeColor = root.errorMode ? Theme.palette.dangerColor1 : toN.preferred ? '#627EEA' : Theme.palette.pinColor1
                            StatusQUtils.Utils.drawArrow(ctx, fromN.x + fromN.width,
                                                         fromN.y + fromN.cardIconPosition + yOffsetFrom,
                                                         toNetworksLayout.x + toN.x,
                                                         toNetworksLayout.y + toN.y + toN.cardIconPosition + yOffsetTo,
                                                         routeColor, xOffset)
                            break
                        }
                    }
                }
            }
            d.calculateCustomAmounts()
        }
    }
}
