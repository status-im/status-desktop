import QtQuick 2.15
import QtTest 1.15
import QtQml 2.15

import Models 1.0

import AppLayouts.Wallet.controls 1.0
import AppLayouts.Wallet.stores 1.0
import AppLayouts.Wallet.adaptors 1.0

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

        readonly property var flatNetworks: NetworksModel.flatNetworks
        readonly property var assetsStore: WalletAssetsStore {
            id: thisWalletAssetStore
            walletTokensStore: TokensStore {
                plainTokensBySymbolModel: TokensBySymbolModel {}
            }
            readonly property var baseGroupedAccountAssetModel: GroupedAccountsAssetsModel {}
            assetsWithFilteredBalances: thisWalletAssetStore.groupedAccountsAssetsModel
        }

        readonly property var adaptor: TokenSelectorViewAdaptor {
            assetsModel: d.assetsStore.groupedAccountAssetsModel
            plainTokensBySymbolModel: plainTokensModel
            flatNetworksModel: d.flatNetworks
            currentCurrency: "USD"

            Binding on searchString {
                value: controlUnderTest ? controlUnderTest.searchString : ""
                restoreMode: Binding.RestoreNone
            }
        }
    }

    Component {
        id: componentUnderTest
        TokenSelector {
            anchors.centerIn: parent
            model: d.adaptor.outputAssetsModel
        }
    }

    SignalSpy {
        id: signalSpy
        target: controlUnderTest
        signalName: "tokenSelected"
    }

    property TokenSelector controlUnderTest: null

    TestCase {
        name: "TokenSelector"
        when: windowShown

        function init() {
            controlUnderTest = createTemporaryObject(componentUnderTest, root)
            signalSpy.clear()
        }

        function test_basicGeometry() {
            verify(!!controlUnderTest)
            verify(controlUnderTest.width > 0)
            verify(controlUnderTest.height > 0)
        }

        function test_clickEthToken() {
            verify(!!controlUnderTest)

            mouseClick(controlUnderTest)
            waitForItemPolished(controlUnderTest)

            const listview = findChild(controlUnderTest.popup.contentItem, "tokenSelectorListview")
            verify(!!listview)
            waitForItemPolished(listview)

            const tokensKey = "ETH"
            const delegate = findChild(listview, "tokenSelectorAssetDelegate_%1".arg(tokensKey))
            verify(!!delegate)
            tryCompare(delegate, "tokensKey", tokensKey)

            // click the delegate, verify the signal has been fired and has the correct "tokensKey" as argument
            mouseClick(delegate)
            tryCompare(signalSpy, "count", 1)
            compare(signalSpy.signalArguments[0][0], tokensKey)
            compare(controlUnderTest.currentTokensKey, tokensKey)

            // close the popup, reopen and verify our token is highlighted
            controlUnderTest.popup.close()
            mouseClick(controlUnderTest)
            tryCompare(controlUnderTest.popup, "opened", true)
            tryCompare(delegate, "highlighted", true)
        }

        function test_clickNonInteractiveToken() {
            verify(!!controlUnderTest)

            const tokensKey = "STT"
            controlUnderTest.nonInteractiveDelegateKey = tokensKey

            mouseClick(controlUnderTest)
            waitForItemPolished(controlUnderTest)

            const listview = findChild(controlUnderTest.popup.contentItem, "tokenSelectorListview")
            verify(!!listview)
            waitForItemPolished(listview)

            const delegate = findChild(listview, "tokenSelectorAssetDelegate_%1".arg(tokensKey))
            verify(!!delegate)
            tryCompare(delegate, "tokensKey", tokensKey)
            tryCompare(delegate, "interactive", false)

            mouseClick(delegate)
            tryCompare(signalSpy, "count", 0)
            tryCompare(controlUnderTest, "currentTokensKey", "")
        }

        function test_selectToken() {
            verify(!!controlUnderTest)

            const tokensKey = "STT"
            controlUnderTest.selectToken(tokensKey)
            tryCompare(signalSpy, "count", 1)
            compare(signalSpy.signalArguments[0][0], tokensKey)
            tryCompare(controlUnderTest, "currentTokensKey", tokensKey)

            const listview = findChild(controlUnderTest.popup.contentItem, "tokenSelectorListview")
            verify(!!listview)
            mouseClick(controlUnderTest)
            const delegate = findChild(listview, "tokenSelectorAssetDelegate_%1".arg(tokensKey))
            verify(!!delegate)
            tryCompare(delegate, "tokensKey", tokensKey)
            tryCompare(delegate, "highlighted", true)
        }

        function test_selectNonexistingToken() {
            verify(!!controlUnderTest)

            const tokensKey = "0x6b175474e89094c44da98b954eedeac495271d0f" // MET

            // not available by default
            controlUnderTest.selectToken(tokensKey)
            tryCompare(signalSpy, "count", 1)
            compare(signalSpy.signalArguments[0][0], "")
            tryCompare(controlUnderTest, "currentTokensKey", "")

            // enable community assets, now should be available, try to select it
            d.adaptor.showCommunityAssets = true
            controlUnderTest.selectToken(tokensKey)
            tryCompare(signalSpy, "count", 2)
            compare(signalSpy.signalArguments[1][0], tokensKey)
            tryCompare(controlUnderTest, "currentTokensKey", tokensKey)

            // disable community assets to simulate token gone
            d.adaptor.showCommunityAssets = false

            // control should reset itself back
            tryCompare(signalSpy, "count", 3)
            compare(signalSpy.signalArguments[2][0], "")
            tryCompare(controlUnderTest, "currentTokensKey", "")
        }

        function test_search() {
            verify(!!controlUnderTest)

            mouseClick(controlUnderTest)
            waitForItemPolished(controlUnderTest)

            const originalCount = controlUnderTest.count
            verify(originalCount > 0)

            // verify the search box has focus
            const searchBox = findChild(controlUnderTest.popup.contentItem, "searchBox")
            verify(!!searchBox)
            tryCompare(searchBox.input.edit, "focus", true)

            // type "dAi"
            keyClick(Qt.Key_D)
            keyClick(Qt.Key_A, Qt.ShiftModifier)
            keyClick(Qt.Key_I)

            // search yields 1 result
            waitForItemPolished(controlUnderTest)
            tryCompare(controlUnderTest, "count", 1)

            // closing the popup should clear the search and put the view back to original count
            controlUnderTest.popup.close()
            mouseClick(controlUnderTest)
            tryCompare(searchBox.input.edit, "text", "")
            tryCompare(controlUnderTest, "count", originalCount)
        }

        function test_sections() {
            verify(!!controlUnderTest)

            d.adaptor.enabledChainIds = [10] // filter Optimism chain only

            mouseClick(controlUnderTest)
            waitForItemPolished(controlUnderTest)

            const listview = findChild(controlUnderTest.popup.contentItem, "tokenSelectorListview")
            verify(!!listview)
            waitForItemPolished(listview)

            const sttDelegate = findChild(listview, "tokenSelectorAssetDelegate_STT")
            verify(!!sttDelegate)
            tryCompare(sttDelegate, "tokensKey", "STT")
            compare(sttDelegate.ListView.section, "Your assets on Optimism")

            const ethDelegate = findChild(listview, "tokenSelectorAssetDelegate_ETH")
            verify(!!ethDelegate)
            tryCompare(ethDelegate, "tokensKey", "ETH")
            compare(ethDelegate.ListView.section, "Popular assets")
        }

        function test_plainTokenDelegate() {
            verify(!!controlUnderTest)

            d.adaptor.showAllTokens = true
            const tokensKey = "aave"

            mouseClick(controlUnderTest)
            waitForItemPolished(controlUnderTest)

            const listview = findChild(controlUnderTest.popup.contentItem, "tokenSelectorListview")
            verify(!!listview)
            waitForItemPolished(listview)

            const delegate = findChild(listview, "tokenSelectorAssetDelegate_%1".arg(tokensKey))
            verify(!!delegate)
            tryCompare(delegate, "tokensKey", tokensKey)
            tryCompare(delegate, "currencyBalanceAsString", "")

            // click the delegate, verify the signal has been fired and has the correct "tokensKey" as argument
            mouseClick(delegate)
            tryCompare(signalSpy, "count", 1)
            compare(signalSpy.signalArguments[0][0], tokensKey)
            compare(controlUnderTest.currentTokensKey, tokensKey)
            d.adaptor.showAllTokens = false
        }
    }
}
