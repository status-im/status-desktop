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

import shared.popups.send.views 1.0
import shared.popups.send.panels 1.0

import utils 1.0
import shared.stores 1.0

import SortFilterProxyModel 0.2

Control {
    id: root

    // input API
    required property CurrenciesStore currencyStore
    required property var flatNetworksModel
    required property var processedAssetsModel

    property string tokenKey
    onTokenKeyChanged: {
        if (!!tokenKey)
            Qt.callLater(d.setSelectedHoldingId, tokenKey, Constants.TokenType.ERC20)
    }
    property string tokenAmount
    onTokenAmountChanged: {
        if (!!tokenAmount)
            Qt.callLater(() => amountToSendInput.input.text = Number(tokenAmount).toLocaleString(Qt.locale(), 'f', -128))
    }

    property int swapSide: SwapInputPanel.SwapSide.Pay
    property bool fiatInputInteractive
    property bool loading

    // output API
    readonly property string selectedHoldingId: d.selectedHoldingId
    readonly property double cryptoValue: amountToSendInput.cryptoValueToSendFloat
    readonly property string cryptoValueRaw: amountToSendInput.cryptoValueToSend
    readonly property bool cryptoValueValid: amountToSendInput.inputNumberValid

    // visual properties
    property int swapExchangeButtonWidth: 44
    property string caption: swapSide === SwapInputPanel.SwapSide.Pay ? qsTr("Pay") : qsTr("Receive")

    enum SwapSide {
        Pay = 0,
        Receive = 1
    }

    padding: Style.current.padding

    // by design
    implicitWidth: 492
    implicitHeight: 131

    Component.onCompleted: {
        if (root.swapSide === SwapInputPanel.SwapSide.Pay)
            amountToSendInput.input.forceActiveFocus()
    }

    QtObject {
        id: d

        function setSelectedHoldingId(holdingId, holdingType) {
            let holding = SQUtils.ModelUtils.getByKey(root.processedAssetsModel, "symbol", holdingId)
            d.selectedHoldingId = holdingId
            d.setSelectedHolding(holding, holdingType)
        }

        function setSelectedHolding(holding, holdingType) {
            d.selectedHoldingType = holdingType
            d.selectedHolding = holding
            holdingSelector.setSelectedItem(holding, holdingType)
        }

        property var selectedHolding: null
        property var selectedHoldingType: Constants.TokenType.Unknown
        property string selectedHoldingId

        readonly property bool isSelectedHoldingValidAsset: !!selectedHolding && selectedHoldingType === Constants.TokenType.ERC20
        readonly property double maxFiatBalance: isSelectedHoldingValidAsset ? selectedHolding.currentCurrencyBalance : 0
        readonly property double maxCryptoBalance: isSelectedHoldingValidAsset ? selectedHolding.currentBalance : 0
        readonly property double maxInputBalance: amountToSendInput.inputIsFiat ? maxFiatBalance : maxCryptoBalance
        readonly property string inputSymbol: amountToSendInput.inputIsFiat ? root.currencyStore.currentCurrency :
                                                                              !!d.selectedHolding && !!d.selectedHolding.symbol ? d.selectedHolding.symbol: ""
        readonly property string maxInputBalanceFormatted:
            root.currencyStore.formatCurrencyAmount(Math.trunc(prepareForMaxSend(d.maxInputBalance, d.inputSymbol)*100)/100, d.inputSymbol, {noSymbol: !amountToSendInput.inputIsFiat})

        function prepareForMaxSend(value, symbol) {
            if (symbol !== Constants.ethToken) {
                return value
            }

            return value - Math.max(0.0001, Math.min(0.01, value * 0.1))
        }

        property string searchText
    }

    background: Shape {
        id: shape

        property int radius: 16
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
                interactive: true
                selectedHolding: d.selectedHolding
                fiatInputInteractive: root.fiatInputInteractive

                multiplierIndex: d.isSelectedHoldingValidAsset && !!holdingSelector.selectedItem && !!holdingSelector.selectedItem.decimals
                                 ? holdingSelector.selectedItem.decimals
                                 : 0

                maxInputBalance: (root.swapSide === SwapInputPanel.SwapSide.Receive || !d.isSelectedHoldingValidAsset) ? Number.POSITIVE_INFINITY
                                                                                                                       : d.prepareForMaxSend(d.maxInputBalance, d.inputSymbol)
                currentCurrency: root.currencyStore.currentCurrency
                formatCurrencyAmount: root.currencyStore.formatCurrencyAmount
                loading: root.loading
            }
        }
        ColumnLayout {
            Layout.preferredWidth: parent.width*.33

            Item { Layout.fillHeight: true }

            HoldingSelector {
                id: holdingSelector
                objectName: "holdingSelector"
                Layout.rightMargin: d.isSelectedHoldingValidAsset ? -root.padding : 0
                Layout.alignment: Qt.AlignRight
                Layout.preferredHeight: 38

                searchPlaceholderText: qsTr("Search asset name or symbol")
                assetsModel: SortFilterProxyModel {
                    sourceModel: root.processedAssetsModel
                    filters: FastExpressionFilter {
                        function search(symbol, name, searchString) {
                            return (symbol.toUpperCase().includes(searchString.toUpperCase())
                                    || name.toUpperCase().includes(searchString.toUpperCase()))
                        }
                        expression: search(model.symbol, model.name, d.searchText)
                        expectedRoles: ["symbol", "name"]
                    }
                }
                networksModel: root.flatNetworksModel
                formatCurrentCurrencyAmount: function(balance) {
                    return root.currencyStore.formatCurrencyAmount(balance, root.currencyStore.currentCurrency)
                }
                formatCurrencyAmountFromBigInt: function(balance, symbol, decimals) {
                    return root.currencyStore.formatCurrencyAmountFromBigInt(balance, symbol, decimals)
                }
                onItemSelected: {
                    d.setSelectedHoldingId(holdingId, holdingType)
                    amountToSendInput.input.forceActiveFocus()
                }
                onSearchTextChanged: d.searchText = searchText
            }

            Item { Layout.fillHeight: !itemTag.visible }

            StatusListItemTag {
                id: itemTag
                objectName: "maxTagButton"
                Layout.alignment: Qt.AlignRight
                Layout.maximumWidth: parent.width
                Layout.preferredHeight: 22
                visible: d.isSelectedHoldingValidAsset && root.swapSide === SwapInputPanel.SwapSide.Pay
                title: d.maxInputBalance > 0 ? qsTr("Max: %1").arg(d.maxInputBalanceFormatted)
                                             : qsTr("No balances active")
                tagClickable: true
                closeButtonVisible: false
                titleText.font.pixelSize: 12
                bgColor: amountToSendInput.input.valid || !amountToSendInput.input.text ? Theme.palette.primaryColor3 : Theme.palette.dangerColor2
                titleText.color: amountToSendInput.input.valid || !amountToSendInput.input.text ? Theme.palette.primaryColor1 : Theme.palette.dangerColor1
                onTagClicked: {
                    const max = d.prepareForMaxSend(d.maxInputBalance, d.inputSymbol)
                    if (max > 0)
                        amountToSendInput.input.text = max.toLocaleString(Qt.locale(), 'f', -128)
                    else
                        amountToSendInput.input.input.edit.clear()
                    amountToSendInput.input.forceActiveFocus()
                }
            }
        }
    }
}
