import QtQuick 2.15
import QtTest 1.15

import Models 1.0

import StatusQ.Core 0.1
import StatusQ.Controls 0.1
import StatusQ.Core.Theme 0.1

import AppLayouts.TradingCenter 1.0
import AppLayouts.Wallet 1.0

import utils 1.0

Item {
    id: root
    width: 600
    height: 400

    Component {
        id: componentUnderTest
        TradingCenterLayout {
            anchors.fill: parent
            loading: false
            totalTokensCount: 1300
            tokensModel: TokensBySymbolModel {}
            formatCurrencyAmount: function(cryptoValue) {
                return "%L1 %2".arg(cryptoValue).arg("USD")
            }
        }
    }

    SignalSpy {
        id: signalSpyLaunchSwap
        target: controlUnderTest
        signalName: "requestLaunchSwap"
    }

    property TradingCenterLayout controlUnderTest: null

    TestCase {
        name: "TradingCenterLayout"
        when: windowShown

        function init() {
            controlUnderTest = createTemporaryObject(componentUnderTest, root)
            signalSpyLaunchSwap.clear()
        }

        function test_basicGeometry() {
            verify(!!controlUnderTest)
            verify(controlUnderTest.width > 0)
            verify(controlUnderTest.height > 0)
        }

        function test_header() {
            verify(!!controlUnderTest)

            // header
            const heading = findChild(controlUnderTest.centerPanel, "heading")
            verify(!!heading)
            compare(heading.text, qsTr("Trading"))
            compare(heading.font.pixelSize, 28)
            compare(heading.font.weight, Font.Bold)

            // Swap Button
            const swapButton = findChild(controlUnderTest.centerPanel, "swapButton")
            verify(!!swapButton)
            compare(swapButton.text, qsTr("Swap"))
            compare(swapButton.icon.name, "swap")
            compare(swapButton.type, StatusBaseButton.Type.Primary)
            mouseClick(swapButton)
            tryCompare(signalSpyLaunchSwap, "count", 1)
        }

        function test_tokenList() {
            verify(!!controlUnderTest)

            const regularModel = findChild(controlUnderTest, "regularModel")
            verify(!!regularModel)

            // token list
            const tokensList = findChild(controlUnderTest.centerPanel, "tokensList")
            verify(!!tokensList)
            compare(tokensList.model, regularModel)
            compare(tokensList.count, controlUnderTest.tokensModel.count)
            verify(!controlUnderTest.loading)

            // footer
            const footer = findChild(tokensList, "tradingCenterFooter")
            verify(!!footer)
            verify(footer.visible)

            verify(!tokensList.verticalScrollBar.visible)
            tokensList.positionViewAtIndex(60, ListView.Center)
            waitForRendering(tokensList)
            verify(tokensList.verticalScrollBar.visible)

            waitForItemPolished(tokensList)

            // Test Delegate contents
            for(let i = 0; i<tokensList.count - 1; i++) {
                const delegateUnderTest = tokensList.itemAtIndex(i)
                if(!!delegateUnderTest) {
                    const modelItemUnderTest = regularModel.model.get(i)
                    verify(!!modelItemUnderTest)

                    const indexText = findChild(delegateUnderTest.contentItem, "indexText")
                    verify(!!indexText)
                    const icon = findChild(delegateUnderTest.contentItem, "icon")
                    verify(!!icon)
                    const tokenNameText = findChild(delegateUnderTest.contentItem, "tokenNameText")
                    verify(!!tokenNameText)
                    const tokenSymbolText = findChild(delegateUnderTest.contentItem, "tokenSymbolText")
                    verify(!!tokenSymbolText)
                    const priceText = findChild(delegateUnderTest.contentItem, "priceText")
                    verify(!!priceText)
                    const changePct24HrText = findChild(delegateUnderTest.contentItem, "changePct24HrText")
                    verify(!!changePct24HrText)
                    const volume24HrText = findChild(delegateUnderTest.contentItem, "volume24HrText")
                    verify(!!volume24HrText)
                    const marketCapText = findChild(delegateUnderTest.contentItem, "marketCapText")
                    verify(!!marketCapText)

                    compare(indexText.text, "%1".arg(i+1))
                    compare(indexText.font.pixelSize, Theme.additionalTextSize)
                    compare(indexText.color, Theme.palette.directColor1)

                    compare(icon.image.source, Constants.tokenIcon(modelItemUnderTest.symbol))
                    compare(icon.width, 32)
                    compare(icon.height, 32)

                    compare(tokenNameText.text, modelItemUnderTest.name)
                    compare(tokenNameText.font.pixelSize, Theme.primaryTextFontSize)
                    compare(tokenNameText.font.weight, Font.Medium)
                    compare(tokenNameText.color, Theme.palette.directColor1)

                    compare(tokenSymbolText.text, modelItemUnderTest.symbol)
                    compare(tokenSymbolText.font.pixelSize, Theme.primaryTextFontSize)
                    compare(tokenSymbolText.font.weight, Font.Normal)
                    compare(tokenSymbolText.color, Theme.palette.baseColor1)

                    compare(priceText.text,
                            controlUnderTest.formatCurrencyAmount(modelItemUnderTest.marketDetails.currencyPrice.amount))
                    compare(priceText.font.pixelSize, Theme.primaryTextFontSize)
                    compare(priceText.font.weight, Font.Medium)
                    compare(priceText.color, Theme.palette.directColor1)

                    compare(changePct24HrText.text,
                            qsTr("%1 %2%").arg(WalletUtils.getUpDownTriangle(modelItemUnderTest.marketDetails.changePct24hour))
                            .arg(LocaleUtils.numberToLocaleString(modelItemUnderTest.marketDetails.changePct24hour, 2)))
                    compare(changePct24HrText.font.pixelSize, Theme.primaryTextFontSize)
                    compare(changePct24HrText.font.weight, Font.Medium)
                    compare(changePct24HrText.color,
                            WalletUtils.getChangePct24HourColor(modelItemUnderTest.marketDetails.changePct24hour))

                    compare(volume24HrText.text, "--")
                    compare(volume24HrText.font.pixelSize, Theme.primaryTextFontSize)
                    compare(volume24HrText.font.weight, Font.Medium)
                    compare(volume24HrText.color, Theme.palette.directColor1)

                    compare(marketCapText.text, LocaleUtils.currencyAmountToLocaleString(modelItemUnderTest.marketDetails.marketCap))
                    compare(marketCapText.font.pixelSize, Theme.primaryTextFontSize)
                    compare(marketCapText.font.weight, Font.Medium)
                    compare(marketCapText.color, Theme.palette.directColor1)
                }
            }
        }

        function test_loadingState() {
            verify(!!controlUnderTest)

            verify(!controlUnderTest.loading)

            const regularModel = findChild(controlUnderTest, "regularModel")
            verify(!!regularModel)
            const loadingModel = findChild(controlUnderTest, "loadingModel")
            verify(!!loadingModel)
            const tokensList = findChild(controlUnderTest.centerPanel, "tokensList")
            verify(!!tokensList)

            // Loading true
            controlUnderTest.loading = true
            compare(tokensList.model, loadingModel)
            compare(tokensList.count, 100)

            // Loading false
            controlUnderTest.loading = false
            compare(tokensList.model, regularModel)
            compare(tokensList.count, controlUnderTest.tokensModel.count)
        }
    }
}
