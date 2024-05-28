import QtQuick 2.15
import QtTest 1.15

import StatusQ 0.1

import AppLayouts.Wallet.stores 1.0
import AppLayouts.Wallet.panels 1.0
import AppLayouts.Wallet.popups.swap 1.0

import shared.stores 1.0

import SortFilterProxyModel 0.2

import Models 1.0
import Storybook 1.0

Item {
    id: root
    width: 600
    height: 400

    QtObject {
        id: d

        readonly property SwapModalAdaptor adaptor: SwapModalAdaptor {
            swapStore: SwapStore {
                readonly property var accounts: WalletAccountsModel {}
                readonly property var flatNetworks: NetworksModel.flatNetworks
                readonly property bool areTestNetworksEnabled: false
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
            swapFormData: SwapInputParamsForm {}
        }
    }

    Component {
        id: componentUnderTest
        SwapInputPanel {
            anchors.centerIn: parent

            currencyStore: d.adaptor.currencyStore
            flatNetworksModel: d.adaptor.filteredFlatNetworksModel
            processedAssetsModel: d.adaptor.processedAssetsModel
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
            tryCompare(controlUnderTest, "cryptoValue", 0)
            tryCompare(controlUnderTest, "cryptoValueRaw", "0")
        }

        function test_basicSetupReceiveSide() {
            controlUnderTest = createTemporaryObject(componentUnderTest, root, {swapSide: SwapInputPanel.SwapSide.Receive})

            verify(!!controlUnderTest)
            verify(controlUnderTest.width > 0)
            verify(controlUnderTest.height > 0)

            tryCompare(controlUnderTest, "swapSide", SwapInputPanel.SwapSide.Receive)
            tryCompare(controlUnderTest, "caption", qsTr("Receive"))
            tryCompare(controlUnderTest, "selectedHoldingId", "")
            tryCompare(controlUnderTest, "cryptoValue", 0)
            tryCompare(controlUnderTest, "cryptoValueRaw", "0")
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
            tryCompare(controlUnderTest, "cryptoValue", 10000000.0000001)
            verify(controlUnderTest.cryptoValueValid)
        }

        function test_setTokenKeyAndAmounts_data() {
            return [
                { tag: "1.42", tokenAmount: "1.42", valid: true },
                { tag: "0.00001", tokenAmount: "0.00001", valid: true },
                { tag: "1234567890", tokenAmount: "1234567890", valid: true },
                { tag: "1234567890.1234567890", tokenAmount: "1234567890.1234567890", valid: true },
                { tag: "abc", tokenAmount: "abc", valid: false },
                { tag: "NaN", tokenAmount: "NaN", valid: false }
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
            tryCompare(controlUnderTest, "cryptoValue", parseFloat(tokenAmount))
            tryCompare(controlUnderTest, "cryptoValueValid", true)

            const holdingSelector = findChild(controlUnderTest, "holdingSelector")
            verify(!!holdingSelector)
            tryCompare(holdingSelector.selectedItem, "symbol", tokenSymbol)

            const amountToSendInput = findChild(controlUnderTest, "amountToSendInput")
            verify(!!amountToSendInput)
            tryCompare(amountToSendInput.input, "text", Number(tokenAmount).toLocaleString(Qt.locale(), 'f', -128))
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
            tryCompare(controlUnderTest, "cryptoValue", 1000000.00000042)
            verify(controlUnderTest.cryptoValueValid)
        }

        function test_selectSTTHoldingAndTypeAmount() {
            controlUnderTest = createTemporaryObject(componentUnderTest, root)
            verify(!!controlUnderTest)

            const holdingSelector = findChild(controlUnderTest, "holdingSelector")
            verify(!!holdingSelector)
            mouseClick(holdingSelector)
            waitForRendering(holdingSelector)

            const assetSelectorList = findChild(holdingSelector, "assetSelectorList")
            verify(!!assetSelectorList)
            waitForRendering(assetSelectorList)

            const sttDelegate = findChild(assetSelectorList, "AssetSelector_ItemDelegate_STT")
            verify(!!sttDelegate)
            mouseClick(sttDelegate, 40, 40) // center might be covered by tags

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

            tryCompare(controlUnderTest, "cryptoValue", 1.42)
            verify(controlUnderTest.cryptoValueValid)
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
            mouseClick(maxTagButton)

            const amountToSendInput = findChild(controlUnderTest, "amountToSendInput")
            verify(!!amountToSendInput)
            waitForRendering(amountToSendInput)
            const maxValue = amountToSendInput.maxInputBalance

            tryCompare(amountToSendInput.input, "text", maxValue.toLocaleString(Qt.locale(), 'f', -128))
            tryCompare(controlUnderTest, "cryptoValue", maxValue)
            verify(controlUnderTest.cryptoValueValid)
        }

        function test_loadingState() {
            controlUnderTest = createTemporaryObject(componentUnderTest, root)
            verify(!!controlUnderTest)

            controlUnderTest.loading = true

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
    }
}
