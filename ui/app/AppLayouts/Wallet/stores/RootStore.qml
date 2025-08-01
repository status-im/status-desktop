pragma Singleton

import QtQuick

// Aliasing not to conflict with the shared.stores.RootStore
import shared.stores as SharedStores

import utils

import StatusQ
import SortFilterProxyModel
import StatusQ.Core.Theme
import StatusQ.Core.Utils as SQUtils

QtObject {
    id: root

    property bool showSavedAddresses: false
    property string selectedAddress: ""
    readonly property bool showAllAccounts: !root.showSavedAddresses && !root.selectedAddress

    property var lastCreatedSavedAddress
    property bool addingSavedAddress: false
    property bool deletingSavedAddress: false

    readonly property SharedStores.NetworksStore networksStore: SharedStores.NetworksStore {}

    readonly property TokensStore tokensStore: TokensStore {
        networksStore: root.networksStore
    }
    readonly property WalletAssetsStore walletAssetsStore: WalletAssetsStore {
        walletTokensStore: tokensStore
    }

    /* This property holds address of currently selected account in Wallet Main layout  */
    readonly property var addressFilters: walletSectionInst.addressFilters
    readonly property var keypairImportModule: walletSectionInst.keypairImportModule
    readonly property string mnemonicBackedUp: walletSectionInst.isMnemonicBackedUp

    readonly property var transactionActivityStatus: walletSectionInst.activityController.status


    readonly property string defaultSelectedKeyUid: userProfile.keyUid
    readonly property bool defaultSelectedKeyUidMigratedToKeycard: userProfile.isKeycardUser

    property string backButtonName: ""
    property var overview: walletSectionOverview
    property bool balanceLoading: overview.balanceLoading
    readonly property var accounts: walletSectionAccounts.accounts
    property var appSettings: localAppSettings
    property var accountSensitiveSettings: localAccountSensitiveSettings

    property CollectiblesStore collectiblesStore: CollectiblesStore {}

    readonly property bool areTestNetworksEnabled: networksModule.areTestNetworksEnabled

    property var savedAddresses: SortFilterProxyModel {
        sourceModel: walletSectionSavedAddresses.model
        filters: [
            ValueFilter {
                roleName: "isTest"
                value: root.networksStore.areTestNetworksEnabled
            }
        ]
    }

    property var nonWatchAccounts: SortFilterProxyModel {
        sourceModel: accounts
        proxyRoles: [
            FastExpressionRole {
                name: "color"

                function getColor(colorId) {
                    return Utils.getColorForId(colorId)
                }

                // Direct call for singleton function is not handled properly by
                // SortFilterProxyModel that's why helper function is used instead.
                expression: { return getColor(model.colorId) }
                expectedRoles: ["colorId"]
            }
        ]
        filters: ValueFilter {
            roleName: "canSend"
            value: true
        }
    }

    readonly property var currentActivityFiltersStore: {
        const address = root.overview.mixedcaseAddress
        if (address in d.activityFiltersStoreDictionary) {
            return d.activityFiltersStoreDictionary[address]
        }
        let store = d.activityFilterStoreComponent.createObject(root)
        d.activityFiltersStoreDictionary[address] = store
        return store
    }

    // "walletSection" is a context property slow to lookup, so we cache it here
    readonly property var walletSectionInst: walletSection
    readonly property var totalCurrencyBalance: walletSectionInst.totalCurrencyBalance

    readonly property var activityController: walletSectionInst.activityController
    readonly property var tmpActivityController0: walletSectionInst.tmpActivityController0
    readonly property var tmpActivityController1: walletSectionInst.tmpActivityController1
    readonly property var walletConnectController: walletSectionInst.walletConnectController
    readonly property var dappsConnectorController: walletSectionInst.dappsConnectorController

    readonly property bool isAccountTokensReloading: walletSectionInst.isAccountTokensReloading
    readonly property double lastReloadTimestamp: walletSectionInst.lastReloadTimestamp

    readonly property var historyTransactions: walletSectionInst.activityController.model
    readonly property bool loadingHistoryTransactions: walletSectionInst.activityController.status.loadingData
    readonly property bool newDataAvailable: walletSectionInst.activityController.status.newDataAvailable
    readonly property bool isNonArchivalNode: walletSectionInst.isNonArchivalNode

    signal savedAddressAddedOrUpdated(added: bool, name: string, address: string, errorMsg: string)
    signal savedAddressDeleted(name: string, address: string, errorMsg: string)

    property QtObject _d: QtObject {
        id: d

        readonly property var mainModuleInst: mainModule
        readonly property var walletSectionSavedAddressesInst: walletSectionSavedAddresses

        readonly property Connections walletSectionSavedAddressesConnections: Connections{
            target: walletSectionSavedAddresses

            function onSavedAddressAddedOrUpdated(added: bool, name: string, address: string, errorMsg: string) {
                root.savedAddressAddedOrUpdated(added, name, address , errorMsg);
            }
            function onSavedAddressDeleted(name: string, address: string, errorMsg: string) {
                root.savedAddressDeleted(name, address, errorMsg)
            }
        }

        property var activityFiltersStoreDictionary: ({})
        readonly property Component activityFilterStoreComponent: ActivityFiltersStore{
            tokensList: walletAssetsStore.groupedAccountAssetsModel
        }

        readonly property Connections walletSectionConnections: Connections {
            target: root.walletSectionInst
            function onWalletAccountRemoved(address) {
                address = address.toLowerCase();
                for (var addressKey in d.activityFiltersStoreDictionary){
                    if (address === addressKey.toLowerCase()){
                        delete d.activityFiltersStoreDictionary[addressKey]
                        return
                    }
                }
            }
        }
    }

    function resetCurrentViewedHolding(type) {
        currentViewedHoldingTokensKey = ""
        currentViewedHoldingID = ""
        currentViewedHoldingCommunityId = ""
        currentViewedHoldingType = type
    }

    function setCurrentViewedHoldingType(type) {
        currentViewedHoldingTokensKey = ""
        currentViewedHoldingID = ""
        currentViewedHoldingCommunityId = ""
        currentViewedHoldingType = type
    }

    function setCurrentViewedHolding(id, tokensKey, type, communityId) {
        currentViewedHoldingTokensKey = tokensKey
        currentViewedHoldingID = id
        currentViewedHoldingType = type
        currentViewedHoldingCommunityId = communityId
    }

    property string currentViewedHoldingTokensKey: ""
    /* TODO: should get rid if this eventually, we shouldnt be using token symbols
    everywhere. Adding a new one currentViewedHoldingTokensKey aboce to not impact send/bridge flows */
    property string currentViewedHoldingID: ""
    property int currentViewedHoldingType
    property string currentViewedHoldingCommunityId: ""
    readonly property var currentViewedCollectible: collectiblesStore.detailedCollectible

    function canProfileProveOwnershipOfProvidedAddresses(addresses) {
        return walletSection.canProfileProveOwnershipOfProvidedAddresses(JSON.stringify(addresses))
    }

    function getLatestBlockNumber(chainId) {
        // NOTE returns hex
        return walletSection.getLatestBlockNumber(chainId)
    }

    function getEstimatedLatestBlockNumber(chainId) {
        // NOTE returns decimal
        return walletSection.getEstimatedLatestBlockNumber(chainId)
    }

    function setFilterAddress(address) {
        walletSection.setFilterAddress(address)
    }

    function setFilterAllAddresses() {
        walletSectionInst.setFilterAllAddresses()
    }

    function deleteAccount(address) {
        return walletSectionAccounts.deleteAccount(address)
    }

    function getQrCode(address) {
        return globalUtils.qrCode(address)
    }

    function getNameForWalletAddress(address) {
        return walletSectionAccounts.getNameByAddress(address)
    }

    function getWalletAccount(address) {
        const defaultValue = {
            name: "",
            address: "",
            mixedcaseAddress: "",
            keyUid: "",
            path: "",
            colorId: Constants.walletAccountColors.primary,
            publicKey: "",
            walletType: "",
            isWallet: false,
            isChat: false,
            emoji: "",
            ens: "",
            assetsLoading: false,
            removed: "",
            operable: "",
            createdAt: -1,
            position: -1,
            hideFromTotalBalance: false
        }

        const jsonObj = walletSectionAccounts.getWalletAccountAsJson(address)

        try {
            if (jsonObj === "null" || jsonObj === undefined) {
                return defaultValue
            }
            return JSON.parse(jsonObj)
        }
        catch (e) {
            console.warn("error parsing wallet account for address: ", address, " error: ", e.message)
            return defaultValue
        }
    }

    function getSavedAddress(address) {
        const defaultValue = {
            name: "",
            address: "",
            ens: "",
            colorId: Constants.walletAccountColors.primary,
            isTest: false,
        }

        const jsonObj = d.walletSectionSavedAddressesInst.getSavedAddressAsJson(address)

        try {
            return JSON.parse(jsonObj)
        }
        catch (e) {
            console.warn("error parsing saved address for address: ", address, " error: ", e.message)
            return defaultValue
        }
    }

    function isChecksumValidForAddress(address) {
        return root.walletSectionInst.isChecksumValidForAddress(address)
    }

    function getNameForAddress(address) {
        var name = getNameForWalletAddress(address)
        if (name.length === 0) {
            let savedAddress = getSavedAddress(address)
            name = savedAddress.name
        }
        return name
    }

    function getAssetForSendTx(tx) {
        if (tx.isNFT) {
            return collectiblesStore.getUidForData(tx.tokenID, tx.tokenAddress, tx.chainId)
        }
        return tx.symbol
    }

    function isTxRepeatable(tx) {
        if (!tx || tx.txType !== Constants.TransactionType.Send)
            return false

        let res = SQUtils.ModelUtils.getByKey(root.accounts, "address", tx.sender)
        if (!res || res.walletType === Constants.watchWalletType)
            return false

        if (!tx.amount) {
            // Ignore incorrect transactions
            return false
        }

        if (tx.isNFT && !root.collectiblesStore.hasNFT(tx.sender, tx.chainId, tx.tokenID, tx.tokenAddress)) {
            return false
        }
        return true
    }

    function isOwnedAccount(address) {
        return walletSectionAccounts.isOwnedAccount(address)
    }

    function getEmojiForWalletAddress(address) {
        return walletSectionAccounts.getEmojiByAddress(address)
    }

    function getColorForWalletAddress(address) {
        return walletSectionAccounts.getColorByAddress(address)
    }

    function createOrUpdateSavedAddress(name, address, ens, colorId) {
        root.addingSavedAddress = true
        walletSectionSavedAddresses.createOrUpdateSavedAddress(name, address, ens, colorId)
    }

    function deleteSavedAddress(address) {
        root.deletingSavedAddress = true
        walletSectionSavedAddresses.deleteSavedAddress(address)
    }

    function savedAddressNameExists(name) {
        return walletSectionSavedAddresses.savedAddressNameExists(name)
    }

    function remainingCapacityForSavedAddresses() {
        return walletSectionSavedAddresses.remainingCapacityForSavedAddresses()
    }

    function runAddAccountPopup() {
        walletSection.runAddAccountPopup(false)
    }

    function runAddWatchOnlyAccountPopup() {
        walletSection.runAddAccountPopup(true)
    }

    function runEditAccountPopup(address) {
        walletSection.runEditAccountPopup(address)
    }

    function toggleWatchOnlyAccounts() {
        walletSection.toggleWatchOnlyAccounts()
    }

    function updateWatchAccountHiddenFromTotalBalance(address, hideFromTotalBalance) {
        walletSectionAccounts.updateWatchAccountHiddenFromTotalBalance(address, hideFromTotalBalance)
    }

    property SharedStores.CurrenciesStore currencyStore: SharedStores.CurrenciesStore {} // FIXME pass it down from AppMain instead of recreating it here

    function addressWasShown(address) {
        return d.mainModuleInst.addressWasShown(address)
    }

    function getExplorerUrl(networkShortName, contractAddress, tokenId) {
        let link = Utils.getExplorerDomain(networkShortName)
        if (networkShortName === Constants.networkShortChainNames.mainnet) {
            return "%1/nft/%2/%3".arg(link).arg(contractAddress).arg(tokenId)
        }
        else {
            return "%1/token/%2?a=%3".arg(link).arg(contractAddress).arg(tokenId)
        }
    }

    function getExplorerNameForNetwork(networkShortName)  {
        if (networkShortName === Constants.networkShortChainNames.arbitrum) {
            return qsTr("Arbiscan Explorer")
        }
        if (networkShortName === Constants.networkShortChainNames.optimism) {
            return qsTr("Optimism Explorer")
        }
        if (networkShortName === Constants.networkShortChainNames.base) {
            return qsTr("Base Explorer")
        }
        if (networkShortName === Constants.networkShortChainNames.status) {
            return qsTr("Status Explorer")
        }
        if (networkShortName === Constants.networkShortChainNames.binanceSmartChain) {
            return qsTr("BNB Smart Chain Explorer")
        }
        return qsTr("Etherscan Explorer")
    }

    function getOpenSeaNetworkName(networkShortName) {
        let networkName = Constants.openseaExplorerLinks.ethereum
        if (networkShortName === Constants.networkShortChainNames.mainnet) {
            if (root.areTestNetworksEnabled) {
                networkName = Constants.openseaExplorerLinks.sepoliaEthereum
            }
        }
        if (networkShortName === Constants.networkShortChainNames.arbitrum) {
            networkName = Constants.openseaExplorerLinks.arbitrum
            if (root.areTestNetworksEnabled) {
                networkName = Constants.openseaExplorerLinks.sepoliaArbitrum
            }
        } else if (networkShortName === Constants.networkShortChainNames.optimism) {
            networkName = Constants.openseaExplorerLinks.optimism
            if (root.areTestNetworksEnabled) {
                networkName = Constants.openseaExplorerLinks.sepoliaOptimism
            }
        } else if (networkShortName === Constants.networkShortChainNames.base) {
            networkName = Constants.openseaExplorerLinks.base
            if (root.areTestNetworksEnabled) {
                networkName = Constants.openseaExplorerLinks.sepoliaBase
            }
        }
        return networkName
    }

    function getOpenseaDomainName() {
        return root.areTestNetworksEnabled ? Constants.openseaExplorerLinks.testnetLink : Constants.openseaExplorerLinks.mainnetLink
    }

    function getOpenSeaUrl(networkShortName) {
        let networkName = getOpenSeaNetworkName(networkShortName)
        let baseLink = root.areTestNetworksEnabled ? Constants.openseaExplorerLinks.testnetLink : Constants.openseaExplorerLinks.mainnetLink
         return "%1/assets/%2".arg(baseLink).arg(networkName)
    }

    function getOpenSeaCollectionUrl(networkShortName, contractAddress) {
        let networkName = getOpenSeaNetworkName(networkShortName)
        let baseLink = root.areTestNetworksEnabled ? Constants.openseaExplorerLinks.testnetLink : Constants.openseaExplorerLinks.mainnetLink
        return "%1/assets/%2/%3".arg(baseLink).arg(networkName).arg(contractAddress)
    }

    function getOpenSeaCollectibleUrl(networkShortName, contractAddress, tokenId) {
        let networkName = getOpenSeaNetworkName(networkShortName)
        let baseLink = root.areTestNetworksEnabled ? Constants.openseaExplorerLinks.testnetLink : Constants.openseaExplorerLinks.mainnetLink
        return "%1/assets/%2/%3/%4".arg(baseLink).arg(networkName).arg(contractAddress).arg(tokenId)
    }

    function getTwitterLink(twitterHandle) {
        const prefix = Constants.socialLinkPrefixesByType[Constants.socialLinkType.twitter]
        return prefix + twitterHandle
    }

    function getTransactionType(transaction) {
        if (!transaction)
            return Constants.TransactionType.Send

        // Cross chain Send to another recipient is not a bridge, though involves bridging
        if (transaction.txType == Constants.TransactionType.Bridge && transaction.sender !== transaction.recipient) {
            if (root.showAllAccounts) {
                const addresses = root.addressFilters
                if (addresses.indexOf(transaction.sender) > -1)
                    return Constants.TransactionType.Send

                return Constants.TransactionType.Receive
            }
            return addressesEqual(root.selectedAddress, transaction.sender) ? Constants.TransactionType.Send : Constants.TransactionType.Receive
        }

        return transaction.txType
    }

    function addressesEqual(address1, address2) {
        return address1.toUpperCase() === address2.toUpperCase()
    }

    // TODO: https://github.com/status-im/status-desktop/issues/15329
    // Get DApp data from the backend
    function getDappDetails(chainId, contractAddress) {
        switch (contractAddress) {
            case Constants.swap.paraswapV5ApproveContractAddress:
            case Constants.swap.paraswapV5SwapContractAddress:
                return {
                    "icon": Theme.png("swap/%1".arg(Constants.swap.paraswapIcon)),
                    "url": Constants.swap.paraswapHostname,
                    "name": Constants.swap.paraswapName,
                    "approvalContractAddress": Constants.swap.paraswapV5ApproveContractAddress,
                    "swapContractAddress": Constants.swap.paraswapV5SwapContractAddress,
                }
            case Constants.swap.paraswapV6_2ContractAddress:
                return {
                    "icon": Theme.png("swap/%1".arg(Constants.swap.paraswapIcon)),
                    "url": Constants.swap.paraswapUrl,
                    "name": Constants.swap.paraswapName,
                    "approvalContractAddress": Constants.swap.paraswapV6_2ContractAddress,
                    "swapContractAddress": Constants.swap.paraswapV6_2ContractAddress,
                }
        }
        return undefined
    }

    function resetActivityData() {
        root.walletSectionInst.activityController.resetActivityData()
    }

    function updateTransactionFilterIfDirty() {
        if (root.transactionActivityStatus.isFilterDirty)
            root.walletSectionInst.activityController.updateFilter()
    }

    function fetchDecodedTxData(txHash, input) {
        root.walletSectionInst.fetchDecodedTxData(txHash, input)
    }

    function fetchMoreTransactions() {
        if (root.historyTransactions.count === 0
                || !root.historyTransactions.hasMore
                || root.loadingHistoryTransactions)
            return
        root.walletSectionInst.activityController.loadMoreItems()
    }

    function reloadAccountTokens() {
        root.walletSectionInst.reloadAccountTokens()
    }
}
