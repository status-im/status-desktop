import QtQuick 2.15
import QtQuick.Controls 2.15

import SortFilterProxyModel 0.2

import StatusQ 0.1
import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Core.Utils 0.1 as SQUtils
import StatusQ.Controls 0.1

import AppLayouts.Wallet.stores 1.0 as WalletStores
import AppLayouts.Wallet.popups.simpleSend 1.0
import AppLayouts.Wallet.adaptors 1.0
import AppLayouts.Wallet 1.0

import shared.popups.send 1.0
import shared.stores 1.0 as SharedStores
import shared.stores.send 1.0

import utils 1.0

QtObject {
    id: root

    required property var popupParent
    required property int loginType
    required property TransactionStore transactionStore
    required property WalletStores.CollectiblesStore walletCollectiblesStore
    required property WalletStores.TransactionStoreNew transactionStoreNew
    required property SharedStores.NetworksStore networksStore

    /** for ens flows **/
    required property string myPublicKey
    required property string ensRegisteredAddress
    /** TODO: This should probably be a property and not
    a function. Needs changes on  backend side **/
    property var getStatusTokenKey: function() {}

    /** for sticker flows **/
    required property string stickersMarketAddress
    required property string stickersNetworkId

    /** Feature flag for single network send until its feature complete **/
    required property bool simpleSendEnabled

    /** For simple send modal flows, decoupling from transaction store **/

    /** Expected model structure:
    - name: name of account
    - address: wallet address
    - color: color of the account
    - emoji: emoji selected for the account
    - currencyBalance: total currency balance in CurrencyAmount
    - accountBalance: balance of selected token + selected chain
    **/
    required property var walletAccountsModel
    /** Expected model structure:
    - tokensKey: unique string ID of the token (asset); e.g. "ETH" or contract address
    - name: user visible token name (e.g. "Ethereum")
    - symbol: user visible token symbol (e.g. "ETH")
    - decimals: number of decimal places
    - communityId: optional; ID of the community this token belongs to, if any
    - marketDetails: object containing props like `currencyPrice` for the computed values below
    - balances: submodel[ chainId:int, account:string, balance:BigIntString, iconUrl:string ]
    **/
    required property var groupedAccountAssetsModel
    /** Expected token by symbol model structure:
    - key: id for the token,
    - name: name of the token,
    - symbol: symbol of the token,
    - decimals: decimals for the token
    */
    required property var plainTokensBySymbolModel
    /** Expected model structure:
    - symbol              [string] - unique identifier of a collectible
    - collectionUid       [string] - unique identifier of a collection
    - contractAddress     [string] - collectible's contract address
    - name                [string] - collectible's name e.g. "Magicat"
    - collectionName      [string] - collection name e.g. "Crypto Kitties"
    - mediaUrl            [url]    - collectible's media url
    - imageUrl            [url]    - collectible's image url
    - communityId         [string] - unique identifier of a community for community collectible or empty
    - ownership           [model]  - submodel of balances per chain/account
            - balance         [int]    - balance (always 1 for ERC-721)
            - accountAddress  [string] - unique identifier of an account
    **/
    required property var collectiblesBySymbolModel
    /**
    Expected model structure:
    - chainId: network chain id
    - chainName: name of network
    - iconUrl: network icon url
    networks on both mainnet & testnet
    **/
    required property var flatNetworksModel
    /**
    Expected model structure:
    - chainId: network chain id
    - chainName: name of network
    - iconUrl: network icon url
    networks on either mainnet OR testnet
    **/
    required property var filteredFlatNetworksModel
    /** true if testnet mode is on **/
    required property bool areTestNetworksEnabled
    /** whether community tokens are shown in send modal
    based on a global setting **/
    required property bool showCommunityAssetsInSend

    required property var savedAddressesModel
    required property var recentRecipientsModel

    /** required function to resolve an ens name
    - ensName      [string] - ensName to be resolved
    - uuid         [string] - unique identifier for the request
    **/
    required property var fnResolveENS
    /** required signal to receive resolved ens name address **/
    signal ensNameResolved(string resolvedPubKey, string resolvedAddress, string uuid)

    /** curently selected fiat currency symbol **/
    required property string currentCurrency
    /** required function to format currency amount to locale string
    - amount         [real] - amount to be formatted as a number
    - symbol         [string] - fiat/crypto currency symbol
    **/
    required property var fnFormatCurrencyAmount
    /** required function to format to currency amount from big int
    - amount         [real] - amount to be formatted as a number
    - symbol         [string] - fiat/crypto currency symbol
    - decimals       [int] - decimals of the crypto token
    **/
    required property var fnFormatCurrencyAmountFromBigInt

    /** required property holds the detailed collectible **/
    required property var detailedCollectible
    /** required property holds if collectible details is loading **/
    required property bool isDetailedCollectibleLoading
    /** required function to fetch detailed collectible
      chainId, contractAddress, tokenId
    - chainId           [int] - chainId of collectible
    - contractAddress   [string] - contract address of collectible
    - tokenId           [string] - token id of collectible
    **/
    required property var fnGetDetailedCollectible
    /** required function to reset the detailed collectible **/
    required property var fnResetDetailedCollectible

    /** required function to get openSea explorer url
    - networkShortName      [string] - collectible networks short name
    **/
    required property var fnGetOpenSeaUrl

    /** property to store the params to be updated in the send modal until it is launched **/
    property var simpleSendParams

    /** signal to request launch of buy crypto modal **/
    signal launchBuyFlowRequested(string accountAddress, int chainId, string tokenKey)

    function openSend(params = {}, forceLaunchOldSend = false) {
        // TODO remove once simple send is feature complete
        if(root.simpleSendEnabled && !forceLaunchOldSend) {
            root.simpleSendParams = params
            let sendModalInst = simpleSendModalComponent.createObject(popupParent)
            sendModalInst.open()
        } else {
            let sendModalInst = sendModalComponent.createObject(popupParent, params)
            sendModalInst.open()
        }
    }

    function connectUsername(ensName) {
        let params = {}
        if (root.simpleSendEnabled) {
            params = {
                sendType: Constants.SendType.ENSSetPubKey,
                selectedTokenKey: Constants.ethToken ,
                selectedRawAmount: "0",
                selectedRecipientAddress: root.ensRegisteredAddress,
                interactive: false,
                publicKey: root.myPublicKey,
                ensName: ensName
            }
        } else {
            params = {
                preSelectedSendType: Constants.SendType.ENSSetPubKey,
                preSelectedHoldingID: Constants.ethToken ,
                preSelectedHoldingType: Constants.TokenType.Native,
                preDefinedAmountToSend: LocaleUtils.numberToLocaleString(0),
                preSelectedRecipient: root.ensRegisteredAddress,
                interactive: false,
                publicKey: root.myPublicKey,
                ensName: ensName
            }
        }
        openSend(params)
    }

    function registerUsername(ensName) {
        let params = {}
        if (root.simpleSendEnabled) {
            params = {
                sendType: Constants.SendType.ENSRegister,
                selectedTokenKey: root.getStatusTokenKey(),
                // TODO this should come from backend.To be fixed when ENS is reworked
                selectedRawAmount: SQUtils.AmountsArithmetic.fromNumber(10, 18).toString(),
                selectedRecipientAddress: root.ensRegisteredAddress,
                interactive: false,
                publicKey: root.myPublicKey,
                ensName: ensName
            }
        } else {
            params = {
                preSelectedSendType: Constants.SendType.ENSRegister,
                preSelectedHoldingID: root.getStatusTokenKey(),
                preSelectedHoldingType: Constants.TokenType.ERC20,
                preDefinedAmountToSend: LocaleUtils.numberToLocaleString(10),
                preSelectedRecipient: root.ensRegisteredAddress,
                interactive: false,
                publicKey: root.myPublicKey,
                ensName: ensName
            }
        }
        openSend(params)
    }

    function releaseUsername(ensName, senderAddress, chainId) {
        let params = {}
        if (root.simpleSendEnabled) {
            params = {
                sendType: Constants.SendType.ENSRelease,
                selectedAccountAddress: senderAddress,
                selectedTokenKey: Constants.ethToken ,
                selectedRawAmount: "0",
                selectedChainId: chainId,
                selectedRecipientAddress: root.ensRegisteredAddress,
                interactive: false,
                publicKey: root.myPublicKey,
                ensName: ensName
            }
        } else {
            params = {
                preSelectedSendType: Constants.SendType.ENSRelease,
                preSelectedAccountAddress: senderAddress,
                preSelectedHoldingID: Constants.ethToken ,
                preSelectedHoldingType: Constants.TokenType.Native,
                preDefinedAmountToSend: LocaleUtils.numberToLocaleString(0),
                preSelectedChainId: chainId,
                preSelectedRecipient: root.ensRegisteredAddress,
                interactive: false,
                publicKey: root.myPublicKey,
                ensName: ensName
            }
        }
        openSend(params)
    }

    function buyStickerPack(packId, price) {
        let params = {}
        if (root.simpleSendEnabled) {
            params = {
                sendType: Constants.SendType.StickersBuy,
                selectedTokenKey: root.getStatusTokenKey(),
                selectedRawAmount: SQUtils.AmountsArithmetic.fromNumber(price, 18).toString(),
                selectedChainId: root.stickersNetworkId,
                selectedRecipientAddress: root.stickersMarketAddress,
                interactive: false,
                stickersPackId: packId
            }
        } else {
            params = {
                preSelectedSendType: Constants.SendType.StickersBuy,
                preSelectedHoldingID: root.getStatusTokenKey(),
                preSelectedHoldingType: Constants.TokenType.ERC20,
                preDefinedAmountToSend: LocaleUtils.numberToLocaleString(price),
                preSelectedChainId: root.stickersNetworkId,
                preSelectedRecipient: root.stickersMarketAddress,
                interactive: false,
                stickersPackId: packId
            }
        }
        openSend(params)
    }

    function transferOwnership(tokenId, senderAddress) {
        let selectedChainId =
                    SQUtils.ModelUtils.getByKey(root.collectiblesBySymbolModel, "symbol", tokenId, "chainId")
        let params = {}
        if (root.simpleSendEnabled) {
            params = {
                sendType: Constants.SendType.ERC721Transfer,
                selectedAccountAddress: senderAddress,
                selectedTokenKey: tokenId,
                selectedChainId: selectedChainId,
                transferOwnership: true
            }
        } else {
            params = {
                preSelectedSendType: Constants.SendType.ERC721Transfer,
                preSelectedAccountAddress: senderAddress,
                preSelectedHoldingID: tokenId,
                preSelectedHoldingType:  Constants.TokenType.ERC721,
            }
        }
        openSend(params)
    }

    function sendToRecipient(recipientAddress) {
        let params = {}
        if (root.simpleSendEnabled) {
            params = {
                openReason: "send to recipient"
            }
            params.selectedRecipientAddress = recipientAddress
        } else {
            params = {
                preSelectedRecipient: recipientAddress
            }
        }
        openSend(params)
    }

    function bridgeToken(tokenId, tokenType) {
        let params = {
            preSelectedSendType: Constants.SendType.Bridge,
            preSelectedHoldingID: tokenId ,
            preSelectedHoldingType: tokenType,
            onlyAssets: true
        }
        openSend(params, true)
    }

    function sendToken(senderAddress, tokenId, tokenType) {
        let sendType = Constants.SendType.Transfer
        let selectedChainId = 0
        if (tokenType === Constants.TokenType.ERC721)  {
            sendType = Constants.SendType.ERC721Transfer
            selectedChainId =
                    SQUtils.ModelUtils.getByKey(root.collectiblesBySymbolModel, "symbol", tokenId, "chainId")
        }
        else if(tokenType === Constants.TokenType.ERC1155) {
            sendType = Constants.SendType.ERC1155Transfer
            selectedChainId =
                    SQUtils.ModelUtils.getByKey(root.collectiblesBySymbolModel, "symbol", tokenId, "chainId")
        }
        else {
            let layer1chainId = SQUtils.ModelUtils.getByKey(root.filteredFlatNetworksModel, "layer", "1", "chainId")
            let networksChainIdArray = SQUtils.ModelUtils.modelToFlatArray(root.filteredFlatNetworksModel, "chainId")
            let selectedAssetAddressPerChain =
                SQUtils.ModelUtils.getByKey(root.plainTokensBySymbolModel, "key", tokenId, "addressPerChain")
            // check if layer address is found
            selectedChainId = SQUtils.ModelUtils.getByKey(selectedAssetAddressPerChain, "chainId", layer1chainId, "chainId")
            // if not layer 1 chain id found, select the first one is list
            if (!selectedChainId) {
                selectedChainId = SQUtils.ModelUtils.getFirstModelEntryIf(
                            selectedAssetAddressPerChain,
                            (addPerChain) => {
                                return networksChainIdArray.includes(addPerChain.chainId)
                            })
            }
        }
        let params = {}
        if (root.simpleSendEnabled) {
            params = {
                sendType: sendType,
                selectedAccountAddress: senderAddress,
                selectedTokenKey: tokenId,
                selectedChainId: selectedChainId,
            }
        } else {
            params = {
                preSelectedSendType: sendType,
                preSelectedAccountAddress: senderAddress,
                preSelectedHoldingID: tokenId,
                preSelectedHoldingType: tokenType,
            }
        }
        openSend(params)
    }

    function openTokenPaymentRequest(recipientAddress, symbol, rawAmount, chainId) {
        let params = {}
        if (root.simpleSendEnabled) {
            params = {
                selectedTokenKey: symbol,
                selectedRawAmount: rawAmount,
                selectedChainId: chainId,
                selectedRecipientAddress: recipientAddress,
                interactive: false,
                openReason: "token payment request"
            }
        } else {
            params = {
                preSelectedHoldingID: symbol,
                preSelectedHoldingType: Constants.TokenType.ERC20,
                preDefinedRawAmountToSend: rawAmount,
                preSelectedChainId: chainId,
                preSelectedRecipient: recipientAddress
            }
        }
        openSend(params)
    }

    readonly property Component sendModalComponent: Component {
        SendModal {
            loginType: root.loginType

            store: root.transactionStore
            collectiblesStore: root.walletCollectiblesStore
            networksStore: root.networksStore

            onClosed: destroy()
        }
    }

    readonly property Component simpleSendModalComponent: Component {
        SimpleSendModal {
            id: simpleSendModal

            accountsModel: handler.accountsSelectorAdaptor.processedWalletAccounts
            assetsModel: handler.assetsSelectorViewAdaptor.outputAssetsModel
            flatAssetsModel: root.plainTokensBySymbolModel
            flatCollectiblesModel: handler.collectiblesSelectionAdaptor.filteredFlatModel
            collectiblesModel: handler.collectiblesSelectionAdaptor.model
            networksModel: root.filteredFlatNetworksModel
            recipientsModel: handler.recipientViewAdaptor.recipientsModel
            recipientsFilterModel: handler.recipientViewAdaptor.recipientsFilterModel

            highestTabElementCount: handler.recipientViewAdaptor.highestTabElementCount
            currentCurrency: root.currentCurrency
            fnFormatCurrencyAmount: root.fnFormatCurrencyAmount
            fnResolveENS: root.fnResolveENS

            onOpened: {
                if(isValidParameter(root.simpleSendParams.interactive)) {
                    interactive = root.simpleSendParams.interactive
                }
                if(isValidParameter(root.simpleSendParams.displayOnlyAssets)) {
                    displayOnlyAssets = root.simpleSendParams.displayOnlyAssets
                }
                if(isValidParameter(root.simpleSendParams.sendType)) {
                    sendType = root.simpleSendParams.sendType
                }
                if(isValidParameter(root.simpleSendParams.selectedAccountAddress) &&
                        !!root.simpleSendParams.selectedAccountAddress) {
                    selectedAccountAddress = root.simpleSendParams.selectedAccountAddress
                }
                if(isValidParameter(root.simpleSendParams.selectedTokenKey)) {
                    selectedTokenKey = root.simpleSendParams.selectedTokenKey
                }
                if(isValidParameter(root.simpleSendParams.selectedChainId)) {
                    selectedChainId = root.simpleSendParams.selectedChainId
                }
                if(isValidParameter(root.simpleSendParams.selectedRawAmount)) {
                    selectedRawAmount = root.simpleSendParams.selectedRawAmount
                }
                if(isValidParameter(root.simpleSendParams.selectedRecipientAddress)) {
                    selectedAddress = root.simpleSendParams.selectedRecipientAddress
                }
                if(isValidParameter(root.simpleSendParams.publicKey)) {
                    publicKey = root.simpleSendParams.publicKey
                }
                if(isValidParameter(root.simpleSendParams.ensName)) {
                    ensName = root.simpleSendParams.ensName
                }
                if(isValidParameter(root.simpleSendParams.stickersPackId)) {
                    stickersPackId = root.simpleSendParams.stickersPackId
                }
                if(isValidParameter(root.simpleSendParams.transferOwnership)) {
                    transferOwnership = root.simpleSendParams.transferOwnership
                }
                let metricsData = ""
                if(isValidParameter(root.simpleSendParams.openReason)) {
                    metricsData = root.simpleSendParams.openReason
                } else {
                    metricsData = handler.getSendTypeString()
                }

                handler.sendMetricsEvent("popup opened", metricsData)
            }

            function isValidParameter(param) {
                return param !== undefined && param !== null
            }

            onClosed: {
                handler.sendMetricsEvent("popup closed", "")
                destroy()
                root.transactionStoreNew.stopUpdatesForSuggestedRoute()
            }

            onFormChanged: {
                handler.resetRouterValues()
                if(allValuesFilledCorrectly) {
                    handler.uuid = Utils.uuid()
                    simpleSendModal.routesLoading = true
                    let tokenKey = selectedTokenKey
                    /** TODO: This special handling for collectibles should ideally not
                    be needed, howver is needed because of current implementation and
                    collectible token id is contractAddress:tokenId **/
                    if(sendType === Constants.SendType.ERC1155Transfer ||
                            sendType === Constants.SendType.ERC721Transfer) {
                        const selectedCollectible =
                                                  SQUtils.ModelUtils.getByKey(root.collectiblesBySymbolModel, "symbol", selectedTokenKey)
                        if(!!selectedCollectible &&
                                !!selectedCollectible.contractAddress &&
                                !!selectedCollectible.tokenId) {
                            tokenKey = "%1:%2".arg(
                                        selectedCollectible.contractAddress).arg(
                                        selectedCollectible.tokenId)
                        }
                    }
                    root.transactionStoreNew.fetchSuggestedRoutes(handler.uuid,
                                                                  sendType,
                                                                  selectedChainId,
                                                                  selectedAccountAddress,
                                                                  selectedRecipientAddress,
                                                                  selectedRawAmount,
                                                                  tokenKey,
                                                                  /*amountOut = */ "0",
                                                                  /*toToken =*/ "",
                                                                  /*slippagePercentage*/ "",
                                                                  handler.extraParamsJson)
                }
            }

            onReviewSendClicked: {
                handler.sendMetricsEvent("review send clicked", handler.getSendTypeString())
                if(sendType === Constants.SendType.ERC1155Transfer ||
                        sendType === Constants.SendType.ERC721Transfer) {
                    const selectedCollectible =
                                              SQUtils.ModelUtils.getByKey(root.collectiblesBySymbolModel, "symbol", selectedTokenKey)
                    if(!!selectedCollectible &&
                            !!selectedCollectible.contractAddress &&
                            !!selectedCollectible.tokenId) {
                        root.fnGetDetailedCollectible(simpleSendModal.selectedChainId ,
                                                      selectedCollectible.contractAddress,
                                                      selectedCollectible.tokenId)
                    }
                }

                handler.reviewNext()

                Global.openPopup(sendSignModalCmp)
            }

            onLaunchBuyFlow: {
                root.launchBuyFlowRequested(selectedAccountAddress, selectedChainId, selectedTokenKey)
            }

            ModelEntry {
                id: txPathUnderReviewEntry
                sourceModel: handler.fetchedPathModel
                key: "index"
                value: handler.indexOfTxPathUnderReview
            }

            QtObject {
                id: handler
                property string uuid
                property var fetchedPathModel

                signal refreshTxSettings()

                readonly property string extraParamsJson: {
                    if (!!simpleSendModal.stickersPackId) {
                        return JSON.stringify({[Constants.suggestedRoutesExtraParamsProperties.packId]: simpleSendModal.stickersPackId})
                    }
                    if (!!simpleSendModal.ensName && !!simpleSendModal.publicKey) {
                        return JSON.stringify({[Constants.suggestedRoutesExtraParamsProperties.username]: simpleSendModal.ensName,
                                                  [Constants.suggestedRoutesExtraParamsProperties.publicKey]: simpleSendModal.publicKey})
                    }
                    return ""
                }

                property int indexOfTxPathUnderReview: -1
                readonly property bool reviewingLastTxPath: !!handler.fetchedPathModel && handler.indexOfTxPathUnderReview === handler.fetchedPathModel.ModelCount.count - 1

                property bool approvalForTxPathUnderReviewReviewed: false
                readonly property bool reviewApprovalForTxPathUnderReview: !!txPathUnderReviewEntry.item
                                                                           && txPathUnderReviewEntry.item.approvalRequired
                                                                           && !handler.approvalForTxPathUnderReviewReviewed

                function reviewNext() {
                    if (!handler.reviewApprovalForTxPathUnderReview) {
                        handler.indexOfTxPathUnderReview++
                        handler.approvalForTxPathUnderReviewReviewed = false
                    } else {
                        handler.approvalForTxPathUnderReviewReviewed = true
                    }
                }

                function handleReject() {
                    if (handler.approvalForTxPathUnderReviewReviewed) {
                        handler.approvalForTxPathUnderReviewReviewed = false
                    } else {
                        handler.indexOfTxPathUnderReview--
                    }
                }

                function routesFetched(returnedUuid, pathModel, errCode, errDescription) {
                    simpleSendModal.routesLoading = false
                    if(returnedUuid !== handler.uuid) {
                        // Suggested routes for a different fetch, ignore
                        return
                    }
                    simpleSendModal.routerErrorCode = errCode
                    simpleSendModal.routerError = WalletUtils.getRouterErrorBasedOnCode(errCode)
                    simpleSendModal.routerErrorDetails = "%1 - %2".arg(errCode).arg(
                                WalletUtils.getRouterErrorDetailsOnCode(errCode, errDescription))
                    fetchedPathModel = pathModel
                    handler.refreshTxSettings()
                }

                function transactionSent(returnedUuid, chainId, approvalTx, txHash, error) {
                    if(returnedUuid !== handler.uuid) {
                        // Suggested routes for a different fetch, ignore
                        return
                    }
                    if (!!error) {
                        handleReject()
                        if (error.includes(Constants.walletSection.authenticationCanceled)) {
                            return
                        }
                        simpleSendModal.routerError = error
                        sendMetricsEvent("transaction error")
                        return
                    }
                    sendMetricsEvent("transaction successful")
                    simpleSendModal.close()
                }

                function userSuccessfullyAuthenticated(uuid) {
                    if(uuid !== handler.uuid) {
                        return
                    }
                    simpleSendModal.close()
                }

                function sendMetricsEvent(eventName, data = "") {
                    Global.addCentralizedMetricIfEnabled("send", {subEvent: eventName, data: data})
                }

                function getSendTypeString() {
                    switch(simpleSendModal.sendType) {
                        case Constants.SendType.Transfer:
                            return "Transfer"
                        case Constants.SendType.ENSRegister:
                            return "ENS Register"
                        case Constants.SendType.ENSRelease:
                            return "ENS Release"
                        case Constants.SendType.ENSSetPubKey:
                            return "ENS Set Public Key"
                        case Constants.SendType.StickersBuy:
                            return "Stickers Buy"
                        case Constants.SendType.ERC721Transfer:
                            return "ERC721 Transfer"
                        case Constants.SendType.ERC1155Transfer:
                            return "ERC1155 Transfer"
                        case Constants.SendType.CommunityBurn:
                            return "Community Burn"
                        case Constants.SendType.CommunityDeployAssets:
                            return "Community Deploy Assets"
                        case Constants.SendType.CommunityDeployCollectibles:
                            return "Community Deploy Collectibles"
                        case Constants.SendType.CommunityDeployOwnerToken:
                            return "Community Deploy Owner Token"
                        case Constants.SendType.CommunityMintTokens:
                            return "Community Mint Tokens"
                        case Constants.SendType.CommunityRemoteBurn:
                            return "Community Remote Burn"
                        case Constants.SendType.CommunitySetSignerPubKey:
                            return "Community Set Signer Public Key"
                        case Constants.SendType.Approve:
                            return "Approve"
                        default:
                            return ""
                    }
                }

                readonly property var recipientViewAdaptor: RecipientViewAdaptor {
                    savedAddressesModel: root.savedAddressesModel
                    accountsModel: root.walletAccountsModel
                    recentRecipientsModel: root.recentRecipientsModel

                    selectedSenderAddress: simpleSendModal.selectedAccountAddress
                    selectedRecipientType: simpleSendModal.selectedRecipientType
                    searchPattern: simpleSendModal.recipientSearchPattern
                }

                readonly property var accountsSelectorAdaptor: WalletAccountsSelectorAdaptor {
                    accounts: root.walletAccountsModel
                    assetsModel: root.groupedAccountAssetsModel
                    tokensBySymbolModel: root.plainTokensBySymbolModel
                    filteredFlatNetworksModel: root.filteredFlatNetworksModel

                    selectedTokenKey: simpleSendModal.selectedTokenKey
                    selectedNetworkChainId: simpleSendModal.selectedChainId

                    fnFormatCurrencyAmountFromBigInt: root.fnFormatCurrencyAmountFromBigInt
                }

                readonly property var assetsSelectorViewAdaptor: TokenSelectorViewAdaptor {
                    assetsModel: root.groupedAccountAssetsModel
                    flatNetworksModel: root.flatNetworksModel

                    currentCurrency: root.currentCurrency
                    showCommunityAssets: root.showCommunityAssetsInSend
                    showZeroBalanceForDefaultTokens: true

                    accountAddress: simpleSendModal.selectedAccountAddress
                    enabledChainIds: [simpleSendModal.selectedChainId]
                }

                readonly property var collectiblesSelectionAdaptor: CollectiblesSelectionAdaptor {
                    accountKey: simpleSendModal.selectedAccountAddress
                    enabledChainIds: [simpleSendModal.selectedChainId]

                    networksModel: root.filteredFlatNetworksModel
                    collectiblesModel: SortFilterProxyModel {
                        sourceModel: root.collectiblesBySymbolModel
                        filters: ValueFilter {
                            roleName: "soulbound"
                            value: false
                        }
                    }
                    filterCommunityOwnerAndMasterTokens: !simpleSendModal.transferOwnership
                }

                readonly property var totalFeesAggregator: FunctionAggregator {
                    model: !!handler.fetchedPathModel ?
                               handler.fetchedPathModel: null
                    initialValue: "0"
                    roleName: "txTotalFee"

                    aggregateFunction: (aggr, value) => SQUtils.AmountsArithmetic.sum(
                                           SQUtils.AmountsArithmetic.fromString(aggr),
                                           SQUtils.AmountsArithmetic.fromString(value)).toString()

                    onValueChanged: {
                        const nativeTokenSymbol = Utils.getNativeTokenSymbol(simpleSendModal.selectedChainId)
                        const nativeToken = SQUtils.ModelUtils.getByKey(root.plainTokensBySymbolModel, "key", nativeTokenSymbol)
                        let nativeTokenFiatValue = !!nativeToken ? nativeToken.marketDetails.currencyPrice.amount: 1
                        let totalFees = Utils.nativeTokenRawToDecimal(simpleSendModal.selectedChainId, value)
                        let totalFeesInFiat = root.fnFormatCurrencyAmount(nativeTokenFiatValue*totalFees, root.currentCurrency).toString()
                        simpleSendModal.estimatedCryptoFees = root.fnFormatCurrencyAmount(totalFees.toString(), nativeTokenSymbol)
                        simpleSendModal.estimatedFiatFees = totalFeesInFiat
                    }
                }

                readonly property var estimatedTimeAggregator: FunctionAggregator {
                    model: !!handler.fetchedPathModel ?
                               handler.fetchedPathModel: null
                    initialValue: -1
                    roleName: "estimatedTime"

                    aggregateFunction: (aggr, value) => aggr < value? value : aggr

                    onValueChanged: {
                        simpleSendModal.estimatedTime = WalletUtils.formatEstimatedTime(value)
                    }
                }

                readonly property Connections rootConnections: Connections {
                    target: root
                    function onEnsNameResolved(resolvedPubKey, resolvedAddress, uuid) {
                        simpleSendModal.ensNameResolved(resolvedPubKey, resolvedAddress, uuid)
                    }
                }

                readonly property Connections storeConnections: Connections {
                    target: root.transactionStoreNew

                    function onSuggestedRoutesReady(uuid, pathModel, errCode, errDescription) {
                        handler.routesFetched(uuid, pathModel, errCode, errDescription)
                    }

                    function onTransactionSent(uuid, chainId, approvalTx, txHash, error) {
                        handler.transactionSent(uuid, chainId, approvalTx, txHash, error)
                    }

                    function onSuccessfullyAuthenticated(uuid) {
                        handler.userSuccessfullyAuthenticated(uuid)
                    }
                }

                function resetRouterValues() {
                    root.transactionStoreNew.stopUpdatesForSuggestedRoute()
                    handler.uuid = ""
                    handler.fetchedPathModel = null
                    handler.indexOfTxPathUnderReview = -1
                    simpleSendModal.estimatedCryptoFees = ""
                    simpleSendModal.estimatedFiatFees = ""
                    simpleSendModal.estimatedTime = ""
                    simpleSendModal.routerErrorCode = ""
                    simpleSendModal.routerError = ""
                    simpleSendModal.routerErrorDetails = ""
                }
            }

            SignSendAdaptor {
                id: signSendAdaptor
                accountKey: simpleSendModal.selectedAccountAddress
                accountsModel: root.walletAccountsModel
                recipientModel: handler.recipientViewAdaptor.recipientsModel
                chainId: simpleSendModal.selectedChainId
                networksModel: root.flatNetworksModel
                tokenKey: simpleSendModal.selectedTokenKey
                tokenBySymbolModel: root.plainTokensBySymbolModel
                selectedAmountInBaseUnit: simpleSendModal.selectedRawAmount
                selectedRecipientAddress: simpleSendModal.selectedRecipientAddress
            }

            Component {
                id: sendSignModalCmp
                SendSignModal {
                    closePolicy: Popup.CloseOnEscape
                    destroyOnClose: true
                    // Unused
                    formatBigNumber: function(number, symbol, noSymbolOption) {}

                    tokenSymbol: !!signSendAdaptor.selectedAsset &&
                                     !!signSendAdaptor.selectedAsset.symbol ?
                                         signSendAdaptor.selectedAsset.symbol: ""
                    tokenAmount: signSendAdaptor.selectedAmount
                    tokenContractAddress: signSendAdaptor.selectedAssetContractAddress

                    accountName: signSendAdaptor.selectedAccount.name
                    accountAddress: signSendAdaptor.selectedAccount.address
                    accountEmoji: signSendAdaptor.selectedAccount.emoji
                    accountColor: Utils.getColorForId(signSendAdaptor.selectedAccount.colorId)

                    recipientAddress: signSendAdaptor.recipientAddress
                    recipientName: signSendAdaptor.recipientName
                    recipientEns: signSendAdaptor.recipientEns
                    recipientEmoji: signSendAdaptor.recipientEmoji
                    recipientWalletColor: signSendAdaptor.recipientWalletColor

                    networkShortName: signSendAdaptor.selectedNetwork.shortName
                    networkName: signSendAdaptor.selectedNetwork.chainName
                    networkIconPath: Theme.svg(signSendAdaptor.selectedNetwork.iconUrl)
                    networkBlockExplorerUrl: signSendAdaptor.selectedNetwork.blockExplorerURL
                    networkChainId: signSendAdaptor.selectedNetwork.chainId

                    selectedFeeMode: {
                        if (!!txPathUnderReviewEntry.item) {
                            if (handler.reviewApprovalForTxPathUnderReview) {
                                return txPathUnderReviewEntry.item.approvalGasFeeMode
                            }
                            return txPathUnderReviewEntry.item.txGasFeeMode
                        }
                        return Constants.FeePriorityModeType.Normal
                    }

                    currentBaseFee: !!txPathUnderReviewEntry.item? txPathUnderReviewEntry.item.currentBaseFee : ""
                    currentSuggestedMinPriorityFee: !!txPathUnderReviewEntry.item? txPathUnderReviewEntry.item.suggestedMinPriorityFee : ""
                    currentSuggestedMaxPriorityFee: !!txPathUnderReviewEntry.item? txPathUnderReviewEntry.item.suggestedMaxPriorityFee : ""
                    currentGasAmount: {
                        if (!!txPathUnderReviewEntry.item) {
                            if (handler.reviewApprovalForTxPathUnderReview) {
                                return txPathUnderReviewEntry.item.suggestedApprovalGasAmount
                            }
                            return txPathUnderReviewEntry.item.suggestedTxGasAmount
                        }
                        return ""
                    }
                    currentNonce: {
                        if (!!txPathUnderReviewEntry.item) {
                            if (handler.reviewApprovalForTxPathUnderReview) {
                                return txPathUnderReviewEntry.item.suggestedApprovalTxNonce
                            }
                            return txPathUnderReviewEntry.item.suggestedTxNonce
                        }
                        return 0
                    }

                    fnGetPriceInCurrencyForFee: function(rawFee) {
                        if (!rawFee) {
                            return ""
                        }
                        const feeSymbol = Utils.getNativeTokenSymbol(simpleSendModal.selectedChainId)
                        const decimalFee = Utils.nativeTokenRawToDecimal(simpleSendModal.selectedChainId, rawFee)
                        const feeToken = SQUtils.ModelUtils.getByKey(root.plainTokensBySymbolModel, "key", feeSymbol)
                        const feeTokenPrice = !!feeToken ? feeToken.marketDetails.currencyPrice.amount: 1
                        return root.fnFormatCurrencyAmount(feeTokenPrice*decimalFee, root.currentCurrency).toString()
                    }

                    fnGetEstimatedTime: function(rawBaseFee, rawPriorityFee) {
                        if (!txPathUnderReviewEntry.item) {
                            return ""
                        }
                        const chainId = txPathUnderReviewEntry.item.fromChain
                        return root.transactionStoreNew.getEstimatedTime(chainId, rawBaseFee, rawPriorityFee)
                    }

                    normalPrice: {
                        if (!!txPathUnderReviewEntry.item) {
                            if (handler.reviewApprovalForTxPathUnderReview) {
                                const rawFee = SQUtils.AmountsArithmetic.times(
                                                   SQUtils.AmountsArithmetic.fromString(txPathUnderReviewEntry.item.suggestedMaxFeesPerGasLowLevel),
                                                   SQUtils.AmountsArithmetic.fromString(txPathUnderReviewEntry.item.suggestedApprovalGasAmount)).toFixed()
                                return fnGetPriceInCurrencyForFee(rawFee)
                            }
                            const rawFee = SQUtils.AmountsArithmetic.times(
                                               SQUtils.AmountsArithmetic.fromString(txPathUnderReviewEntry.item.suggestedMaxFeesPerGasLowLevel),
                                               SQUtils.AmountsArithmetic.fromString(txPathUnderReviewEntry.item.suggestedTxGasAmount)).toFixed()
                            return fnGetPriceInCurrencyForFee(rawFee)
                        }
                        return ""
                    }
                    normalBaseFee: !!txPathUnderReviewEntry.item?
                                       SQUtils.AmountsArithmetic.sub(SQUtils.AmountsArithmetic.fromString(txPathUnderReviewEntry.item.suggestedMaxFeesPerGasLowLevel),
                                                                     SQUtils.AmountsArithmetic.fromString(txPathUnderReviewEntry.item.suggestedPriorityFeePerGasLowLevel)).toFixed()
                                     : ""
                    normalPriorityFee: !!txPathUnderReviewEntry.item? txPathUnderReviewEntry.item.suggestedPriorityFeePerGasLowLevel : ""
                    normalTime: !!txPathUnderReviewEntry.item? txPathUnderReviewEntry.item.suggestedEstimatedTimeLowLevel : ""

                    fastPrice: {
                        if (!!txPathUnderReviewEntry.item) {
                            if (handler.reviewApprovalForTxPathUnderReview) {
                                const rawFee = SQUtils.AmountsArithmetic.times(
                                                   SQUtils.AmountsArithmetic.fromString(txPathUnderReviewEntry.item.suggestedMaxFeesPerGasMediumLevel),
                                                   SQUtils.AmountsArithmetic.fromString(txPathUnderReviewEntry.item.suggestedApprovalGasAmount)).toFixed()
                                return fnGetPriceInCurrencyForFee(rawFee)
                            }
                            const rawFee = SQUtils.AmountsArithmetic.times(
                                               SQUtils.AmountsArithmetic.fromString(txPathUnderReviewEntry.item.suggestedMaxFeesPerGasMediumLevel),
                                               SQUtils.AmountsArithmetic.fromString(txPathUnderReviewEntry.item.suggestedTxGasAmount)).toFixed()
                            return fnGetPriceInCurrencyForFee(rawFee)
                        }
                        return ""
                    }
                    fastBaseFee: !!txPathUnderReviewEntry.item?
                                       SQUtils.AmountsArithmetic.sub(SQUtils.AmountsArithmetic.fromString(txPathUnderReviewEntry.item.suggestedMaxFeesPerGasMediumLevel),
                                                                     SQUtils.AmountsArithmetic.fromString(txPathUnderReviewEntry.item.suggestedPriorityFeePerGasMediumLevel)).toFixed()
                                     : ""
                    fastPriorityFee: !!txPathUnderReviewEntry.item? txPathUnderReviewEntry.item.suggestedPriorityFeePerGasMediumLevel : ""
                    fastTime: !!txPathUnderReviewEntry.item? txPathUnderReviewEntry.item.suggestedEstimatedTimeMediumLevel : ""

                    urgentPrice: {
                        if (!!txPathUnderReviewEntry.item) {
                            if (handler.reviewApprovalForTxPathUnderReview) {
                                const rawFee = SQUtils.AmountsArithmetic.times(
                                                   SQUtils.AmountsArithmetic.fromString(txPathUnderReviewEntry.item.suggestedMaxFeesPerGasHighLevel),
                                                   SQUtils.AmountsArithmetic.fromString(txPathUnderReviewEntry.item.suggestedApprovalGasAmount)).toFixed()
                                return fnGetPriceInCurrencyForFee(rawFee)
                            }
                            const rawFee = SQUtils.AmountsArithmetic.times(
                                               SQUtils.AmountsArithmetic.fromString(txPathUnderReviewEntry.item.suggestedMaxFeesPerGasHighLevel),
                                               SQUtils.AmountsArithmetic.fromString(txPathUnderReviewEntry.item.suggestedTxGasAmount)).toFixed()
                            return fnGetPriceInCurrencyForFee(rawFee)
                        }
                        return ""
                    }
                    urgentBaseFee: !!txPathUnderReviewEntry.item?
                                       SQUtils.AmountsArithmetic.sub(SQUtils.AmountsArithmetic.fromString(txPathUnderReviewEntry.item.suggestedMaxFeesPerGasHighLevel),
                                                                     SQUtils.AmountsArithmetic.fromString(txPathUnderReviewEntry.item.suggestedPriorityFeePerGasHighLevel)).toFixed()
                                     : ""
                    urgentPriorityFee: !!txPathUnderReviewEntry.item? txPathUnderReviewEntry.item.suggestedPriorityFeePerGasHighLevel : ""
                    urgentTime: !!txPathUnderReviewEntry.item? txPathUnderReviewEntry.item.suggestedEstimatedTimeHighLevel : ""

                    customBaseFee: {
                        if (!!txPathUnderReviewEntry.item) {
                            if (handler.reviewApprovalForTxPathUnderReview) {
                                return txPathUnderReviewEntry.item.approvalBaseFee
                            }
                            return txPathUnderReviewEntry.item.txBaseFee
                        }
                        return ""
                    }
                    customPriorityFee: {
                        if (!!txPathUnderReviewEntry.item) {
                            if (handler.reviewApprovalForTxPathUnderReview) {
                                return txPathUnderReviewEntry.item.approvalPriorityFee
                            }
                            return txPathUnderReviewEntry.item.txPriorityFee
                        }
                        return ""
                    }
                    customGasAmount: {
                        if (!!txPathUnderReviewEntry.item) {
                            if (handler.reviewApprovalForTxPathUnderReview) {
                                return txPathUnderReviewEntry.item.approvalGasAmount
                            }
                            return txPathUnderReviewEntry.item.txGasAmount
                        }
                        return ""
                    }
                    customNonce: {
                        if (!!txPathUnderReviewEntry.item) {
                            if (handler.reviewApprovalForTxPathUnderReview) {
                                return txPathUnderReviewEntry.item.approvalTxNonce
                            }
                            return txPathUnderReviewEntry.item.txNonce
                        }
                        return ""
                    }

                    readonly property var decimalTotalFees: {
                        let rawTotalFee = "0"
                        if (!!txPathUnderReviewEntry.item) {
                            if (handler.reviewApprovalForTxPathUnderReview) {
                                rawTotalFee = SQUtils.AmountsArithmetic.sum(SQUtils.AmountsArithmetic.fromString(txPathUnderReviewEntry.item.approvalFee),
                                                                             SQUtils.AmountsArithmetic.fromString(txPathUnderReviewEntry.item.approvalL1Fee)).toFixed()
                            } else {
                                rawTotalFee = SQUtils.AmountsArithmetic.sum(SQUtils.AmountsArithmetic.fromString(txPathUnderReviewEntry.item.txFee),
                                                                             SQUtils.AmountsArithmetic.fromString(txPathUnderReviewEntry.item.txL1Fee)).toFixed()
                            }
                        }
                        return Utils.nativeTokenRawToDecimal(simpleSendModal.selectedChainId, rawTotalFee)
                    }

                    fiatFees: {
                        const feeSymbol = Utils.getNativeTokenSymbol(simpleSendModal.selectedChainId)
                        const feeToken = SQUtils.ModelUtils.getByKey(root.plainTokensBySymbolModel, "key", feeSymbol)
                        const feeTokenPrice = !!feeToken ? feeToken.marketDetails.currencyPrice.amount: 1
                        return root.fnFormatCurrencyAmount(feeTokenPrice*decimalTotalFees, root.currentCurrency).toString()
                    }

                    cryptoFees: {
                        const feeSymbol = Utils.getNativeTokenSymbol(simpleSendModal.selectedChainId)
                        return root.fnFormatCurrencyAmount(decimalTotalFees.toString(), feeSymbol)
                    }

                    estimatedTime: {
                        if (!!txPathUnderReviewEntry.item) {
                            if (handler.reviewApprovalForTxPathUnderReview) {
                                return WalletUtils.formatEstimatedTime(txPathUnderReviewEntry.item.approvalEstimatedTime)
                            }
                            return WalletUtils.formatEstimatedTime(txPathUnderReviewEntry.item.txEstimatedTime)
                        }
                        return WalletUtils.formatEstimatedTime(0)
                    }

                    loginType: root.loginType

                    isCollectible: simpleSendModal.sendType === Constants.SendType.ERC1155Transfer ||
                                   simpleSendModal.sendType === Constants.SendType.ERC721Transfer
                    isCollectibleLoading: root.isDetailedCollectibleLoading
                    collectibleContractAddress: root.detailedCollectible.contractAddress
                    collectibleTokenId: root.detailedCollectible.tokenId
                    collectibleName: root.detailedCollectible.name
                    collectibleBackgroundColor: root.detailedCollectible.backgroundColor
                    collectibleIsMetadataValid: root.detailedCollectible.isMetadataValid
                    collectibleMediaUrl: root.detailedCollectible.mediaUrl
                    collectibleMediaType: root.detailedCollectible.mediaType
                    collectibleFallbackImageUrl: root.detailedCollectible.imageUrl

                    fnGetOpenSeaExplorerUrl: root.fnGetOpenSeaUrl

                    Component.onCompleted: {
                        handler.refreshTxSettings.connect(refreshTxSettings)
                    }

                    onOpened: handler.sendMetricsEvent("sign modal opened")
                    closeHandler: function() {
                        handler.handleReject()
                        close()
                    }

                    onUpdateTxSettings: {
                        let pathName = ""
                        let chainId = 0
                        if (!!txPathUnderReviewEntry.item) {
                            pathName = txPathUnderReviewEntry.item.processorName
                            chainId = txPathUnderReviewEntry.item.fromChain
                        }

                        if (selectedFeeMode === Constants.FeePriorityModeType.Custom) {
                            root.transactionStoreNew.setCustomTxDetails(customNonce,
                                                                        customGasAmount,
                                                                        maxFeesPerGas,
                                                                        priorityFee,
                                                                        handler.uuid,
                                                                        pathName,
                                                                        chainId,
                                                                        handler.reviewApprovalForTxPathUnderReview,
                                                                        "")
                            return
                        }

                        root.transactionStoreNew.setFeeMode(selectedFeeMode,
                                                            handler.uuid,
                                                            pathName,
                                                            chainId,
                                                            handler.reviewApprovalForTxPathUnderReview,
                                                            "")
                    }

                    onRejected: {
                        handler.sendMetricsEvent("sign modal rejected")
                        handler.handleReject()
                    }

                    onAccepted: {
                        handler.sendMetricsEvent("sign modal accepted")
                        if (handler.reviewingLastTxPath) {
                            root.transactionStoreNew.authenticateAndTransfer(handler.uuid, simpleSendModal.selectedAccountAddress)
                            return
                        }
                        handler.reviewNext()
                    }
                }
            }
        }
    }
}
