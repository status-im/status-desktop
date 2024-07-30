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
    onTokenAmountChanged: Qt.callLater(d.updateInputText)

    property int swapSide: SwapInputPanel.SwapSide.Pay
    property bool fiatInputInteractive
    property bool mainInputLoading
    property bool bottomTextLoading
    property bool interactive: true

    function reevaluateSelectedId() {
        holdingSelector.selectToken(tokenKey)
        d.selectedHolding = SQUtils.ModelUtils.getByKey(holdingSelector.model, "tokensKey", holdingSelector.currentTokensKey)
    }

    // output API
    readonly property string selectedHoldingId: holdingSelector.currentTokensKey
    readonly property double value: amountToSendInput.cryptoValueToSendFloat
    readonly property string rawValue: amountToSendInput.cryptoValueToSend
    readonly property int rawValueMultiplierIndex: amountToSendInput.multiplierIndex
    readonly property bool valueValid: amountToSendInput.inputNumberValid
    readonly property bool amountEnteredGreaterThanBalance: value > maxSendButton.maxSafeValue

    // visual properties
    property int swapExchangeButtonWidth: 44
    property string caption: swapSide === SwapInputPanel.SwapSide.Pay ? qsTr("Pay") : qsTr("Receive")

    function forceActiveFocus() {
        amountToSendInput.input.forceActiveFocus()
    }

    enum SwapSide {
        Pay = 0,
        Receive = 1
    }

    padding: Style.current.padding

    // by design
    implicitWidth: 492
    implicitHeight: 131

    QtObject {
        id: d

        property var selectedHolding: SQUtils.ModelUtils.getByKey(holdingSelector.model, "tokensKey", holdingSelector.currentTokensKey)

        readonly property bool isSelectedHoldingValidAsset: !!selectedHolding
        readonly property double maxFiatBalance: isSelectedHoldingValidAsset && !!selectedHolding.currencyBalance ? selectedHolding.currencyBalance : 0
        readonly property double maxCryptoBalance: isSelectedHoldingValidAsset && !!selectedHolding.currentBalance ? selectedHolding.currentBalance : 0
        readonly property double maxInputBalance: amountToSendInput.inputIsFiat ? maxFiatBalance : maxCryptoBalance
        readonly property string inputSymbol: amountToSendInput.inputIsFiat ? root.currencyStore.currentCurrency
                                                                            : (!!selectedHolding ? selectedHolding.symbol : "")

        readonly property var adaptor: TokenSelectorViewAdaptor {
            assetsModel: root.processedAssetsModel
            plainTokensBySymbolModel: root.plainTokensBySymbolModel
            flatNetworksModel: root.flatNetworksModel
            currentCurrency: root.currencyStore.currentCurrency

            showAllTokens: true
            enabledChainIds: root.selectedNetworkChainId !== -1 ? [root.selectedNetworkChainId] : []
            accountAddress: root.selectedAccountAddress
            searchString: holdingSelector.searchString
        }

        function updateInputText() {
            if (!tokenAmount) {
                amountToSendInput.input.input.edit.clear()
                return
            }
            let amountToSet = SQUtils.AmountsArithmetic.fromString(tokenAmount).toFixed()
            /* When deleting characters after a decimal point
            eg: 0.000001 being deleted we have 0.00000 and it should not be updated to 0
            and thats why we compare with toFixed()
            also when deleting a numbers last digit, we should not update the text to 0
            instead it should remain empty as entered by the user */
            let currentInputTextAmount = SQUtils.AmountsArithmetic.fromString(amountToSendInput.input.text.replace(amountToSendInput.input.locale.decimalPoint,'.')).toFixed()
            if (currentInputTextAmount !== amountToSet &&
                    !(amountToSet === "0" && !amountToSendInput.input.text)) {
                amountToSendInput.input.text = amountToSet.replace('.', amountToSendInput.input.locale.decimalPoint)
            }
        }
    }

    /* TODO: remove after https://github.com/status-im/status-desktop/issues/15604 is
    implemented as this is hack to set token values correctly when model is reset */
    Connections {
        target: holdingSelector.model
        function onRowsInserted() {
            if(!!tokenKey) {
                root.reevaluateSelectedId()
            }
        }
    }

    background: Shape {
        id: shape

        property int radius: Style.current.radius
        property int leftTopRadius: radius
        property int rightTopRadius: radius
        property int leftBottomRadius: radius
        property int rightBottomRadius: radius

        readonly property int cutoutGap: 4

        scale: swapSide === SwapInputPanel.SwapSide.Pay ? -1 : 1

        ShapePath {
            id: path
            fillColor: Theme.palette.indirectColor3
            strokeColor: amountToSendInput.input.input.edit.activeFocus ? Theme.palette.directColor7 : Theme.palette.directColor8
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
            Layout.preferredWidth: parent.width*.66
            Layout.fillHeight: true

            AmountToSend {
                Layout.fillWidth: true
                id: amountToSendInput
                objectName: "amountToSendInput"
                caption: root.caption
                interactive: root.interactive
                selectedHolding: d.selectedHolding // FIXME shouldn't be necesary to pass the whole object

                fiatInputInteractive: root.fiatInputInteractive
                input.input.edit.color: !input.valid ? Theme.palette.dangerColor1 : maxSendButton.hovered ? Theme.palette.baseColor1
                                                                                                          : Theme.palette.directColor1

                multiplierIndex: d.selectedHolding && d.selectedHolding.decimals ? d.selectedHolding.decimals : 0

                maxInputBalance: (root.swapSide === SwapInputPanel.SwapSide.Receive || !d.isSelectedHoldingValidAsset) ? Number.POSITIVE_INFINITY
                                                                                                                       : maxSendButton.maxSafeValue
                currentCurrency: root.currencyStore.currentCurrency
                formatCurrencyAmount: root.currencyStore.formatCurrencyAmount
                mainInputLoading: root.mainInputLoading
                bottomTextLoading: root.bottomTextLoading
            }
        }
        ColumnLayout {
            Layout.preferredWidth: parent.width*.33

            Item { Layout.fillHeight: true }

            TokenSelector {
                id: holdingSelector
                objectName: "holdingSelector"
                Layout.rightMargin: d.isSelectedHoldingValidAsset ? -root.padding : 0
                Layout.alignment: Qt.AlignRight
                model: d.adaptor.outputAssetsModel
                nonInteractiveDelegateKey: root.nonInteractiveTokensKey
                onActivated: if (root.interactive) amountToSendInput.input.forceActiveFocus()
            }

            Item { Layout.fillHeight: !maxSendButton.visible }

            MaxSendButton {
                id: maxSendButton

                Layout.alignment: Qt.AlignRight
                Layout.maximumWidth: parent.width
                objectName: "maxTagButton"

                readonly property double maxSafeValue: WalletUtils.calculateMaxSafeSendAmount(
                                                           d.maxInputBalance, d.inputSymbol)
                readonly property string maxSafeValueAsString: maxSafeValue.toLocaleString(
                                                                   amountToSendInput.input.locale, 'f', -128)

                markAsInvalid: (!amountToSendInput.input.valid && !!amountToSendInput.input.text)
                               || d.maxInputBalance === 0

                formattedValue:
                    d.maxInputBalance === 0 ? amountToSendInput.input.locale.zeroDigit
                                            : root.currencyStore.formatCurrencyAmount(
                                                  maxSafeValue, d.inputSymbol,
                                                  { noSymbol: !amountToSendInput.inputIsFiat })

                visible: d.isSelectedHoldingValidAsset && root.swapSide === SwapInputPanel.SwapSide.Pay
                // FIXME: This should be enabled after #15709 is resolved
                enabled: false

                onClicked: {
                    if (maxSafeValue)
                        amountToSendInput.input.text = maxSafeValueAsString
                    else
                        amountToSendInput.input.input.edit.clear()
                    amountToSendInput.input.forceActiveFocus()
                }
            }
        }
    }
}
