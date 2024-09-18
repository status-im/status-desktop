import QtQuick 2.15
import QtTest 1.15

import Models 1.0

import AppLayouts.Wallet.views 1.0
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

        readonly property var adaptor: TokenSelectorViewAdaptor {
            assetsModel: d.assetsStore.groupedAccountAssetsModel
            flatNetworksModel: d.flatNetworks
            currentCurrency: "USD"
            enabledChainIds: ModelUtils.modelToFlatArray(d.flatNetworks, "chainId")
        }
    }

    Component {
        id: componentUnderTest
        TokenSelectorView {
            anchors.fill: parent
            model: d.adaptor.outputAssetsModel
        }
    }

    SignalSpy {
        id: signalSpy
        target: controlUnderTest
        signalName: "tokenSelected"
    }

    property TokenSelectorView controlUnderTest: null

    TestCase {
        name: "TokenSelectorView"
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

            const tokensKey = "ETH"

            const delegate = findChild(controlUnderTest, "tokenSelectorAssetDelegate_%1".arg(tokensKey))
            verify(!!delegate)

            // click the delegate, verify the signal has been fired and has the correct "tokensKey" as argument
            mouseClick(delegate)
            tryCompare(signalSpy, "count", 1)
            compare(signalSpy.signalArguments[0][0], tokensKey)
        }
    }
}
