pragma Singleton

import QtQuick 2.13

// Aliasing not to conflict with the shared.stores.RootStore
import shared.stores 1.0 as Stores

import utils 1.0

import SortFilterProxyModel 0.2
import StatusQ.Core.Theme 0.1
import StatusQ.Core.Utils 0.1 as SQUtils

QtObject {
    id: root

    property bool showSavedAddresses: false
    property string selectedAddress: ""
    readonly property bool showAllAccounts: !root.showSavedAddresses && !root.selectedAddress

    property var lastCreatedSavedAddress
    property bool addingSavedAddress: false
    property bool deletingSavedAddress: false

    readonly property TokensStore tokensStore: TokensStore {}
    readonly property WalletAssetsStore walletAssetsStore: WalletAssetsStore {
        walletTokensStore: tokensStore
    }

    /* This property holds address of currently selected account in Wallet Main layout  */
    readonly property var addressFilters: walletSectionInst.addressFilters
    readonly property var keypairImportModule: walletSectionInst.keypairImportModule
    readonly property string signingPhrase: walletSectionInst.signingPhrase
    readonly property string mnemonicBackedUp: walletSectionInst.isMnemonicBackedUp

    /* This property holds networks currently selected in the Wallet Main layout  */
    readonly property var networkFilters: networksModule.enabledChainIds

    readonly property string defaultSelectedKeyUid: userProfile.keyUid
    readonly property bool defaultSelectedKeyUidMigratedToKeycard: userProfile.isKeycardUser

    property string backButtonName: ""
    property var overview: walletSectionOverview
    property bool balanceLoading: overview.balanceLoading
    readonly property var accounts: walletSectionAccounts.accounts
    property var appSettings: localAppSettings
    property var accountSensitiveSettings: localAccountSensitiveSettings
    property bool hideSignPhraseModal: accountSensitiveSettings.hideSignPhraseModal

    property CollectiblesStore collectiblesStore: CollectiblesStore {}

    readonly property bool areTestNetworksEnabled: networksModule.areTestNetworksEnabled
    readonly property bool isGoerliEnabled: profileSectionModule.walletModule.networksModule.isGoerliEnabled

    property var savedAddresses: SortFilterProxyModel {
        sourceModel: walletSectionSavedAddresses.model
        filters: [
            ValueFilter {
                roleName: "isTest"
                value: networksModule.areTestNetworksEnabled
            }
        ]
    }

    property var nonWatchAccounts: SortFilterProxyModel {
        sourceModel: accounts
        proxyRoles: [
            ExpressionRole {
                name: "color"

                function getColor(colorId) {
                    return Utils.getColorForId(colorId)
                }

                // Direct call for singleton function is not handled properly by
                // SortFilterProxyModel that's why helper function is used instead.
                expression: { return getColor(model.colorId) }
            }
        ]
        filters: ValueFilter {
            roleName: "walletType"
            value: Constants.watchWalletType
            inverted: true
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
    readonly property var activityDetailsController: walletSectionInst.activityDetailsController
    readonly property var walletConnectController: walletSectionInst.walletConnectController

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

        property var chainColors: ({})

        function initChainColors(model) {
            for (let i = 0; i < model.count; i++) {
                const item = SQUtils.ModelUtils.get(model, i)
                chainColors[item.shortName] = item.chainColor
            }
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

    function colorForChainShortName(chainShortName) {
        return d.chainColors[chainShortName]
    }

    property var flatNetworks: networksModule.flatNetworks
    property SortFilterProxyModel filteredFlatModel: SortFilterProxyModel {
        sourceModel: root.flatNetworks
        filters: ValueFilter { roleName: "isTest"; value: root.areTestNetworksEnabled }
    }

    onFlatNetworksChanged: {
        d.initChainColors(flatNetworks)
    }

    property var cryptoRampServicesModel: walletSectionBuySellCrypto.model

    function resetCurrentViewedHolding(type) {
        currentViewedHoldingTokensKey = ""
        currentViewedHoldingID = ""
        currentViewedHoldingType = type
    }

    function setCurrentViewedHoldingType(type) {
        currentViewedHoldingTokensKey = ""
        currentViewedHoldingID = ""
        currentViewedHoldingType = type
    }

    function setCurrentViewedHolding(id, tokensKey, type) {
        currentViewedHoldingTokensKey = tokensKey
        currentViewedHoldingID = id
        currentViewedHoldingType = type
    }

    property string currentViewedHoldingTokensKey: ""
    /* TODO: should get rid if this eventually, we shouldnt be using token symbols
    everywhere. Adding a new one currentViewedHoldingTokensKey aboce to not impact send/bridge flows */
    property string currentViewedHoldingID: ""
    property int currentViewedHoldingType
    readonly property var currentViewedCollectible: collectiblesStore.detailedCollectible

    function canProfileProveOwnershipOfProvidedAddresses(addresses) {
        return walletSection.canProfileProveOwnershipOfProvidedAddresses(JSON.stringify(addresses))
    }

    function setHideSignPhraseModal(value) {
        localAccountSensitiveSettings.hideSignPhraseModal = value;
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

    function updateCurrency(newCurrency) {
        walletSection.updateCurrency(newCurrency)
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
            prodPreferredChainIds: "",
            testPreferredChainIds: "",
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
            chainShortNames: "",
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

    function getNameForAddress(address) {
        var name = getNameForWalletAddress(address)
        if (name.length === 0) {
            let savedAddress = getSavedAddress(address)
            name = savedAddress.name
        }
        return name
    }

    enum LookupType {
        Account = 0,
        SavedAddress = 1
    }

    // Returns object of type {type: null, object: null} or null if lookup didn't find anything
    function lookupAddressObject(address) {
        let res = null
        let acc = SQUtils.ModelUtils.getByKey(root.accounts, "address", address)
        if (acc) {
            res = {type: RootStore.LookupType.Account, object: acc}
        } else {
            let sa = SQUtils.ModelUtils.getByKey(walletSectionSavedAddresses.model, "address", address)
            if (sa) {
                res = {type: RootStore.LookupType.SavedAddress, object: sa}
            }
        }

        return res
    }

    function getAssetForSendTx(tx) {
        if (tx.isNFT) {
            return {
                uid: tx.tokenID,
                chainId: tx.chainId,
                name: tx.nftName,
                imageUrl: tx.nftImageUrl,
                collectionUid: "",
                collectionName: ""
            }
        } else {
            return tx.symbol
        }
    }

    function isTxRepeatable(tx) {
        if (!tx || tx.txType !== Constants.TransactionType.Send)
            return false

        let res = root.lookupAddressObject(tx.sender)
        if (!res || res.type !== RootStore.LookupType.Account || res.object.walletType == Constants.watchWalletType)
            return false

        if (tx.isNFT) {
            // TODO #12275: check if account owns enough NFT
        } else {
            // TODO #12275: Check if account owns enough tokens
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

    function createOrUpdateSavedAddress(name, address, ens, colorId, chainShortNames) {
        root.addingSavedAddress = true
        walletSectionSavedAddresses.createOrUpdateSavedAddress(name, address, ens, colorId, chainShortNames)
    }

    function updatePreferredChains(address, chainShortNames) {
        walletSectionSavedAddresses.updatePreferredChains(address, chainShortNames)
    }

    function deleteSavedAddress(address) {
        root.deletingSavedAddress = true
        walletSectionSavedAddresses.deleteSavedAddress(address)
    }

    function savedAddressNameExists(name) {
        return walletSectionSavedAddresses.savedAddressNameExists(name)
    }

    function toggleNetwork(chainId) {
        networksModule.toggleNetwork(chainId)
    }

    function copyToClipboard(text) {
        globalUtils.copyToClipboard(text)
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

    function getAllNetworksChainIds() {
        let result = []
        let chainIdsArray = SQUtils.ModelUtils.modelToFlatArray(root.filteredFlatModel, "chainId")
        for(let i = 0; i< chainIdsArray.length; i++) {
            result.push(chainIdsArray[i].toString())
        }
        return result
    }

    function getNetworkShortNames(chainIds) {
        return networksModule.getNetworkShortNames(chainIds)
    }

    function getNetworkIds(shortNames) {
        return networksModule.getNetworkIds(shortNames)
    }

    function updateWalletAccountPreferredChains(address, preferredChainIds) {
        if(areTestNetworksEnabled) {
            walletSectionAccounts.updateWalletAccountTestPreferredChains(address, preferredChainIds)
        }
        else {
            walletSectionAccounts.updateWalletAccountProdPreferredChains(address, preferredChainIds)
        }
    }

    function updateWatchAccountHiddenFromTotalBalance(address, hideFromTotalBalance) {
        walletSectionAccounts.updateWatchAccountHiddenFromTotalBalance(address, hideFromTotalBalance)
    }

    property Stores.CurrenciesStore currencyStore: Stores.CurrenciesStore {}

    function addressWasShown(address) {
        return d.mainModuleInst.addressWasShown(address)
    }

    function getExplorerDomain(networkShortName) {
        let link = Constants.networkExplorerLinks.etherscan
        if (networkShortName === Constants.networkShortChainNames.mainnet) {
            if (root.areTestNetworksEnabled) {
                if (!root.isGoerliEnabled) {
                    link = Constants.networkExplorerLinks.sepoliaEtherscan
                } else {
                    link = Constants.networkExplorerLinks.goerliEtherscan
                }
            }
        }
        if (networkShortName === Constants.networkShortChainNames.arbitrum) {
            link = Constants.networkExplorerLinks.arbiscan
            if (root.areTestNetworksEnabled) {
                if (!root.isGoerliEnabled) {
                    link = Constants.networkExplorerLinks.sepoliaArbiscan
                } else {
                    link = Constants.networkExplorerLinks.goerliArbiscan
                }
            }
        } else if (networkShortName === Constants.networkShortChainNames.optimism) {
            link = Constants.networkExplorerLinks.optimism
            if (root.areTestNetworksEnabled) {
                if (!root.isGoerliEnabled) {
                    link = Constants.networkExplorerLinks.sepoliaOptimism
                } else {
                    link = Constants.networkExplorerLinks.goerliOptimism
                }
            }
        }
        return link
    }

    function getExplorerUrl(networkShortName, contractAddress, tokenId) {
        let link = getExplorerDomain(networkShortName)
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
        return qsTr("Etherscan Explorer")
    }

    function getOpenSeaNetworkName(networkShortName) {
        let networkName = Constants.openseaExplorerLinks.ethereum
        if (networkShortName === Constants.networkShortChainNames.mainnet) {
            if (root.areTestNetworksEnabled) {
                if (!root.isGoerliEnabled) {
                    networkName = Constants.openseaExplorerLinks.sepoliaEthereum
                } else {
                    networkName = Constants.openseaExplorerLinks.goerliEthereum
                }
            }
        }
        if (networkShortName === Constants.networkShortChainNames.arbitrum) {
            networkName = Constants.openseaExplorerLinks.arbitrum
            if (root.areTestNetworksEnabled) {
                if (!root.isGoerliEnabled) {
                    networkName = Constants.openseaExplorerLinks.sepoliaArbitrum
                } else {
                    networkName = Constants.openseaExplorerLinks.goerliArbitrum
                }
            }
        } else if (networkShortName === Constants.networkShortChainNames.optimism) {
            networkName = Constants.openseaExplorerLinks.optimism
            if (root.areTestNetworksEnabled) {
                if (!root.isGoerliEnabled) {
                    networkName = Constants.openseaExplorerLinks.sepoliaOptimism
                } else {
                    networkName = Constants.openseaExplorerLinks.goerliOptimism
                }
            }
        }
        return networkName
    }

    function getOpenseaDomainName() {
        return root.areTestNetworksEnabled ? Constants.openseaExplorerLinks.testnetLink : Constants.openseaExplorerLinks.mainnetLink
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
}
