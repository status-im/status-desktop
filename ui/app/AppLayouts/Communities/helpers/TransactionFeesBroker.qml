import QtQuick

import shared.stores

import StatusQ.Core.Utils
import AppLayouts.Wallet

import utils

QtObject {
    id: root

    enum FeeType {
        Airdrop,
        Deploy,
        SelfDestruct,
        Burn,
        SetSigner
    }

    property CommunityTokensStore communityTokensStore
    property alias active: feesBroker.active

    property QtObject d: QtObject {
        id: internal

        component AirdropFeeSubscription: Subscription {
            required property AirdropFeesSubscriber subscriber
            readonly property var requestArgs: ({
                type: TransactionFeesBroker.FeeType.Airdrop,
                communityId: subscriber.communityId,
                contractKeysAndAmounts: subscriber.contractKeysAndAmounts,
                addressesToAirdrop: subscriber.addressesToAirdrop,
                feeAccountAddress: subscriber.feeAccountAddress
            })

            isReady: !!subscriber.communityId &&
                    !!subscriber.contractKeysAndAmounts &&
                    !!subscriber.addressesToAirdrop &&
                    !!subscriber.feeAccountAddress &&
                    subscriber.contractKeysAndAmounts.length &&
                    subscriber.addressesToAirdrop.length &&
                    subscriber.enabled

            topic: isReady ? JSON.stringify(requestArgs) : ""
            onResponseChanged: subscriber.airdropFeesResponse = response
        }

        component DeployFeeSubscription: Subscription {
            required property DeployFeesSubscriber subscriber
            readonly property var requestArgs: ({
                type: TransactionFeesBroker.FeeType.Deploy,
                communityId: subscriber.communityId,
                chainId: subscriber.chainId,
                accountAddress: subscriber.accountAddress,
                tokenType: subscriber.tokenType,
                isOwnerDeployment: subscriber.isOwnerDeployment,
                ownerToken: subscriber.ownerToken,
                masterToken: subscriber.masterToken,
                token: subscriber.token
            })

            isReady: !!subscriber.chainId && 
                    !!subscriber.accountAddress && 
                    !!subscriber.tokenType && 
                    subscriber.enabled

            topic: isReady ? JSON.stringify(requestArgs) : ""
            onResponseChanged: subscriber.feesResponse = response
        }

        component SelfDestructFeeSubscription: Subscription {
            required property SelfDestructFeesSubscriber subscriber
            readonly property var requestArgs: ({
                type: TransactionFeesBroker.FeeType.SelfDestruct,
                walletsAndAmounts:subscriber.walletsAndAmounts,
                tokenKey: subscriber.tokenKey,
                accountAddress: subscriber.accountAddress,
            })
            isReady: !!subscriber.walletsAndAmounts && 
                    !!subscriber.tokenKey && 
                    !!subscriber.accountAddress && 
                    subscriber.walletsAndAmounts.length &&
                    subscriber.enabled

            topic: isReady ? JSON.stringify(requestArgs) : ""
            onResponseChanged: subscriber.feesResponse = response
        }

        component BurnTokenFeeSubscription: Subscription {
            required property BurnTokenFeesSubscriber subscriber
            readonly property var requestArgs: ({
                type: TransactionFeesBroker.FeeType.Burn,
                tokenKey: subscriber.tokenKey,
                amount: subscriber.amount,
                accountAddress: subscriber.accountAddress
            })
            isReady: !!subscriber.tokenKey && 
                    !!subscriber.amount && 
                    !!subscriber.accountAddress &&
                    subscriber.enabled

            topic: isReady ? JSON.stringify(requestArgs) : ""
            onResponseChanged: subscriber.feesResponse = response
        }

        component SetSignerFeeSubscription: Subscription {
            required property SetSignerFeesSubscriber subscriber
            readonly property var requestArgs: ({
                communityId: subscriber.communityId,
                type: TransactionFeesBroker.FeeType.SetSigner,
                chainId: subscriber.chainId,
                contractAddress: subscriber.contractAddress,
                accountAddress: subscriber.accountAddress
            })
            isReady: !!subscriber.communityId &&
                    !!subscriber.chainId &&
                    !!subscriber.contractAddress &&
                    !!subscriber.accountAddress &&
                    subscriber.enabled

            topic: isReady ? JSON.stringify(requestArgs) : ""
            onResponseChanged: subscriber.feesResponse = response
        }

        readonly property Component airdropFeeSubscriptionComponent: AirdropFeeSubscription {}
        readonly property Component deployFeeSubscriptionComponent: DeployFeeSubscription {}
        readonly property Component selfDestructFeeSubscriptionComponent: SelfDestructFeeSubscription {}
        readonly property Component burnFeeSubscriptionComponent: BurnTokenFeeSubscription {}
        readonly property Component setSignerFeeSubscriptionComponent: SetSignerFeeSubscription {}

        readonly property SubscriptionBrokerCommunities feesBroker: SubscriptionBrokerCommunities {
            id: feesBroker

            onRequest: internal.computeFee(subscriptionId, topic)
        }

        property Connections communityTokensStoreConnections: Connections {
            target: root.communityTokensStore.communityTokensModuleInst

            function onSuggestedRoutesReady(uuid, nativeCryptoCurrency, fiatCurrency, costPerPath, errCode, errDescription) {
                let err = ""
                if(!!errCode || !!errDescription) {
                    err = "%1 - %2".arg(errCode).arg(WalletUtils.getRouterErrorDetailsOnCode(errCode, errDescription))
                }

                let jsonFees = [{
                                    nativeCryptoFee: {},
                                    fiatFee: {},
                                    contractUniqueKey: ""
                                }]

                if (!err && !!costPerPath) {
                    try {
                        jsonFees = JSON.parse(costPerPath)
                    }
                    catch (e) {
                        console.info("parsing fees issue: ", e.message)
                    }
                }

                d.feesBroker.response(uuid, { nativeCryptoCurrency: nativeCryptoCurrency, fiatCurrency: fiatCurrency, fees: jsonFees, error: err })
            }




        }

        function computeFee(subscriptionId, topic) {
            const args = JSON.parse(topic)
            switch (args.type) {
                case TransactionFeesBroker.FeeType.Airdrop:
                    computeAirdropFee(subscriptionId, args)
                    break
                case TransactionFeesBroker.FeeType.Deploy:
                    computeDeployFee(subscriptionId, args)
                    break
                case TransactionFeesBroker.FeeType.SelfDestruct:
                    computeSelfDestructFee(subscriptionId, args)
                    break
                case TransactionFeesBroker.FeeType.Burn:
                    computeBurnFee(subscriptionId, args)
                    break
                case TransactionFeesBroker.FeeType.SetSigner:
                    computeSetSignerFee(subscriptionId, args)
                    break
                default:
                    console.error("Unknown fee type: " + args.type)
            }
        }

        function computeAirdropFee(subscriptionId, args) {
            communityTokensStore.computeAirdropFee(
                        subscriptionId,
                        args.communityId,
                        args.contractKeysAndAmounts,
                        args.addressesToAirdrop,
                        args.feeAccountAddress)
        }

        function computeDeployFee(subscriptionId, args) {
            if (args.isOwnerDeployment) {
                communityTokensStore.computeDeployTokenOwnerFee(
                            subscriptionId,
                            args.communityId,
                            args.ownerToken.chainId,
                            args.ownerToken.accountAddress,
                            args.ownerToken.name,
                            args.ownerToken.symbol,
                            args.ownerToken.description,
                            args.ownerToken.artworkSource,
                            args.ownerToken.artworkCropRect,
                            args.masterToken.name,
                            args.masterToken.symbol,
                            args.masterToken.description)
                return
            }

            if (args.tokenType === Constants.TokenType.ERC721) {
                communityTokensStore.computeDeployCollectiblesFee(
                            subscriptionId,
                            args.communityId,
                            args.token.key,
                            args.token.chainId,
                            args.token.accountAddress,
                            args.token.name,
                            args.token.symbol,
                            args.token.description,
                            args.token.supply,
                            args.token.infiniteSupply,
                            args.token.transferable,
                            args.token.remotelyDestruct,
                            args.token.artworkSource,
                            args.token.artworkCropRect)
                return

            }

            communityTokensStore.computeDeployAssetsFee(
                        subscriptionId,
                        args.communityId,
                        args.token.key,
                        args.token.chainId,
                        args.token.accountAddress,
                        args.token.name,
                        args.token.symbol,
                        args.token.description,
                        args.token.supply,
                        args.token.infiniteSupply,
                        args.token.decimals,
                        args.token.artworkSource,
                        args.token.artworkCropRect)
        }

        function computeSelfDestructFee(subscriptionId, args) {
            communityTokensStore.computeSelfDestructFee(subscriptionId, args.walletsAndAmounts, args.tokenKey, args.accountAddress)
        }

        function computeBurnFee(subscriptionId, args) {
            console.assert(typeof args.amount === "string")
            communityTokensStore.computeBurnFee(subscriptionId, args.tokenKey, args.amount, args.accountAddress)
        }

        function computeSetSignerFee(subscriptionId, args) {
            communityTokensStore.computeSetSignerFee(subscriptionId, args.communityId, args.chainId, args.contractAddress, args.accountAddress)
        }
    }

    function registerAirdropFeesSubscriber(subscriberObj) {
        const subscription = d.airdropFeeSubscriptionComponent.createObject(subscriberObj, { subscriber: subscriberObj })
        d.feesBroker.subscribe(subscription)
    }

    function registerDeployFeesSubscriber(subscriberObj) {
        const subscription = d.deployFeeSubscriptionComponent.createObject(subscriberObj, { subscriber: subscriberObj })
        d.feesBroker.subscribe(subscription)
    }

    function registerSelfDestructFeesSubscriber(subscriberObj) {
        const subscription = d.selfDestructFeeSubscriptionComponent.createObject(subscriberObj, { subscriber: subscriberObj })
        d.feesBroker.subscribe(subscription)
    }

    function registerBurnFeesSubscriber(subscriberObj) {
        const subscription = d.burnFeeSubscriptionComponent.createObject(subscriberObj, { subscriber: subscriberObj })
        d.feesBroker.subscribe(subscription)
    }

    function registerSetSignerFeesSubscriber(subscriberObj) {
        const subscription = d.setSignerFeeSubscriptionComponent.createObject(subscriberObj, { subscriber: subscriberObj })
        d.feesBroker.subscribe(subscription)
    }
}
