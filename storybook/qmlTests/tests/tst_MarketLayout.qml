import QtQuick 2.15
import QtTest 1.15

import Models 1.0
import SortFilterProxyModel 0.2

import StatusQ.Core 0.1
import StatusQ.Controls 0.1
import StatusQ.Core.Theme 0.1

import AppLayouts.Market 1.0
import AppLayouts.Wallet 1.0

import utils 1.0

Item {
    id: root
    width: 600
    height: 400

    Component {
        id: componentUnderTest
        MarketLayout {
            anchors.fill: parent
            loading: false
            totalTokensCount: marketTokensModel.count
            currencySymbol: "$"
            tokensModel: SortFilterProxyModel {
                sourceModel: MarketTokensModel {
                    id: marketTokensModel
                }
                filters: IndexFilter {
                    minimumIndex: d.startIndex
                    maximumIndex: d.endIndex
                }
            }
            fnFormatCurrencyAmount: function(amount, options) {
                let abc = ({
                               amount: amount,
                               symbol: "usd".toUpperCase(),
                               displayDecimals: 2,
                               stripTrailingZeroes: false
                           })
                return LocaleUtils.currencyAmountToLocaleString(abc, options)
            }
            currentPage: -1
            onFetchMarketTokens: {
                d.startIndex = ((pageNumber - 1) * pageSize) + 1
                d.endIndex = Math.min(pageNumber * pageSize, totalTokensCount)
                currentPage = pageNumber
            }
        }
    }

    QtObject {
        id: d
        property int startIndex: 0
        property int endIndex: 0
    }

    SignalSpy {
        id: signalSpyLaunchSwap
        target: controlUnderTest
        signalName: "requestLaunchSwap"
    }

    property MarketLayout controlUnderTest: null

    TestCase {
        name: "MarketLayout"
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
            compare(heading.text, qsTr("Market"))
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
            const footer = findChild(tokensList, "marketFooter")
            verify(!!footer)
            verify(footer.visible)

            waitForRendering(controlUnderTest)

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

                    compare(icon.image.source, modelItemUnderTest.image)
                    compare(icon.width, 32)
                    compare(icon.height, 32)

                    compare(tokenNameText.text, modelItemUnderTest.name)
                    compare(tokenNameText.font.pixelSize, Theme.primaryTextFontSize)
                    compare(tokenNameText.font.weight, Font.Medium)
                    compare(tokenNameText.color, Theme.palette.directColor1)

                    compare(tokenSymbolText.text, modelItemUnderTest.symbol.toUpperCase())
                    compare(tokenSymbolText.font.pixelSize, Theme.primaryTextFontSize)
                    compare(tokenSymbolText.font.weight, Font.Normal)
                    compare(tokenSymbolText.color, Theme.palette.baseColor1)

                    const expectedPriceString = "%1%2"
                    .arg(controlUnderTest.currencySymbol)
                    .arg(controlUnderTest.fnFormatCurrencyAmount(modelItemUnderTest.currentPrice, {noSymbol: true}))
                    compare(priceText.text, expectedPriceString)
                    compare(priceText.font.pixelSize, Theme.primaryTextFontSize)
                    compare(priceText.font.weight, Font.Medium)
                    compare(priceText.color, Theme.palette.directColor1)

                    compare(changePct24HrText.text,
                            qsTr("%1 %2%").arg(WalletUtils.getUpDownTriangle(modelItemUnderTest.priceChangePercentage24h))
                            .arg(LocaleUtils.numberToLocaleString(modelItemUnderTest.priceChangePercentage24h, 2)))
                    compare(changePct24HrText.font.pixelSize, Theme.primaryTextFontSize)
                    compare(changePct24HrText.font.weight, Font.Medium)
                    compare(changePct24HrText.color,
                            WalletUtils.getChangePct24HourColor(modelItemUnderTest.priceChangePercentage24h))

                    const expectedTotalVolumeString = "%1%2"
                    .arg(controlUnderTest.currencySymbol)
                    .arg(controlUnderTest.fnFormatCurrencyAmount(modelItemUnderTest.totalVolume, {noSymbol: true}))
                    compare(volume24HrText.text, expectedTotalVolumeString)
                    compare(volume24HrText.font.pixelSize, Theme.primaryTextFontSize)
                    compare(volume24HrText.font.weight, Font.Medium)
                    compare(volume24HrText.color, Theme.palette.directColor1)

                    const expectedMarketCapString = "%1%2"
                    .arg(controlUnderTest.currencySymbol)
                    .arg(controlUnderTest.fnFormatCurrencyAmount(modelItemUnderTest.marketCap, {noSymbol: true}))
                    compare(marketCapText.text, expectedMarketCapString)
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
