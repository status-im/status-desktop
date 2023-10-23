import QtQuick 2.15

import shared.stores 1.0
import utils 1.0

import StatusQ.Core.Utils 0.1

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
                isOwnerDeployment: subscriber.isOwnerDeployment
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
                type: TransactionFeesBroker.FeeType.SetSigner,
                chainId: subscriber.chainId,
                contractAddress: subscriber.contractAddress,
                accountAddress: subscriber.accountAddress
            })
            isReady: !!subscriber.chainId &&
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

        readonly property SubscriptionBroker feesBroker: SubscriptionBroker {
            active: Global.applicationWindow.active
            onRequest: internal.computeFee(topic)
        }

        property Connections communityTokensStoreConnections: Connections {
            target: communityTokensStore

            function onDeployFeeUpdated(ethCurrency, fiatCurrency, errorCode, responseId) {
                d.feesBroker.response(responseId, { ethCurrency: ethCurrency, fiatCurrency: fiatCurrency, errorCode: errorCode })
            }

            function onAirdropFeeUpdated(response) {
                d.feesBroker.response(response.requestId, response)
            }

            function onSelfDestructFeeUpdated(ethCurrency, fiatCurrency, errorCode, responseId) {
                d.feesBroker.response(responseId, { ethCurrency: ethCurrency, fiatCurrency: fiatCurrency, errorCode: errorCode })
            }

            function onBurnFeeUpdated(ethCurrency, fiatCurrency, errorCode, responseId) {
                d.feesBroker.response(responseId, { ethCurrency: ethCurrency, fiatCurrency: fiatCurrency, errorCode: errorCode })
            }

            function onSetSignerFeeUpdated(ethCurrency, fiatCurrency, errorCode, responseId) {
                d.feesBroker.response(responseId, { ethCurrency: ethCurrency, fiatCurrency: fiatCurrency, errorCode: errorCode })
            }
        }

        function computeFee(topic) {
            const args = JSON.parse(topic)
            switch (args.type) {
                case TransactionFeesBroker.FeeType.Airdrop:
                    computeAirdropFee(args, topic)
                    break
                case TransactionFeesBroker.FeeType.Deploy:
                    computeDeployFee(args, topic)
                    break
                case TransactionFeesBroker.FeeType.SelfDestruct:
                    computeSelfDestructFee(args, topic)
                    break
                case TransactionFeesBroker.FeeType.Burn:
                    computeBurnFee(args, topic)
                    break
                case TransactionFeesBroker.FeeType.SetSigner:
                    computeSetSignerFee(args, topic)
                    break
                default:
                    console.error("Unknown fee type: " + args.type)
            }
        }

        function computeAirdropFee(args, topic) {            
            communityTokensStore.computeAirdropFee(
                        args.communityId,
                        args.contractKeysAndAmounts,
                        args.addressesToAirdrop,
                        args.feeAccountAddress,
                        topic)
        }

        function computeDeployFee(args, topic) {
            communityTokensStore.computeDeployFee(args.communityId, args.chainId, args.accountAddress, args.tokenType, args.isOwnerDeployment, topic)
        }

        function computeSelfDestructFee(args, topic) {
            communityTokensStore.computeSelfDestructFee(args.walletsAndAmounts, args.tokenKey, args.accountAddress, topic)
        }

        function computeBurnFee(args, topic) {
            console.assert(typeof args.amount === "string")
            communityTokensStore.computeBurnFee(args.tokenKey, args.amount, args.accountAddress, topic)
        }

        function computeSetSignerFee(args, topic) {
            communityTokensStore.computeSetSignerFee(args.chainId, args.contractAddress, args.accountAddress, topic)
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
