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
            assetsModel: adaptor.outputModel

            PaymentRequestAdaptor {
                id: adaptor
                selectedNetworkChainId: paymentRequestModal.selectedNetworkChainId
                flatNetworksModel: d.flatNetworks
                plainTokensBySymbolModel:  ListModel {
                    Component.onCompleted: append(data)
                    readonly property var data: [
                        {
                            key: "ETH",
                            name: "Ether",
                            symbol: "ETH",
                            addressPerChain: [
                                { chainId: 1, address: "0x0000000000000000000000000000000000000000"},
                                { chainId: 5, address: "0x0000000000000000000000000000000000000000"},
                                { chainId: 10, address: "0x0000000000000000000000000000000000000000"},
                                { chainId: 11155420, address: "0x0000000000000000000000000000000000000000"},
                                { chainId: 42161, address: "0x0000000000000000000000000000000000000000"},
                                { chainId: 421614, address: "0x0000000000000000000000000000000000000000"},
                                { chainId: 11155111, address: "0x0000000000000000000000000000000000000000"},
                            ],
                            decimals: 18,
                            type: 1,
                            communityId: "",
                            description: "Ethereum is a decentralized, open-source blockchain platform that enables developers to build and deploy smart contracts and decentralized applications (dApps). It runs on a global network of nodes, making it highly secure and resistant to censorship. Ethereum introduced the concept of programmable money, allowing users to interact with the blockchain through self-executing contracts, also known as smart contracts. Ethereum's native currency, Ether (ETH), powers these contracts and facilitates transactions on the network.",
                            websiteUrl: "https://www.ethereum.org/",
                            marketDetails: {
                                marketCap: ({amount: 250980621528.3937, symbol: "USD", displayDecimals: 2, stripTrailingZeroes: false}),
                                highDay: ({amount: 2090.658790484828, symbol: "USD", displayDecimals: 2, stripTrailingZeroes: false}),
                                lowDay: ({amount: 2059.795033958552, symbol: "USD", displayDecimals: 2, stripTrailingZeroes: false}),
                                changePctHour: 0.3655439934313061,
                                changePctDay: 1.19243897022671,
                                changePct24hour: 0.05209315257442912,
                                change24hour: 0.9121310349524345,
                                currencyPrice: ({amount: 2098.790000016801, symbol: "USD", displayDecimals: 2, stripTrailingZeroes: false})
                            },
                            detailsLoading: false,
                            marketDetailsLoading: false,
                        },
                        {
                            key: "STT",
                            name: "Status Test Token",
                            symbol: "STT",
                            addressPerChain: [
                                {chainId: 5, address: "0x3d6afaa395c31fcd391fe3d562e75fe9e8ec7e6a"},
                                { chainId: 11155420, address: "0x3d6afaa395c31fcd391fe3d562e75fe9e8ec7e6a"},
                                { chainId: 421614, address: "0x3d6afaa395c31fcd391fe3d562e75fe9e8ec7e6a"},
                                { chainId: 11155111, address: "0x3d6afaa395c31fcd391fe3d562e75fe9e8ec7e6a"},
                                { chainId: 10, address: "0x3d6afaa395c31fcd391fe3d562e75fe9e8ec7e6a"},
                            ],
                            decimals: 18,
                            type: 1,
                            communityId: "",
                            description: "Status Network Token (SNT) is a utility token used within the Status.im platform, which is an open-source messaging and social media platform built on the Ethereum blockchain. SNT is designed to facilitate peer-to-peer communication and interactions within the decentralized Status network.",
                            websiteUrl: "https://status.im/",
                            marketDetails: {
                                marketCap: ({amount: 289140007.5701632, symbol: "USD", displayDecimals: 2, stripTrailingZeroes: false}),
                                highDay: ({amount: 0.04361387720794776, symbol: "USD", displayDecimals: 2, stripTrailingZeroes: false}),
                                lowDay: ({amount: 0.0405415571067135, symbol: "USD", displayDecimals: 2, stripTrailingZeroes: false}),
                                changePctHour: 0.7372177058415699,
                                changePctDay: 4.094492504074038,
                                changePct24hour: 5.038796965532456,
                                change24hour: 0.002038287801810013,
                                currencyPrice: ({amount: 0.04258000295521924, symbol: "USD", displayDecimals: 2, stripTrailingZeroes: false})
                            },
                            detailsLoading: false,
                            marketDetailsLoading: false,
                        },
                        {
                            key: "DAI",
                            name: "Dai Stablecoin",
                            symbol: "DAI",
                            addressPerChain: [
                                { chainId: 1, address: "0x6b175474e89094c44da98b954eedeac495271d0f"},
                                { chainId: 10, address: "0xda10009cbd5d07dd0cecc66161fc93d7c9000da1"},
                                { chainId: 42161, address: "0xda10009cbd5d07dd0cecc66161fc93d7c9000da1"},
                                { chainId: 5, address: "0xf2edf1c091f683e3fb452497d9a98a49cba84666"},
                                { chainId: 11155111, address: "0xda10009cbd5d07dd0cecc66161fc93d7c9000da1"},
                                { chainId: 11155420, address: "0xf2edf1c091f683e3fb452497d9a98a49cba84669"},
                                { chainId: 421614, address: "0xf2edf1c091f683e3fb452497d9a98a49cba84666"},
                            ],
                            decimals: 18,
                            type: 1,
                            communityId: "",
                            description: "Dai (DAI) is a decentralized, stablecoin cryptocurrency built on the Ethereum blockchain. It is designed to maintain a stable value relative to the US Dollar, and is backed by a reserve of collateral-backed tokens and other assets. Dai is an ERC-20 token, meaning it is fully compatible with other networks and wallets that support Ethereum-based tokens, making it an ideal medium of exchange and store of value.",
                            websiteUrl: "https://makerdao.com/",
                            marketDetails: {
                                marketCap: ({amount: 3641953745.413845, symbol: "USD", displayDecimals: 2, stripTrailingZeroes: false}),
                                highDay: ({amount: 1.000069852130498, symbol: "USD", displayDecimals: 2, stripTrailingZeroes: false}),
                                lowDay: ({amount: 0.9989457077643417, symbol: "USD", displayDecimals: 2, stripTrailingZeroes: false}),
                                changePctHour: 0.003162399421324529,
                                changePctDay: 0.0008257482387743841,
                                changePct24hour: 0.04426443627508443,
                                change24hour: 0.0004424433543155981,
                                currencyPrice: ({amount: 0.9999000202515163, symbol: "USD", displayDecimals: 2, stripTrailingZeroes: false})
                            },
                            detailsLoading: false,
                            marketDetailsLoading: false
                        }
                    ]
                }
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

            const asset = SQUtils.ModelUtils.get(assetSelector.model, 0)
            verify(!!asset)
            compare(asset.tokensKey, "DAI")
            mouseClick(assetSelector)

            waitForRendering(assetSelector)
            const searchablePanel = findChild(assetSelector, "searchableAssetsPanel")
            verify(!!searchablePanel)
            const assetsList = findChild(searchablePanel, "assetsListView")
            verify(!!assetsList)
            const delegateUnderTest = assetsList.itemAtIndex(0)
            verify(!!delegateUnderTest)
            compare(delegateUnderTest.symbol, "DAI")
            mouseClick(delegateUnderTest)

            compare(controlUnderTest.selectedTokenKey, "DAI")
            compare(assetSelector.contentItem.name, "DAI")

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

        function test_symbol_initial_selection_when_not_available_in_chain() {
            const asset = "STT"
            controlUnderTest = createTemporaryObject(paymentRequestModalComponent, root, { selectedTokenKey: asset, selectedNetworkChainId: Constants.chains.mainnetChainId })
            verify(!!controlUnderTest)

            controlUnderTest.open()
            verify(!!controlUnderTest.opened)

            const assetSelector = findChild(controlUnderTest, "assetSelector")
            verify(!!assetSelector)
            tryCompare(assetSelector.contentItem, "name", "ETH")
            compare(controlUnderTest.selectedTokenKey, "ETH")
        }

        function test_symbol_selection_after_network_change() {
            const asset = "STT"
            controlUnderTest = createTemporaryObject(paymentRequestModalComponent, root, { selectedNetworkChainId: Constants.chains.arbitrumSepoliaChainId, selectedTokenKey: asset })
            verify(!!controlUnderTest)

            controlUnderTest.open()
            verify(!!controlUnderTest.opened)

            compare(controlUnderTest.selectedNetworkChainId, Constants.chains.arbitrumSepoliaChainId)
            compare(controlUnderTest.selectedTokenKey, "STT")
            const assetSelector = findChild(controlUnderTest, "assetSelector")
            verify(!!assetSelector)
            compare(assetSelector.contentItem.name, "STT")

            controlUnderTest.selectedNetworkChainId = Constants.chains.mainnetChainId
            tryCompare(assetSelector.contentItem, "name", "ETH")
            compare(controlUnderTest.selectedTokenKey, "ETH")
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
