import QtQuick
import QtTest

import utils

import StatusQ
import StatusQ.Core.Utils

import AppLayouts.Wallet.stores
import AppLayouts.Wallet.adaptors

import QtModelsToolkit
import SortFilterProxyModel

import Models
import Mocks

Item {
    id: root
    width: 600
    height: 400

    readonly property string daiGroupKey: Constants.daiGroupKey
    readonly property string sttGroupKey: Constants.sttGroupKey

    QtObject {
        id: d

        readonly property var flatNetworks: NetworksModel.flatNetworks
        readonly property var assetsStore: WalletAssetsStore {
            walletTokensStore: TokensStoreMock {
                tokenGroupsModel: TokenGroupsModel {}
                tokenGroupsForChainModel: TokenGroupsModel {
                        skipInitialLoad: true
                }
                searchResultModel: TokenGroupsModel {
                    skipInitialLoad: true
                    tokenGroupsForChainModel: d.adaptor.walletAssetsStore.walletTokensStore.tokenGroupsForChainModel // the search should be performed over this model
                }
            }
        }
    }

    Component {
        id: componentUnderTest
        TokenSelectorViewAdaptor {
            assetsModel: d.assetsStore.groupedAccountAssetsModel
            allTokenGroupsForChainModel: d.assetsStore.walletTokensStore.tokenGroupsForChainModel
            searchResultModel: d.assetsStore.walletTokensStore.searchResultModel
            flatNetworksModel: d.flatNetworks
            currentCurrency: "USD"
            enabledChainIds: ModelUtils.modelToFlatArray(d.flatNetworks, "chainId")
        }
    }

    property TokenSelectorViewAdaptor controlUnderTest: null

    TestCase {
        name: "TokenSelectorViewAdaptor"
        when: windowShown

        function init() {
            controlUnderTest = createTemporaryObject(componentUnderTest, root)
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

        function test_allTokens() {
            verify(!!controlUnderTest)

            // showAllTokens = false
            let initialAssetsCount = controlUnderTest.assetsModel.ModelCount.count
            let initialOutputAssetsCount = controlUnderTest.outputAssetsModel.ModelCount.count

            tryVerify(() => initialAssetsCount === 9)
            tryVerify(() => initialOutputAssetsCount === 5)

            // showAllTokens = true, before building groups for chain
            controlUnderTest.showAllTokens = true
            tryVerify(() => controlUnderTest.outputAssetsModel.count === 0)

            // buildGroupsForChain for chainId 1
            const chainId = 1
            d.assetsStore.walletTokensStore.buildGroupsForChain(chainId)
            tryVerify(() => controlUnderTest.outputAssetsModel.count === 8)

            // showAllTokens = false
            controlUnderTest.showAllTokens = false
            tryVerify(() => controlUnderTest.outputAssetsModel.count === 5)
        }

        function test_enabledChainIds() {
            verify(!!controlUnderTest)

            // enable just "1" (Eth Mainnet) chain
            controlUnderTest.enabledChainIds = [1]

            // grab the "DAI" entry
            const delegate = ModelUtils.getByKey(controlUnderTest.outputAssetsModel, "key", daiGroupKey)
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
            const delegate = ModelUtils.getByKey(controlUnderTest.outputAssetsModel, "key", sttGroupKey)
            verify(!!delegate)

            // should have ~45.90 balance
            fuzzyCompare(delegate.currencyBalance, 45.90, 0.01)
        }

        function test_duplicatePlainTokens() {
            verify(!!controlUnderTest)

            let count = 0
            ModelUtils.forEach(controlUnderTest.outputAssetsModel, (modelItem) => {
                if (modelItem.key === daiGroupKey)
                    count++
            })

            // only one DAI entry should be present
            compare(count, 1)
        }
    }
}
