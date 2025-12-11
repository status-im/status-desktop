import QtQuick

import utils
import StatusQ
import StatusQ.Core.Utils as SQUtils
import shared.stores
import SortFilterProxyModel

import AppLayouts.Wallet.stores

import Models
import Mocks

// TODO: This store, as all other stores should be empty QtObject {}.
// All mocking should be done in place in Storybook pages and unit tests.
// If it's necessary to share mocks between tests/pages, such mock can be
// created by deriving from empty stub and putting in mocks dir.
// Stores itself should be simple, thin layers over functionality exposed from
// the backend. No additional logic should there. Data transformation logic
// should be delegated to adaptors, stateles helpers to proper utility singletons.
//
// PLEASE DO NOT ADD ANY NEW CONTENT HERE

QtObject {
    id: root

    readonly property CurrenciesStore currencyStore: CurrenciesStore {}

    readonly property var tokensStore: TokensStoreMock {}

    readonly property var accounts: WalletSendAccountsModel {
        Component.onCompleted: selectedSenderAccountAddress = accounts.get(0).address
    }

    property WalletAssetsStore walletAssetStore

    property QtObject tmpActivityController0: QtObject {
        property ListModel model: ListModel{}
    }
    property QtObject tmpActivityController1: QtObject {
        property ListModel model: ListModel{}
    }

    property var flatNetworksModel: NetworksModel.flatNetworks
    property var fromNetworksRouteModel: NetworksModel.sendFromNetworks
    property var toNetworksRouteModel: NetworksModel.sendToNetworks
    property string selectedSenderAccountAddress

    readonly property QtObject walletSectionSendInst: QtObject {
        signal transactionSent(var chainId, var txHash, var uuid, var error)
        signal suggestedRoutesReady(var txRoutes, string errCode, string errDescription)
    }
    readonly property QtObject mainModuleInst: QtObject {
        signal resolvedENS(var resolvedPubKey, var resolvedAddress, var uuid)
    }

    property string selectedAssetKey
    property bool showUnPreferredChains: false
    property int sendType: Constants.SendType.Transfer
    property string selectedRecipient

    readonly property var savedAddressesModel: ListModel {
        Component.onCompleted: {
            for (let i = 0; i < 10; i++)
                append({
                           name: "some saved addr name " + i,
                           ens: [],
                           address: "0x2B748A02e06B159C7C3E98F5064577B96E55A7b4",
                       })
            append({
                       name: "some saved ENS name ",
                       ens: ["me@status.eth"],
                       address: "0xc02aaa39b223fe8d0a0e5c4f27ead9083c756cc4",
                   })
        }
    }

    function splitAndFormatAddressPrefix(textAddress, updateInStore) {
        return {
            formattedText: textAddress,
            address: textAddress
        }
    }

    function resolveENS(value: string) {
        if (!!value && value.endsWith(".eth"))
            root.mainModuleInst.resolvedENS("", "0xc02aaa39b223fe8d0a0e5c4f27ead9083c756cc4", "") // return some valid address
        else
            root.mainModuleInst.resolvedENS("", "", "") // invalid
    }

    function getAsset(assetsList, symbol) {
        const idx = SQUtils.ModelUtils.indexOf(assetsList, "symbol", symbol)
        if (idx < 0) {
            return {}
        }
        return SQUtils.ModelUtils.get(assetsList, idx)
    }

    readonly property string currentCurrency: "USD"

    function getAllNetworksSupportedString() {
        return "OPT"
    }

    function prepareTransactionsForAddress(address) {
        console.log("prepareTransactionsForAddress:", address)
    }

    function getTransactions() {
        return transactions
    }

    readonly property var transactions_: ListModel {
        id: transactions

        Component.onCompleted: {
            for (let i = 0; i < 10; i++)
                append({
                           to: "to",
                           loadingTransaction: false,
                           value: {
                               displayDecimals: true,
                               stripTrailingZeroes: true,
                               amount: 3.234
                           },
                           timestamp: new Date()
                       })
        }
    }

    function setSenderAccount(address) {
        for (let i = 0; i < accounts.count; i++) {
            const acc = accounts.get(i)
            if (acc.address === address && acc.canSend) {
                selectedSenderAccountAddress = acc.address
                break
            }
        }
    }

    function setSendType(sendType) {
        root.sendType = sendType
    }

    function setSelectedRecipient(recipientAddress) {
        root.selectedRecipient = recipientAddress
    }

    function setSelectedAssetKey(assetsKey) {
       root.selectedAssetKey = assetsKey
    }

    function getWei2Eth(wei, decimals) {
        return wei/(10**decimals)
    }

    function updateRoutePreferredChains(chainIds) {
        root.toNetworksRouteModel.updateRoutePreferredChains(chainIds)
    }

    function toggleShowUnPreferredChains() {
        root.showUnPreferredChains = !root.showUnPreferredChains
    }

    function setAllNetworksAsRoutePreferredChains() {
    }

    function setRouteEnabledChain(chainId) {
    }

    function setSelectedTokenIsOwnerToken(isOwnerToken) {
    }

    function setSelectedTokenName(tokenName) {
    }

    property string amountToSend
    property bool suggestedRoutesCalled: false
    function suggestedRoutes(amount) {
        root.amountToSend = amount
        root.suggestedRoutesCalled = true
    }

    function resetStoredProperties() {
        root.amountToSend = ""
        root.sendType = Constants.SendType.Transfer
        root.selectedRecipient = ""
        root.selectedAssetKey = ""
        root.showUnPreferredChains = false
        root.fromNetworksRouteModel.reset()
        root.toNetworksRouteModel.reset()
    }

    function getNetworkName(chainId) {
        return SQUtils.ModelUtils.getByKey(flatNetworksModel, "chainId", chainId, "chainName")
    }

    function formatCurrencyAmountFromBigInt(balance, symbol, decimals, options = null) {
        return currencyStore.formatCurrencyAmountFromBigInt(balance, symbol, decimals, options)
    }
}
