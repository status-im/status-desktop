import QtQuick 2.15

import SortFilterProxyModel 0.2

import StatusQ 0.1
import StatusQ.Core 0.1
import StatusQ.Core.Utils 0.1 as SQUtils

import AppLayouts.Wallet.stores 1.0 as WalletStores
import AppLayouts.Wallet.popups.simpleSend 1.0
import AppLayouts.Wallet.adaptors 1.0
import AppLayouts.Wallet 1.0

import shared.popups.send 1.0
import shared.stores.send 1.0

import utils 1.0

QtObject {
    id: root

    required property var popupParent
    required property int loginType
    required property TransactionStore transactionStore
    required property WalletStores.CollectiblesStore walletCollectiblesStore
    required property WalletStores.TransactionStoreNew transactionStoreNew

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

    /** curently selected fiat currency symbol **/
    required property string currentCurrency
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
    required property var tokenBySymbolModel
    /**
    Expected model structure:
    - chainId: network chain id
    - chainName: name of network
    - iconUrl: network icon url
    networks on both mainnet & testnet
    **/
    required property var flatNetworksModel
    /** true if testnet mode is on **/
    required property bool areTestNetworksEnabled
    /** whether community tokens are shown in send modal
    based on a global setting **/
    required property bool showCommunityAssetsInSend
    /** required function to format currency amount to locale string **/
    required property var fnFormatCurrencyAmount

    required property var savedAddressesModel
    required property var recentRecipientsModel

    /** required function to resolve an ens name **/
    required property var fnResolveENS
    /** required signal to receive resolved ens name address **/
    signal ensNameResolved(string resolvedPubKey, string resolvedAddress, string uuid)

    function openSend(params = {}) {
        // TODO remove once simple send is feature complete
        let sendModalCmp = root.simpleSendEnabled ? simpleSendModalComponent: sendModalComponent
        let sendModalInst = sendModalCmp.createObject(popupParent, params)
        sendModalInst.open()
    }

    function connectUsername(ensName) {
        let params = {
            preSelectedSendType: Constants.SendType.ENSSetPubKey,
            preSelectedHoldingID: Constants.ethToken ,
            preSelectedHoldingType: Constants.TokenType.Native,
            preDefinedAmountToSend: LocaleUtils.numberToLocaleString(0),
            preSelectedRecipient: root.ensRegisteredAddress,
            interactive: false,
            publicKey: root.myPublicKey,
            ensName: ensName
        }
        openSend(params)
    }

    function registerUsername(ensName) {
        let params = {
            preSelectedSendType: Constants.SendType.ENSRegister,
            preSelectedHoldingID: root.getStatusTokenKey(),
            preSelectedHoldingType: Constants.TokenType.ERC20,
            preDefinedAmountToSend: LocaleUtils.numberToLocaleString(10),
            preSelectedRecipient: root.ensRegisteredAddress,
            interactive: false,
            publicKey: root.myPublicKey,
            ensName: ensName
        }
        openSend(params)
    }

    function releaseUsername(ensName, senderAddress, chainId) {
        let params = {
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
        openSend(params)
    }

    function buyStickerPack(packId, price) {
        let params = {
            preSelectedSendType: Constants.SendType.StickersBuy,
            preSelectedHoldingID: root.getStatusTokenKey(),
            preSelectedHoldingType: Constants.TokenType.ERC20,
            preDefinedAmountToSend: LocaleUtils.numberToLocaleString(price),
            preSelectedChainId: root.stickersNetworkId,
            preSelectedRecipient: root.stickersMarketAddress,
            interactive: false,
            stickersPackId: packId
        }
        openSend(params)
    }

    function transferOwnership(tokenId, senderAddress) {
        let params = {
            preSelectedSendType: Constants.SendType.ERC721Transfer,
            preSelectedAccountAddress: senderAddress,
            preSelectedHoldingID: tokenId,
            preSelectedHoldingType:  Constants.TokenType.ERC721,
        }
        openSend(params)
    }

    function sendToRecipient(recipientAddress) {
        let params = {
            preSelectedRecipient: recipientAddress
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
        openSend(params)
    }

    function sendToken(senderAddress, tokenId, tokenType) {
        let sendType = Constants.SendType.Transfer
        if (tokenType === Constants.TokenType.ERC721)  {
            sendType = Constants.SendType.ERC721Transfer
        } else if(tokenType === Constants.TokenType.ERC1155) {
            sendType = Constants.SendType.ERC1155Transfer
        }
        let params = {
            preSelectedSendType: sendType,
            preSelectedAccountAddress: senderAddress,
            preSelectedHoldingID: tokenId ,
            preSelectedHoldingType: tokenType,
        }
        openSend(params)
    }

    readonly property Component sendModalComponent: Component {
        SendModal {
            loginType: root.loginType

            store: root.transactionStore
            collectiblesStore: root.walletCollectiblesStore

            showCustomRoutingMode: !production

            onClosed: destroy()
        }
    }

    readonly property Component simpleSendModalComponent: Component {
        SimpleSendModal {
            id: simpleSendModal

            property string uuid
            property var fetchedPathModel

            /** TODO: use the newly defined WalletAccountsSelectorAdaptor
            in https://github.com/status-im/status-desktop/pull/16834 **/
            accountsModel: root.walletAccountsModel
            assetsModel: assetsSelectorViewAdaptor.outputAssetsModel
            collectiblesModel: collectiblesSelectionAdaptor.model
            networksModel: root.filteredFlatNetworksModel

            savedAddressesModel: root.savedAddressesModel
            recentRecipientsModel: root.recentRecipientsModel

            currentCurrency: root.currentCurrency
            fnFormatCurrencyAmount: root.fnFormatCurrencyAmount
            fnResolveENS: root.fnResolveENS

            onClosed: {
                destroy()
                root.transactionStoreNew.stopUpdatesForSuggestedRoute()
            }

            onFormChanged: {
                resetFees()
                if(allValuesFilledCorrectly()) {
                    uuid = Utils.uuid()
                    root.transactionStoreNew.fetchSuggestedRoutes(uuid,
                                                                  sendType,
                                                                  selectedChainId,
                                                                  selectedAccountAddress,
                                                                  selectedRecipientAddress,
                                                                  selectedAmountInBaseUnit,
                                                                  selectedTokenKey)
                }
            }

            // TODO: this should be called from the Reiew and Sign Modal instead
            onReviewSendClicked: {
                root.transactionStoreNew.authenticateAndTransfer(uuid, selectedAccountAddress)
            }

            function routesFetched(rUuid, pathModel, errCode, errDescription) {
                if(rUuid !== uuid) {
                    // Suggested routes for a different fetch, ignore
                    return
                }
                fetchedPathModel = pathModel
                // TODO: Handle errors here
            }

            TokenSelectorViewAdaptor {
                id: assetsSelectorViewAdaptor

                // TODO: remove all store dependecies and add specific properties to the handler instead
                assetsModel: root.groupedAccountAssetsModel
                flatNetworksModel: root.flatNetworksModel

                currentCurrency: root.currentCurrency
                showCommunityAssets: root.showCommunityAssetsInSend

                accountAddress: simpleSendModal.selectedAccountAddress
                enabledChainIds: [simpleSendModal.selectedChainId]
            }
            CollectiblesSelectionAdaptor {
                id: collectiblesSelectionAdaptor

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
            }

            FunctionAggregator {
                id: totalBalanceAggregator

                model: !!simpleSendModal.fetchedPathModel  &&
                       simpleSendModal.fetchedPathModel.ModelCount.count > 0 ?
                           simpleSendModal.fetchedPathModel: null
                initialValue: "0"
                roleName: "txTotalFee"

                aggregateFunction: (aggr, value) => SQUtils.AmountsArithmetic.sum(
                                       SQUtils.AmountsArithmetic.fromString(aggr),
                                       SQUtils.AmountsArithmetic.fromString(value)).toString()

                onValueChanged: {
                    let decimals = !!selectedTokenEntry.item ? selectedTokenEntry.item.decimals: 18
                    let ethFiatValue = !!ethTokenEntry.item ? ethTokenEntry.item.marketDetails.currencyPrice.amount: 1
                    let totalFees = SQUtils.AmountsArithmetic.div(SQUtils.AmountsArithmetic.fromString(value), SQUtils.AmountsArithmetic.fromNumber(1, decimals))
                    let totalFeesInFiat = root.fnFormatCurrencyAmount(ethFiatValue*totalFees, root.currentCurrency).toString()
                    simpleSendModal.estimatedCryptoFees = root.fnFormatCurrencyAmount(totalFees.toString(), Constants.ethToken)
                    simpleSendModal.estimatedFiatFees = totalFeesInFiat
                }
            }

            SumAggregator {
                id: estimatedTimeAggregator

                model: !!simpleSendModal.fetchedPathModel  &&
                       simpleSendModal.fetchedPathModel.ModelCount.count > 0 ?
                           simpleSendModal.fetchedPathModel: null
                roleName: "estimatedTime"
                onValueChanged: {
                    simpleSendModal.estimatedTime = WalletUtils.getLabelForEstimatedTxTime(value)
                }
            }

            ModelEntry {
                id: selectedTokenEntry
                sourceModel: root.tokenBySymbolModel
                key: "key"
                value: simpleSendModal.selectedTokenKey
            }

            ModelEntry {
                id: ethTokenEntry
                sourceModel: root.tokenBySymbolModel
                key: "key"
                value: Constants.ethToken
            }

            Component.onCompleted: {
                root.ensNameResolved.connect(ensNameResolved)
                root.transactionStoreNew.suggestedRoutesReady.connect(routesFetched)
            }
        }
    }

    readonly property var filteredFlatNetworksModel: SortFilterProxyModel {
        sourceModel: root.flatNetworksModel
        filters: ValueFilter { roleName: "isTest"; value: root.areTestNetworksEnabled }
    }
}
