import QtQuick 2.15
import QtTest 1.15

import Models 1.0

import StatusQ.Core.Utils 0.1

import AppLayouts.Wallet.stores 1.0
import AppLayouts.Wallet.adaptors 1.0

Item {
    id: root
    width: 600
    height: 400

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
    }

    Component {
        id: componentUnderTest
        TokenSelectorViewAdaptor {
            assetsModel: d.assetsStore.groupedAccountAssetsModel
            flatNetworksModel: d.flatNetworks
            currentCurrency: "USD"
        }
    }

    property TokenSelectorViewAdaptor controlUnderTest: null

    TestCase {
        name: "TokenSelectorViewAdaptor"
        when: windowShown

        function init() {
            controlUnderTest = createTemporaryObject(componentUnderTest, root)
        }

        function test_search() {
            verify(!!controlUnderTest)

            const searchText = "dAi"
            const originalCount = controlUnderTest.outputAssetsModel.count
            controlUnderTest.searchString = searchText

            // search yields 1 result
            tryCompare(controlUnderTest.outputAssetsModel, "count", 1)

            // resetting search string resets the view back to original count
            controlUnderTest.searchString = ""
            tryCompare(controlUnderTest.outputAssetsModel, "count", originalCount)
        }

        function test_showCommunityAssets() {
            verify(!!controlUnderTest)

            const originalCount = controlUnderTest.outputAssetsModel.count

            // turn on showing the community assets, verify we now have more items
            controlUnderTest.showCommunityAssets = true
            tryVerify(() => controlUnderTest.outputAssetsModel.count > originalCount)

            // turning them back off, verify we are back to the original number of items
            controlUnderTest.showCommunityAssets = false
            tryCompare(controlUnderTest.outputAssetsModel, "count", originalCount)
        }

        function test_enabledChainIds() {
            verify(!!controlUnderTest)

            // enable just "1" (Eth Mainnet) chain
            controlUnderTest.enabledChainIds = [1]

            // grab the "DAI" entry
            const delegate = ModelUtils.getByKey(controlUnderTest.outputAssetsModel, "tokensKey", "DAI")
            verify(!!delegate)
            const origBalance = delegate.currencyBalance

            // should have 0 balance
            tryCompare(delegate, "currencyBalance", 0)

            // re-enable all chains, DAI should again have the original balance
            controlUnderTest.enabledChainIds = []
            tryCompare(delegate, "currencyBalance", origBalance)
        }

        function test_accountAddress() {
            verify(!!controlUnderTest)

            // enable the "Hot wallet" account address filter (0x7F47C2e98a4BBf5487E6fb082eC2D9Ab0E6d8881)
            controlUnderTest.accountAddress = "0x7F47C2e98a4BBf5487E6fb082eC2D9Ab0E6d8881"

            // grab the "STT" entry
            const delegate = ModelUtils.getByKey(controlUnderTest.outputAssetsModel, "tokensKey", "STT")
            verify(!!delegate)

            // should have ~45.90 balance
            fuzzyCompare(delegate.currencyBalance, 45.90, 0.01)
        }
    }
}
