import QtQuick 2.15

import StatusQ.Core.Utils 0.1 as SQUtils

import shared.stores 1.0 as SharedStores
import shared.stores.send 1.0 as SharedSendStores

import AppLayouts.stores 1.0 as AppStores
import AppLayouts.Wallet.stores 1.0 as WalletStores
import AppLayouts.Chat.stores 1.0 as ChatStores

import AppLayouts.Wallet.popups.buy 1.0
import AppLayouts.Wallet.popups.swap 1.0
import utils 1.0

// Public API for this object are ONLY `stores` + the main `popupParent`
QtObject {
    id: root

    required property var popupParent

    // Stores definition:
    required property AppStores.RootStore rootStore
    required property AppStores.FeatureFlagsStore featureFlagsStore

    required property SharedStores.RootStore sharedRootStore
    required property SharedStores.CurrenciesStore currencyStore
    required property SharedStores.NetworksStore networksStore
    required property SharedSendStores.TransactionStore transactionStore

    required property var/*TODO: Apply strong typing onces its no longer a singleton*/ walletRootStore
    required property WalletStores.WalletAssetsStore walletAssetsStore
    required property WalletStores.CollectiblesStore walletCollectiblesStore
    required property WalletStores.TransactionStoreNew transactionStoreNew
    required property WalletStores.TokensStore tokensStore

    required property ChatStores.RootStore rootChatStore

    readonly property SwapModalHandler swapModalHandler: SwapModalHandler {

        property SwapInputParamsForm swapFormData: SwapInputParamsForm {}

        function launchSwap() {
            swapFormData.selectedAccountAddress =
                    SQUtils.ModelUtils.get(root.walletRootStore.nonWatchAccounts, 0, "address")
            swapFormData.selectedNetworkChainId =
                    SQUtils.ModelUtils.getByKey(root.networksStore.activeNetworks, "layer", 1, "chainId")
            Global.openSwapModalRequested(swapFormData, (popup) => {
                                              popup.Component.destruction.connect(() => {
                                                                                      swapFormData.resetFormData()
                                                                                  })})
        }

        popupParent: root.popupParent
        walletAssetsStore: root.walletAssetsStore
        currencyStore: root.currencyStore
        networksStore: root.networksStore
        rootStore: root.rootStore
    }

    readonly property SendModalHandler sendModalHandler: SendModalHandler {

        // TODO: Remove this and adapt new mechanism to launch BuyModal as done for SendModal
        property BuyCryptoParamsForm buyFormData: BuyCryptoParamsForm {}

        popupParent: root.popupParent

        loginType: root.rootStore.loginType
        transactionStore: root.transactionStore
        walletCollectiblesStore: root.walletCollectiblesStore
        transactionStoreNew: root.transactionStoreNew
        networksStore: root.networksStore

        // for ens flows
        ensRegisteredAddress: root.rootStore.profileSectionStore.ensUsernamesStore.getEnsRegisteredAddress()
        myPublicKey: root.rootStore.contactStore.myPublicKey
        getStatusTokenKey: function() {
            return root.rootStore.profileSectionStore.ensUsernamesStore.getStatusTokenKey()
        }

        // for sticker flows
        stickersMarketAddress: root.rootChatStore.stickersStore.getStickersMarketAddress()
        stickersNetworkId: root.rootChatStore.appNetworkId

        simpleSendEnabled: root.featureFlagsStore.simpleSendEnabled

        // for simple send
        walletAccountsModel: root.walletRootStore.accounts
        filteredFlatNetworksModel: root.networksStore.activeNetworks
        flatNetworksModel: root.networksStore.allNetworks
        areTestNetworksEnabled: root.networksStore.areTestNetworksEnabled
        groupedAccountAssetsModel: root.walletAssetsStore.groupedAccountAssetsModel
        plainTokensBySymbolModel: root.tokensStore.plainTokensBySymbolModel
        showCommunityAssetsInSend: root.tokensStore.showCommunityAssetsInSend
        collectiblesBySymbolModel: root.walletRootStore.collectiblesStore.jointCollectiblesBySymbolModel
        savedAddressesModel: root.walletRootStore.savedAddresses
        recentRecipientsModel: root.transactionStore.tempActivityController1Model

        isDetailedCollectibleLoading: root.walletCollectiblesStore.isDetailedCollectibleLoading
        detailedCollectible: root.walletCollectiblesStore.detailedCollectible

        currentCurrency: root.currencyStore.currentCurrency
        fnFormatCurrencyAmount: root.currencyStore.formatCurrencyAmount
        fnFormatCurrencyAmountFromBigInt: root.currencyStore.formatCurrencyAmountFromBigInt

        fnResolveENS: function(ensName, uuid) {
            root.rootStore.resolveENS(ensName, uuid)
        }

        fnGetDetailedCollectible: function(chainId, contractAddress, tokenId) {
            root.walletCollectiblesStore.getDetailedCollectible(chainId, contractAddress, tokenId)
        }

        fnResetDetailedCollectible: function() {
            root.walletCollectiblesStore.resetDetailedCollectible()
        }

        fnGetOpenSeaUrl: function(networkShortName) {

            return root.walletRootStore.getOpenSeaUrl(networkShortName)
        }

        onLaunchBuyFlowRequested: {
            buyFormData.selectedWalletAddress = accountAddress
            buyFormData.selectedNetworkChainId = chainId
            buyFormData.selectedTokenKey = tokenKey
            Global.openBuyCryptoModalRequested(buyFormData)
        }

        Component.onCompleted: {
            // It's requested from many nested places, so as a workaround we use
            // Global to shorten the path via global signal.
            Global.sendToRecipientRequested.connect(sendToRecipient)
            root.rootStore.ensNameResolved.connect(ensNameResolved)
        }
    }

    readonly property StatusGifPopupHandler statusGifPopupHandler: StatusGifPopupHandler {
        gifStore: sharedRootStore.gifStore
        gifUnfurlingEnabled: sharedRootStore.gifUnfurlingEnabled
    }
}
