import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Shapes 1.15

import StatusQ 0.1
import StatusQ.Components 0.1
import StatusQ.Controls 0.1
import StatusQ.Core 0.1
import StatusQ.Core.Utils 0.1 as SQUtils
import StatusQ.Core.Theme 0.1

import AppLayouts.Wallet 1.0
import AppLayouts.Wallet.controls 1.0
import AppLayouts.Wallet.stores 1.0
import AppLayouts.Wallet.adaptors 1.0

import shared.popups.send.views 1.0

import utils 1.0
import shared.stores 1.0

import SortFilterProxyModel 0.2

Control {
    id: root

    // input API
    required property CurrenciesStore currencyStore
    required property var flatNetworksModel
    required property var processedAssetsModel
    property var plainTokensBySymbolModel // optional all tokens model, no balances

    property int selectedNetworkChainId: -1
    property string selectedAccountAddress
    property string nonInteractiveTokensKey

    property string tokenKey
    onTokenKeyChanged: Qt.callLater(reevaluateSelectedId)

    property string tokenAmount
    onTokenAmountChanged: Qt.callLater(d.updateInputText) // FIXME remove the callLater(), shouldn't be needed now

    property real cryptoFeesToReserve: 0

    property int swapSide: SwapInputPanel.SwapSide.Pay
    property bool fiatInputInteractive
    property bool mainInputLoading
    property bool bottomTextLoading
    property bool interactive: true

    // FIXME drop after using ModelEntry, shouldn't be needed
    function reevaluateSelectedId() {
        const entry = SQUtils.ModelUtils.getByKey(holdingSelector.model, "tokensKey", root.tokenKey)

        if (entry) {
            holdingSelector.currentTokensKey = root.tokenKey
            holdingSelector.setSelection(entry.symbol, entry.iconSource, entry.tokensKey)
        } else {
            holdingSelector.currentTokensKey = ""
            holdingSelector.reset()
        }
    }

    // output API
    readonly property string selectedHoldingId: holdingSelector.currentTokensKey
    readonly property double value: amountToSendInput.asNumber
    readonly property string rawValue: {
        if (!d.isSelectedHoldingValidAsset || !d.selectedHolding.item.marketDetails || !d.selectedHolding.item.marketDetails.currencyPrice) {
            return "0"
        }
        return amountToSendInput.amount
    }
    readonly property int rawValueMultiplierIndex: amountToSendInput.multiplierIndex
    readonly property bool valueValid: value > 0 && amountToSendInput.valid &&
                                       (swapSide === SwapInputPanel.SwapSide.Pay ? !amountEnteredGreaterThanBalance : true)
    readonly property bool amountEnteredGreaterThanBalance: amountToSendInput.balanceExceeded

    // visual properties
    property int swapExchangeButtonWidth: 44
    property string caption: swapSide === SwapInputPanel.SwapSide.Pay ? qsTr("Pay") : qsTr("Receive")

    function forceActiveFocus() {
        amountToSendInput.forceActiveFocus()
    }

    enum SwapSide {
        Pay = 0,
        Receive = 1
    }

    padding: Theme.padding

    // by design
    implicitWidth: 492
    implicitHeight: 131

    QtObject {
        id: d

        readonly property var selectedHolding: ModelEntry {
            sourceModel: holdingSelector.model
            key: "tokensKey"
            value: holdingSelector.currentTokensKey
        }

        readonly property bool isSelectedHoldingValidAsset: selectedHolding.available && !!selectedHolding.item
        readonly property double maxFiatBalance: isSelectedHoldingValidAsset && !!selectedHolding.item.currencyBalance ? selectedHolding.item.currencyBalance : 0
        readonly property double maxCryptoBalance: isSelectedHoldingValidAsset && !!selectedHolding.item.currentBalance ? selectedHolding.item.currentBalance : 0
        readonly property double maxInputBalance: amountToSendInput.fiatMode ? maxFiatBalance : maxCryptoBalance
        readonly property string inputSymbol: amountToSendInput.fiatMode ? root.currencyStore.currentCurrency
                                                                         : (!!isSelectedHoldingValidAsset ? selectedHolding.item.symbol : "")

        readonly property var adaptor: TokenSelectorViewAdaptor {
            assetsModel: root.processedAssetsModel
            plainTokensBySymbolModel: root.plainTokensBySymbolModel
            flatNetworksModel: root.flatNetworksModel
            currentCurrency: root.currencyStore.currentCurrency

            showAllTokens: true
            enabledChainIds: root.selectedNetworkChainId !== -1 ? [root.selectedNetworkChainId] : []
            accountAddress: root.selectedAccountAddress
        }

        function updateInputText() {
            if (!tokenAmount) {
                amountToSendInput.clear()
                return
            }
            let amountToSet = SQUtils.AmountsArithmetic.fromString(tokenAmount).toFixed()
            /* When deleting characters after a decimal point
            eg: 0.000001 being deleted we have 0.00000 and it should not be updated to 0
            and thats why we compare with toFixed()
            also when deleting a numbers last digit, we should not update the text to 0
            instead it should remain empty as entered by the user */
            let currentInputTextAmount = SQUtils.AmountsArithmetic.fromString(amountToSendInput.text.replace(amountToSendInput.locale.decimalPoint,'.')).toFixed()
            if (currentInputTextAmount !== amountToSet &&
                    !(amountToSet === "0" && !amountToSendInput.text)) {
                amountToSendInput.setValue(tokenAmount)
            }
        }
    }

    background: Shape {
        id: shape

        property int radius: Theme.radius
        property int leftTopRadius: radius
        property int rightTopRadius: radius
        property int leftBottomRadius: radius
        property int rightBottomRadius: radius

        readonly property int cutoutGap: 4

        scale: swapSide === SwapInputPanel.SwapSide.Pay ? -1 : 1

        ShapePath {
            id: path
            fillColor: Theme.palette.indirectColor3
            strokeColor: amountToSendInput.cursorVisible ? Theme.palette.directColor7 : Theme.palette.directColor8
            strokeWidth: 1
            capStyle: ShapePath.RoundCap

            startX: shape.leftTopRadius
            startY: 0

            PathLine {
                x: shape.width/2 - root.swapExchangeButtonWidth/2 - (shape.cutoutGap/2 + path.strokeWidth)
                y: 0
            }
            PathArc { // the cutout
                relativeX: root.swapExchangeButtonWidth + (shape.cutoutGap + path.strokeWidth*2)
                direction: PathArc.Counterclockwise
                radiusX: root.swapExchangeButtonWidth/2 + path.strokeWidth
                radiusY: root.swapExchangeButtonWidth/2 - path.strokeWidth/2
            }
            PathLine {
                x: shape.width - shape.rightTopRadius
                y: 0
            }

            PathArc {
                x: shape.width
                y: shape.rightTopRadius
                radiusX: shape.rightTopRadius
                radiusY: shape.rightTopRadius
            }
            PathLine {
                x: shape.width
                y: shape.height - shape.rightBottomRadius
            }
            PathArc {
                x: shape.width - shape.rightBottomRadius
                y: shape.height
                radiusX: shape.rightBottomRadius
                radiusY: shape.rightBottomRadius
            }
            PathLine {
                x: shape.leftBottomRadius
                y: shape.height
            }
            PathArc {
                x: 0
                y: shape.height - shape.leftBottomRadius
                radiusX: shape.leftBottomRadius
                radiusY: shape.leftBottomRadius
            }
            PathLine {
                x: 0
                y: shape.leftTopRadius
            }
            PathArc {
                x: shape.leftTopRadius
                y: 0
                radiusX: shape.leftTopRadius
                radiusY: shape.leftTopRadius
            }
        }
    }

    contentItem: RowLayout {
        spacing: 20
        ColumnLayout {
            Layout.fillHeight: true
            Layout.fillWidth: true

            AmountToSend {
                readonly property bool balanceExceeded:
                    SQUtils.AmountsArithmetic.fromNumber(maxSendButton.maxSafeCryptoValue, multiplierIndex).cmp(amount) === -1

                readonly property double asNumber: {
                    if (!valid)
                        return 0

                    return parseFloat(text.replace(LocaleUtils.userInputLocale.decimalPoint, "."))
                }

                Layout.fillWidth: true
                id: amountToSendInput
                objectName: "amountToSendInput"
                caption: root.caption
                interactive: root.interactive
                markAsInvalid: (root.swapSide === SwapInputPanel.SwapSide.Pay && (balanceExceeded || d.maxInputBalance === 0)) || (!!text && !valid)
                fiatInputInteractive: root.fiatInputInteractive
                multiplierIndex: d.isSelectedHoldingValidAsset && !!d.selectedHolding.item.decimals ? d.selectedHolding.item.decimals : 18
                price: d.isSelectedHoldingValidAsset ? (!!d.isSelectedHoldingValidAsset && !!d.selectedHolding.item.marketDetails ? d.selectedHolding.item.marketDetails.currencyPrice.amount : 1)
                                                     : 1
                formatFiat: amount => root.currencyStore.formatCurrencyAmount(amount, root.currencyStore.currentCurrency)
                formatBalance: amount => root.currencyStore.formatCurrencyAmount(amount, d.inputSymbol)

                mainInputLoading: root.mainInputLoading
                bottomTextLoading: root.bottomTextLoading
            }
        }
        ColumnLayout {

            Item { Layout.fillHeight: true }

            AssetSelector {
                id: holdingSelector

                objectName: "holdingSelector"

                property string currentTokensKey

                Layout.alignment: Qt.AlignRight

                model: d.adaptor.outputAssetsModel
                nonInteractiveKey: root.nonInteractiveTokensKey

                onSelected: currentTokensKey = key
            }

            Item { Layout.fillHeight: !maxSendButton.visible }

            MaxSendButton {
                id: maxSendButton

                Layout.alignment: Qt.AlignRight
                objectName: "maxTagButton"

                readonly property double maxSafeValue: WalletUtils.calculateMaxSafeSendAmount(d.maxInputBalance, d.inputSymbol, root.selectedNetworkChainId, root.cryptoFeesToReserve)
                readonly property double maxSafeCryptoValue: WalletUtils.calculateMaxSafeSendAmount(d.maxCryptoBalance, d.inputSymbol, root.selectedNetworkChainId, root.cryptoFeesToReserve)

                markAsInvalid: amountToSendInput.markAsInvalid

                formattedValue: d.maxInputBalance === 0 ? LocaleUtils.userInputLocale.zeroDigit
                                                        : root.currencyStore.formatCurrencyAmount(
                                                              maxSafeValue, d.inputSymbol,
                                                              { noSymbol: !amountToSendInput.fiatMode,
                                                                roundingMode: LocaleUtils.RoundingMode.Down })

                visible: d.isSelectedHoldingValidAsset && root.swapSide === SwapInputPanel.SwapSide.Pay

                onClicked: {
                    if (maxSafeValue)
                        amountToSendInput.setValue(SQUtils.AmountsArithmetic.fromNumber(maxSafeValue).toString())
                    else
                        amountToSendInput.clear()
                    root.forceActiveFocus()
                }
            }
        }
    }
}
