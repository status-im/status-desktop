import QtQuick 2.15
import QtTest 1.15

import StatusQ 0.1
import StatusQ.Core 0.1
import StatusQ.Controls 0.1
import StatusQ.Core.Utils 0.1

import AppLayouts.Wallet.stores 1.0
import AppLayouts.Wallet.panels 1.0
import AppLayouts.Wallet.popups.swap 1.0
import AppLayouts.Wallet.adaptors 1.0

import shared.stores 1.0

import Models 1.0
import Storybook 1.0

Item {
    id: root
    width: 600
    height: 400

    ListModel {
        id: plainTokensModel
        ListElement {
            key: "aave"
            name: "Aave"
            symbol: "AAVE"
            image: "https://cryptologos.cc/logos/aave-aave-logo.png"
            communityId: ""
        }
    }

    QtObject {
        id: d

        readonly property SwapModalAdaptor adaptor: SwapModalAdaptor {
            swapStore: SwapStore {
                readonly property var accounts: WalletAccountsModel {}
                readonly property var flatNetworks: NetworksModel.flatNetworks
                readonly property bool areTestNetworksEnabled: true
            }
            walletAssetsStore: WalletAssetsStore {
                id: thisWalletAssetStore
                walletTokensStore: TokensStore {
                    plainTokensBySymbolModel: TokensBySymbolModel {}
                }
                readonly property var baseGroupedAccountAssetModel: GroupedAccountsAssetsModel {}
                assetsWithFilteredBalances: thisWalletAssetStore.groupedAccountsAssetsModel
            }
            currencyStore: CurrenciesStore {}
            swapFormData: SwapInputParamsForm {
                selectedAccountAddress: "0x7F47C2e18a4BBf5487E6fb082eC2D9Ab0E6d7240"
            }
            swapOutputData: SwapOutputData {}
        }

        readonly property var tokenSelectorAdaptor: TokenSelectorViewAdaptor {
            assetsModel: d.adaptor.walletAssetsStore.groupedAccountAssetsModel
            plainTokensBySymbolModel: plainTokensModel
            flatNetworksModel: d.adaptor.swapStore.flatNetworks
            currentCurrency: d.adaptor.currencyStore.currentCurrency

            accountAddress: d.adaptor.swapFormData.selectedAccountAddress
        }
    }

    Component {
        id: componentUnderTest
        SwapInputPanel {
            anchors.centerIn: parent

            currencyStore: d.adaptor.currencyStore
            flatNetworksModel: d.adaptor.swapStore.flatNetworks
            processedAssetsModel: d.adaptor.walletAssetsStore.groupedAccountAssetsModel
            plainTokensBySymbolModel: plainTokensModel
        }
    }

    property SwapInputPanel controlUnderTest: null

    TestCase {
        name: "SwapInputPanel"
        when: windowShown

        function test_basicSetupAndDefaults() {
            controlUnderTest = createTemporaryObject(componentUnderTest, root)
            verify(!!controlUnderTest)
            verify(controlUnderTest.width > 0)
            verify(controlUnderTest.height > 0)

            tryCompare(controlUnderTest, "swapSide", SwapInputPanel.SwapSide.Pay)
            tryCompare(controlUnderTest, "caption", qsTr("Pay"))
            tryCompare(controlUnderTest, "selectedHoldingId", "")
            tryCompare(controlUnderTest, "value", 0)
            tryCompare(controlUnderTest, "rawValue", "0")
        }

        function test_basicSetupReceiveSide() {
            controlUnderTest = createTemporaryObject(componentUnderTest, root, {swapSide: SwapInputPanel.SwapSide.Receive})

            verify(!!controlUnderTest)
            verify(controlUnderTest.width > 0)
            verify(controlUnderTest.height > 0)

            tryCompare(controlUnderTest, "swapSide", SwapInputPanel.SwapSide.Receive)
            tryCompare(controlUnderTest, "caption", qsTr("Receive"))
            tryCompare(controlUnderTest, "selectedHoldingId", "")
            tryCompare(controlUnderTest, "value", 0)
            tryCompare(controlUnderTest, "rawValue", "0")
        }

        function test_basicSetupWithInitialProperties() {
            controlUnderTest = createTemporaryObject(componentUnderTest, root,
                                                     {
                                                         swapSide: SwapInputPanel.SwapSide.Pay,
                                                         tokenKey: "STT",
                                                         tokenAmount: "10000000.0000001"
                                                     })
            verify(!!controlUnderTest)
            waitForRendering(controlUnderTest)

            tryCompare(controlUnderTest, "swapSide", SwapInputPanel.SwapSide.Pay)
            tryCompare(controlUnderTest, "selectedHoldingId", "STT")
            tryCompare(controlUnderTest, "value", 10000000.0000001)
            verify(controlUnderTest.valueValid)
        }

        function test_setTokenKeyAndAmounts_data() {
            return [
                { tag: "1.42", tokenAmount: "1.42", valid: true },
                { tag: "0.00001", tokenAmount: "0.00001", valid: true },
                { tag: "1234567890", tokenAmount: "1234567890", valid: true },
                { tag: "1234567890.1234567890", tokenAmount: "1234567890.1234567890", valid: true },
                { tag: "abc", tokenAmount: "abc", valid: false },
                { tag: "NaN", tokenAmount: NaN, valid: false },
                { tag: "<empty>", tokenAmount: "", valid: false }
            ]
        }

        function test_setTokenKeyAndAmounts(data) {
            const valid = data.valid
            const tokenAmount = data.tokenAmount
            const tokenSymbol = "STT"

            controlUnderTest = createTemporaryObject(componentUnderTest, root)
            verify(!!controlUnderTest)
            controlUnderTest.tokenKey = tokenSymbol
            controlUnderTest.tokenAmount = tokenAmount

            tryCompare(controlUnderTest, "selectedHoldingId", tokenSymbol)
            if (!valid)
                expectFail(data.tag, "Invalid data expected to fail: %1".arg(tokenAmount))
            tryCompare(controlUnderTest, "value", parseFloat(tokenAmount))
            tryCompare(controlUnderTest, "valueValid", true)

            const holdingSelector = findChild(controlUnderTest, "holdingSelector")
            verify(!!holdingSelector)
            tryCompare(holdingSelector, "currentTokensKey", tokenSymbol)

            const amountToSendInput = findChild(controlUnderTest, "amountToSendInput")
            verify(!!amountToSendInput)
            tryCompare(amountToSendInput.input, "text", AmountsArithmetic.fromString(tokenAmount).toLocaleString(Qt.locale(), 'f', -128))
        }

        function test_enterTokenAmountLocalizedNumber() {
            controlUnderTest = createTemporaryObject(componentUnderTest, root, {tokenKey: "STT"})
            verify(!!controlUnderTest)
            waitForRendering(controlUnderTest)
            tryCompare(controlUnderTest, "selectedHoldingId", "STT")

            const amountToSendInput = findChild(controlUnderTest, "amountToSendInput")
            verify(!!amountToSendInput)
            mouseClick(amountToSendInput)
            waitForRendering(amountToSendInput)
            verify(amountToSendInput.input.input.edit.activeFocus)

            amountToSendInput.input.locale = Qt.locale("cs_CZ")
            compare(amountToSendInput.input.locale.name, "cs_CZ")

            // manually entering "1000000,00000042" meaning "1000000,00000042"; `,` being the decimal separator
            keyClick(Qt.Key_1)
            for (let i = 0; i < 6; i++)
                keyClick(Qt.Key_0)
            keyClick(Qt.Key_Comma)
            for (let i = 0; i < 6; i++)
                keyClick(Qt.Key_0)
            keyClick(Qt.Key_4)
            keyClick(Qt.Key_2)

            tryCompare(amountToSendInput.input, "text", "1000000,00000042")
            tryCompare(controlUnderTest, "value", 1000000.00000042)
            verify(controlUnderTest.valueValid)
        }

        function test_selectSTTHoldingAndTypeAmount() {
            controlUnderTest = createTemporaryObject(componentUnderTest, root)
            verify(!!controlUnderTest)

            const holdingSelector = findChild(controlUnderTest, "holdingSelector")
            verify(!!holdingSelector)
            mouseClick(holdingSelector)
            waitForRendering(holdingSelector)

            const assetSelectorList = findChild(holdingSelector, "tokenSelectorListview")
            verify(!!assetSelectorList)
            waitForRendering(assetSelectorList)

            const sttDelegate = findChild(assetSelectorList, "tokenSelectorAssetDelegate_STT")
            verify(!!sttDelegate)
            mouseClick(sttDelegate)

            tryCompare(controlUnderTest, "selectedHoldingId", "STT")

            const amountToSendInput = findChild(controlUnderTest, "amountToSendInput")
            verify(!!amountToSendInput)
            mouseClick(amountToSendInput)
            waitForRendering(amountToSendInput)
            verify(amountToSendInput.input.input.edit.activeFocus)

            keyClick(Qt.Key_1)
            keyClick(Qt.Key_Period)
            keyClick(Qt.Key_4)
            keyClick(Qt.Key_2)

            tryCompare(controlUnderTest, "value", 1.42)
            verify(controlUnderTest.valueValid)
        }

        // verify that when "fiatInputInteractive" mode is on, the Max send button text shows fiat currency symbol (e.g. "1.2 USD")
        function test_maxButtonFiatCurrencySymbol() {
            controlUnderTest = createTemporaryObject(componentUnderTest, root, {tokenKey: "ETH"})
            verify(!!controlUnderTest)
            waitForRendering(controlUnderTest)
            controlUnderTest.fiatInputInteractive = true

            const maxTagButton = findChild(controlUnderTest, "maxTagButton")
            verify(!!maxTagButton)
            waitForRendering(maxTagButton)
            verify(maxTagButton.visible)
            verify(!maxTagButton.text.endsWith("ETH"))
            compare(maxTagButton.type, StatusBaseButton.Type.Normal)
            mouseClick(maxTagButton)

            const amountToSendInput = findChild(controlUnderTest, "amountToSendInput")
            verify(!!amountToSendInput)
            waitForRendering(amountToSendInput)

            const bottomItemText = findChild(amountToSendInput, "bottomItemText")
            verify(!!bottomItemText)
            verify(bottomItemText.visible)
            mouseClick(bottomItemText)
            waitForRendering(amountToSendInput)

            verify(maxTagButton.text.endsWith("USD"))
        }

        // verify that in default mode, the Max send button text doesn't show the currency symbol for crypto (e.g. "1.2" for ETH)
        function test_maxButtonNoCryptoCurrencySymbol() {
            controlUnderTest = createTemporaryObject(componentUnderTest, root, {tokenKey: "ETH"})
            verify(!!controlUnderTest)
            waitForRendering(controlUnderTest)

            const maxTagButton = findChild(controlUnderTest, "maxTagButton")
            verify(!!maxTagButton)
            waitForRendering(maxTagButton)
            verify(maxTagButton.visible)
            compare(maxTagButton.type, StatusBaseButton.Type.Normal)
            verify(!maxTagButton.text.endsWith("ETH"))
        }

        function test_clickingMaxButton() {
            controlUnderTest = createTemporaryObject(componentUnderTest, root, {tokenKey: "ETH"})
            verify(!!controlUnderTest)
            waitForRendering(controlUnderTest)
            tryCompare(controlUnderTest, "selectedHoldingId", "ETH")

            const maxTagButton = findChild(controlUnderTest, "maxTagButton")
            verify(!!maxTagButton)
            waitForRendering(maxTagButton)
            verify(maxTagButton.visible)
            compare(maxTagButton.type, StatusBaseButton.Type.Normal)
            mouseClick(maxTagButton)

            const amountToSendInput = findChild(controlUnderTest, "amountToSendInput")
            verify(!!amountToSendInput)
            waitForRendering(amountToSendInput)
            const maxValue = amountToSendInput.maxInputBalance

            tryCompare(amountToSendInput.input, "text", maxValue.toLocaleString(Qt.locale(), 'f', -128))
            tryCompare(controlUnderTest, "value", maxValue)
            verify(controlUnderTest.valueValid)
        }

        function test_loadingState() {
            controlUnderTest = createTemporaryObject(componentUnderTest, root)
            verify(!!controlUnderTest)

            controlUnderTest.mainInputLoading = true
            controlUnderTest.bottomTextLoading = true

            const amountToSendInput = findChild(controlUnderTest, "amountToSendInput")
            verify(!!amountToSendInput)

            const amountInput = findChild(amountToSendInput, "amountInput")
            verify(!!amountInput)
            verify(!amountInput.visible)

            const topAmountToSendInputLoadingComponent = findChild(amountToSendInput, "topAmountToSendInputLoadingComponent")
            verify(!!topAmountToSendInputLoadingComponent)
            verify(topAmountToSendInputLoadingComponent.visible)

            const bottomItemText = findChild(amountToSendInput, "bottomItemText")
            verify(!!bottomItemText)
            verify(!bottomItemText.visible)

            const bottomItemTextLoadingComponent = findChild(amountToSendInput, "bottomItemTextLoadingComponent")
            verify(!!bottomItemTextLoadingComponent)
            verify(bottomItemTextLoadingComponent.visible)
        }

        function test_max_button_when_different_tokens_clicked() {
            controlUnderTest = createTemporaryObject(componentUnderTest, root)
            verify(!!controlUnderTest)

            const maxTagButton = findChild(controlUnderTest, "maxTagButton")
            verify(!!maxTagButton)
            verify(!maxTagButton.visible)

            const holdingSelector = findChild(controlUnderTest, "holdingSelector")
            verify(!!holdingSelector)

            const assetSelectorList = findChild(holdingSelector, "tokenSelectorListview")
            verify(!!assetSelectorList)

            const amountToSendInput = findChild(controlUnderTest, "amountToSendInput")
            verify(!!amountToSendInput)

            const bottomItemText = findChild(amountToSendInput, "bottomItemText")
            verify(!!bottomItemText)

            for (let i= 0; i < d.tokenSelectorAdaptor.outputAssetsModel.count; i++) {
                let modelItemToTest = ModelUtils.get(d.tokenSelectorAdaptor.outputAssetsModel, i)
                mouseClick(holdingSelector)
                waitForRendering(assetSelectorList)

                let delToTest = assetSelectorList.itemAtIndex(i)
                verify(!!delToTest)
                mouseClick(delToTest)

                waitForRendering(controlUnderTest)
                verify(maxTagButton.visible)
                verify(!maxTagButton.text.endsWith(modelItemToTest.symbol))
                tryCompare(maxTagButton, "type", modelItemToTest.currentBalance === 0 ? StatusBaseButton.Type.Danger : StatusBaseButton.Type.Normal)

                // check input value and state
                mouseClick(maxTagButton)
                waitForRendering(amountToSendInput)

                tryCompare(amountToSendInput.input, "text", modelItemToTest.currentBalance === 0 ? "" : maxTagButton.maxSafeValueAsString)
                compare(controlUnderTest.value, maxTagButton.maxSafeValue)
                verify(modelItemToTest.currentBalance === 0 ? !controlUnderTest.valueValid : controlUnderTest.valueValid)
                const marketPrice = !!amountToSendInput.selectedHolding ? amountToSendInput.selectedHolding.marketDetails.currencyPrice.amount : 0
                compare(bottomItemText.text, d.adaptor.formatCurrencyAmount(
                            maxTagButton.maxSafeValue * marketPrice,
                            d.adaptor.currencyStore.currentCurrency))

                amountToSendInput.input.input.edit.clear()
            }
        }

        function test_input_greater_than_max_balance() {
            controlUnderTest = createTemporaryObject(componentUnderTest, root)
            verify(!!controlUnderTest)

            controlUnderTest.mainInputLoading = true
            controlUnderTest.bottomTextLoading = true

            const maxTagButton = findChild(controlUnderTest, "maxTagButton")
            verify(!!maxTagButton)
            verify(!maxTagButton.visible)

            const holdingSelector = findChild(controlUnderTest, "holdingSelector")
            verify(!!holdingSelector)

            const assetSelectorList = findChild(holdingSelector, "tokenSelectorListview")
            verify(!!assetSelectorList)

            const amountToSendInput = findChild(controlUnderTest, "amountToSendInput")
            verify(!!amountToSendInput)

            const bottomItemText = findChild(amountToSendInput, "bottomItemText")
            verify(!!bottomItemText)

            // enter 5.42 as entered amount
            keyClick(Qt.Key_5)
            keyClick(Qt.Key_Period)
            keyClick(Qt.Key_4)
            keyClick(Qt.Key_2)

            let numberTested = LocaleUtils.numberFromLocaleString("5.42", amountToSendInput.input.locale)

            compare(amountToSendInput.input.text, "5.42")

            for (let i= 0; i < d.tokenSelectorAdaptor.outputAssetsModel.count; i++) {
                let modelItemToTest = ModelUtils.get(d.tokenSelectorAdaptor.outputAssetsModel, i)
                mouseClick(holdingSelector)
                waitForRendering(holdingSelector)

                let delToTest = assetSelectorList.itemAtIndex(i)
                verify(!!delToTest)
                mouseClick(delToTest)

                // check input value and state
                waitForRendering(controlUnderTest)

                compare(amountToSendInput.input.text, "5.42")
                const marketPrice = !!amountToSendInput.selectedHolding ? amountToSendInput.selectedHolding.marketDetails.currencyPrice.amount : 0
                tryCompare(bottomItemText, "text", d.adaptor.formatCurrencyAmount(
                               numberTested * marketPrice,
                               d.adaptor.currencyStore.currentCurrency))
                compare(controlUnderTest.value, numberTested)
                compare(controlUnderTest.rawValue, AmountsArithmetic.fromNumber(amountToSendInput.input.text, modelItemToTest.decimals).toString())
                compare(controlUnderTest.valueValid, numberTested <= maxTagButton.maxSafeValue)
                compare(controlUnderTest.selectedHoldingId, modelItemToTest.tokensKey)
                compare(controlUnderTest.amountEnteredGreaterThanBalance, numberTested > maxTagButton.maxSafeValue)
            }
        }

        function test_if_values_are_reset_after_setting_tokenAmount_as_empty() {
            const tokenKeyToTest = "ETH"
            let numberTestedString = "1.0001"
            let modelItemToTest = ModelUtils.getByKey(d.tokenSelectorAdaptor.outputAssetsModel, "tokensKey", tokenKeyToTest)
            controlUnderTest = createTemporaryObject(componentUnderTest, root, {
                                                         swapSide: SwapInputPanel.SwapSide.Pay,
                                                         tokenKey: tokenKeyToTest,
                                                         tokenAmount: numberTestedString
                                                     })
            verify(!!controlUnderTest)
            waitForRendering(controlUnderTest)


            const amountToSendInput = findChild(controlUnderTest, "amountToSendInput")
            verify(!!amountToSendInput)

            const bottomItemText = findChild(amountToSendInput, "bottomItemText")
            verify(!!bottomItemText)

            let numberTested = LocaleUtils.numberFromLocaleString(numberTestedString, amountToSendInput.input.locale)

            compare(amountToSendInput.input.text, numberTestedString)
            compare(controlUnderTest.value, numberTested)
            compare(controlUnderTest.rawValue, AmountsArithmetic.fromNumber(amountToSendInput.input.text, modelItemToTest.decimals).toString())
            compare(controlUnderTest.valueValid, true)
            compare(controlUnderTest.selectedHoldingId, tokenKeyToTest)
            compare(controlUnderTest.amountEnteredGreaterThanBalance, false)

            numberTestedString = ""
            numberTested = 0
            controlUnderTest.tokenAmount = numberTestedString
            waitForItemPolished(controlUnderTest)

            tryCompare(amountToSendInput.input, "text", numberTestedString)
            tryCompare(controlUnderTest, "value", numberTested)
            compare(controlUnderTest.rawValue, AmountsArithmetic.fromNumber(numberTested, modelItemToTest.decimals).toString())
            compare(controlUnderTest.valueValid, false)
            compare(controlUnderTest.selectedHoldingId, tokenKeyToTest)
            compare(controlUnderTest.amountEnteredGreaterThanBalance, false)
        }
    }
}
