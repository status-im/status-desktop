import QtQuick 2.15
import QtTest 1.15

import StatusQ.Core 0.1
import StatusQ.Core.Utils 0.1 as SQUtils
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1

import QtQuick.Controls 2.15

import Models 1.0
import Storybook 1.0

import utils 1.0

import AppLayouts.Wallet.stores 1.0 as WalletStores
import AppLayouts.Wallet.adaptors 1.0
import AppLayouts.Chat.popups 1.0
import shared.stores 1.0 as SharedStores

Item {
    id: root
    width: 800
    height: 600

    QtObject {
        id: d

        readonly property var accounts: WalletAccountsModel {}
        readonly property var flatNetworks: NetworksModel.flatNetworks
    }

    Component {
        id: paymentRequestModalComponent
        PaymentRequestModal {
            id: paymentRequestModal
            destroyOnClose: true

            readonly property SharedStores.CurrenciesStore currencyStore: SharedStores.CurrenciesStore {}

            currentCurrency: currencyStore.currentCurrency
            formatCurrencyAmount: currencyStore.formatCurrencyAmount
            flatNetworksModel: d.flatNetworks
            accountsModel: d.accounts
            assetsModel: ListModel {
                Component.onCompleted: append([{
                                                   tokensKey: "ETH",
                                                   name: "eth",
                                                   symbol: "ETH",
                                                   chainId: NetworksModel.ethNet,
                                                   address: "0xbbc200",
                                                   decimals: "18",
                                                   iconSource: ModelsData.assets.eth,
                                                   marketDetails: {
                                                       currencyPrice: {
                                                           amount: 1,
                                                           displayDecimals: true
                                                       }
                                                   }
                                               },
                                               {
                                                   tokensKey: "SNT",
                                                   name: "snt",
                                                   symbol: "SNT",
                                                   chainId: NetworksModel.ethNet,
                                                   address: "0xbbc2000000000000000000000000000000000123",
                                                   decimals: "18",
                                                   iconSource: ModelsData.assets.snt,
                                                   marketDetails: {
                                                       currencyPrice: {
                                                           amount: 1,
                                                           displayDecimals: true
                                                       }
                                                   }
                                               },
                                               {
                                                   tokensKey: "DAI",
                                                   name: "dai",
                                                   symbol: "DAI",
                                                   chainId: NetworksModel.ethNet,
                                                   address: "0xbbc2000000000000000000000000000000550567",
                                                   decimals: "2",
                                                   iconSource: ModelsData.assets.dai,
                                                   marketDetails: {
                                                       currencyPrice: {
                                                           amount: 1,
                                                           displayDecimals: true
                                                       }
                                                   }
                                               }])
            }
        }
    }

    TestCase {
        name: "PaymentRequestModal"
        when: windowShown

        property PaymentRequestModal controlUnderTest: null

        // helper functions -------------------------------------------------------------
        function launchAndVerfyModal() {
            controlUnderTest = createTemporaryObject(paymentRequestModalComponent, root)
            verify(!!controlUnderTest)
            controlUnderTest.open()
            waitForRendering(controlUnderTest.contentItem)
            verify(!!controlUnderTest.opened)
        }

        function closeAndVerfyModal() {
            verify(!!controlUnderTest)
            controlUnderTest.close()
            verify(!controlUnderTest.opened)
        }
        // end helper functions -------------------------------------------------------------

        function test_default_values() {
            launchAndVerfyModal()

            const button = findChild(controlUnderTest, "addButton")
            verify(!!button)
            verify(!button.enabled)

            compare(controlUnderTest.selectedTokenKey, Constants.ethToken)
            const assetSelector = findChild(controlUnderTest, "assetSelector")
            verify(!!assetSelector)
            verify(assetSelector.isSelected)
            verify(assetSelector.contentItem.selected)
            compare(assetSelector.contentItem.name, Constants.ethToken)

            compare(controlUnderTest.selectedNetworkChainId, Constants.chains.mainnetChainId)
            const networkSelector = findChild(controlUnderTest, "networkSelector")
            verify(!!networkSelector)
            compare(networkSelector.control.contentItem.title, Constants.networkMainnet)
            compare(networkSelector.count, d.flatNetworks.count)

            compare(controlUnderTest.selectedAccountAddress, d.accounts.data[0].address)
            const accountSelector = findChild(controlUnderTest, "accountSelector")
            verify(!!accountSelector)
            compare(accountSelector.control.contentItem.name, d.accounts.data[0].name)
            compare(accountSelector.count, d.accounts.data.length)

            compare(controlUnderTest.amount, "0")
            const amountInput = findChild(controlUnderTest, "amountInput")
            verify(!!amountInput)
            compare(amountInput.text, "")

            closeAndVerfyModal()
        }

        function test_change_amount() {
            launchAndVerfyModal()

            const amountInput = findChild(controlUnderTest, "amountInput")
            verify(!!amountInput)

            const amount = "1.24"
            amountInput.setValue(amount)
            compare(amountInput.text, amount)
            compare(controlUnderTest.amount, "1240000000000000000") // Raw amount is returned

            closeAndVerfyModal()
        }

        function test_change_address() {
            launchAndVerfyModal()

            const accountSelector = findChild(controlUnderTest, "accountSelector")
            verify(!!accountSelector)

            const account = d.accounts.data[1]
            mouseClick(accountSelector)
            verify(accountSelector.control.popup.opened)
            waitForRendering(accountSelector.control.popup.contentItem)
            const delegateUnderTest = accountSelector.control.popup.contentItem.itemAtIndex(1)
            verify(!!delegateUnderTest)
            mouseClick(delegateUnderTest)
            verify(!accountSelector.control.popup.opened)

            compare(controlUnderTest.selectedAccountAddress, account.address)
            compare(accountSelector.control.contentItem.name, account.name)

            closeAndVerfyModal()
        }

        function test_change_symbol() {
            launchAndVerfyModal()

            const assetSelector = findChild(controlUnderTest, "assetSelector")
            verify(!!assetSelector)
            compare(controlUnderTest.selectedTokenKey, "ETH")
            compare(assetSelector.contentItem.name, "ETH")

            const asset = SQUtils.ModelUtils.get(assetSelector.model, 2)
            verify(!!asset)
            mouseClick(assetSelector)

            waitForRendering(assetSelector)
            const searchablePanel = findChild(assetSelector, "searchableAssetsPanel")
            verify(!!searchablePanel)
            const assetsList = findChild(searchablePanel, "assetsListView")
            verify(!!assetsList)
            const delegateUnderTest = assetsList.itemAtIndex(2)
            verify(!!delegateUnderTest)
            mouseClick(delegateUnderTest)

            compare(controlUnderTest.selectedTokenKey, asset.tokensKey)
            compare(assetSelector.contentItem.name, asset.symbol)

            closeAndVerfyModal()
        }

        function test_change_network() {
            launchAndVerfyModal()

            const networkSelector = findChild(controlUnderTest, "networkSelector")
            verify(!!networkSelector)

            const network = d.flatNetworks.get(1)
            mouseClick(networkSelector)
            verify(networkSelector.control.popup.opened)
            waitForRendering(networkSelector.control.popup.contentItem)
            const delegateUnderTest = networkSelector.control.popup.contentItem.itemAtIndex(1)
            verify(!!delegateUnderTest)
            mouseClick(delegateUnderTest)
            verify(!networkSelector.control.popup.opened)

            compare(controlUnderTest.selectedNetworkChainId, network.chainId)
            compare(networkSelector.control.contentItem.title, network.chainName)

            closeAndVerfyModal()
        }

        function test_open_initial_account_address() {
            const account = d.accounts.data[1]
            controlUnderTest = createTemporaryObject(paymentRequestModalComponent, root, { selectedAccountAddress: account.address })
            verify(!!controlUnderTest)

            controlUnderTest.open()
            verify(!!controlUnderTest.opened)

            compare(controlUnderTest.selectedAccountAddress, account.address)
            const accountSelector = findChild(controlUnderTest, "accountSelector")
            verify(!!accountSelector)
            compare(accountSelector.control.contentItem.name, account.name)

            closeAndVerfyModal()
        }

        function test_open_initial_network() {
            const network = d.flatNetworks.get(2)
            controlUnderTest = createTemporaryObject(paymentRequestModalComponent, root, { selectedNetworkChainId: network.chainId })
            verify(!!controlUnderTest)

            controlUnderTest.open()
            verify(!!controlUnderTest.opened)

            compare(controlUnderTest.selectedNetworkChainId, network.chainId)
            const networkSelector = findChild(controlUnderTest, "networkSelector")
            verify(!!networkSelector)
            compare(networkSelector.control.contentItem.title, network.chainName)

            closeAndVerfyModal()
        }

        function test_open_initial_asset() {
            const asset = "DAI"
            controlUnderTest = createTemporaryObject(paymentRequestModalComponent, root, { selectedTokenKey: asset })
            verify(!!controlUnderTest)

            controlUnderTest.open()
            verify(!!controlUnderTest.opened)

            compare(controlUnderTest.selectedTokenKey, asset)
            const assetSelector = findChild(controlUnderTest, "assetSelector")
            verify(!!assetSelector)
            verify(assetSelector.isSelected)
            verify(assetSelector.contentItem.selected)
            compare(assetSelector.contentItem.name, asset)

            closeAndVerfyModal()
        }

        function test_accept_button_enabled_state() {
            launchAndVerfyModal()

            const button = findChild(controlUnderTest, "addButton")
            verify(!!button)

            verify(!button.enabled, "Enabled by default because default amount is 0")

            const amountInput = findChild(controlUnderTest, "amountInput")
            verify(!!amountInput)
            amountInput.setValue("1.24")
            verify(button.enabled, "All values are filled")
            amountInput.setValue("0")
            verify(!button.enabled, "Amount cannot be 0")

            amountInput.setValue("2")
            verify(button.enabled)

            // Below scenarios are unlikely to happen in real life, but we should test them anyway.
            // This might produce warnings in the console, but it's fine.

            // Check if button changes after network is changed
            controlUnderTest.selectedNetworkChainId = 0
            verify(!button.enabled)
            controlUnderTest.selectedNetworkChainId = d.flatNetworks.get(1).chainId
            verify(button.enabled)

            // Check if button changes after account is changed
            controlUnderTest.selectedAccountAddress = ""
            verify(!button.enabled)
            controlUnderTest.selectedAccountAddress = d.accounts.data[1].address
            verify(button.enabled)

            // Check if button changes after symbol is changed
            controlUnderTest.selectedTokenKey = ""
            verify(!button.enabled)
            controlUnderTest.selectedTokenKey = "DAI"
            verify(button.enabled)

            closeAndVerfyModal()
        }
    }
}
