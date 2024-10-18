import QtQuick 2.15

import AppLayouts.Wallet.services.dapps 1.0
import AppLayouts.Wallet.services.dapps.plugins 1.0
import AppLayouts.Wallet.services.dapps.types 1.0
import AppLayouts.Wallet.stores 1.0 as WalletStore

import StatusQ.Core.Utils 0.1 as SQUtils

import shared.stores 1.0
import utils 1.0

SQUtils.QObject {
    id: root

    required property WalletConnectSDKBase sdk
    required property DAppsStore store
    required property var accountsModel
    required property var networksModel
    required property CurrenciesStore currenciesStore
    required property WalletStore.WalletAssetsStore assetsStore

    property alias requestsModel: requests

    function subscribeForFeeUpdates(topic, id) {
        d.subscribeForFeeUpdates(topic, id)
    }

    function pair(uri) {
        return sdk.pair(uri)
    }

    /// Approves or rejects the session proposal
    function approvePairSession(key, approvedChainIds, accountAddress) {
        const approvedNamespaces = JSON.parse(
            DAppsHelpers.buildSupportedNamespaces(approvedChainIds,
                                             [accountAddress],
                                             SessionRequest.getSupportedMethods())
        )

        if (siwePlugin.connectionApproved(key, approvedNamespaces)) {
            return
        }

        if (!d.activeProposals.has(key)) {
            console.error("No active proposal found for key: " + key)
            return
        }

        const proposal = d.activeProposals.get(key)
        d.acceptedSessionProposal = proposal
        d.acceptedNamespaces = approvedNamespaces

        sdk.buildApprovedNamespaces(key, proposal.params, approvedNamespaces)
    }

    /// Rejects the session proposal
    function rejectPairSession(id) {
        if (siwePlugin.connectionRejected(id)) {
            return
        }
        sdk.rejectSession(id)
    }

    /// Disconnects the WC session with the given topic
    function disconnectSession(sessionTopic) {
        wcSDK.disconnectSession(sessionTopic)
    }

    function validatePairingUri(uri){
        const info = DAppsHelpers.extractInfoFromPairUri(uri)
        sdk.getActiveSessions((sessions) => {
            // Check if the URI is already paired
            let validationState = Pairing.errors.uriOk
            for (const key in sessions) {
                if (sessions[key].pairingTopic === info.topic) {
                    validationState = Pairing.errors.alreadyUsed
                    break
                }
            }

            // Check if expired
            if (validationState === Pairing.errors.uriOk) {
                const now = (new Date().getTime())/1000
                if (info.expiry < now) {
                    validationState = Pairing.errors.expired
                }
            }

            root.pairingValidated(validationState)
        });
    }

    signal sessionRequest(var id)
    /*type - maps to Constants.ephemeralNotificationType*/
    signal displayToastMessage(string message, int type)
    signal pairingValidated(int validationState)
    signal pairingResponse(int state) // Maps to Pairing.errors
    signal connectDApp(var chains, string dAppUrl, string dAppName, string dAppIcon, var key)
    signal approveSessionResult(var proposalId, bool error, var topic)
    signal dappDisconnected(var topic, string url, bool error)

    Connections {
        target: sdk

        function onRejectSessionResult(proposalId, err) {
            if (!d.activeProposals.has(proposalId)) {
                console.error("No active proposal found for key: " + proposalId)
                return
            }
            
            const proposal = d.activeProposals.get(proposalId)
            d.activeProposals.delete(proposalId)

            const app_url = proposal.params.proposer.metadata.url ?? "-"
            const app_domain = SQUtils.StringUtils.extractDomainFromLink(app_url)
            if(err) {
                root.pairingResponse(Pairing.errors.unknownError)
                root.displayToastMessage(qsTr("Failed to reject connection request for %1").arg(app_domain), Constants.ephemeralNotificationType.danger)
            } else {
                root.displayToastMessage(qsTr("Connection request for %1 was rejected").arg(app_domain), Constants.ephemeralNotificationType.success)
            }
        }

        function onApproveSessionResult(proposalId, session, err) {
            if (!d.activeProposals.has(proposalId)) {
                console.error("No active proposal found for key: " + proposalId)
                return
            }

            if (!d.acceptedSessionProposal || d.acceptedSessionProposal.id !== proposalId) {
                console.error("No accepted proposal found for key: " + proposalId)
                d.activeProposals.delete(proposalId)
                return
            }

            const proposal = d.activeProposals.get(proposalId)
            d.activeProposals.delete(proposalId)
            d.acceptedSessionProposal = null
            d.acceptedNamespaces = null
            
            if (err) {
                root.pairingResponse(Pairing.errors.unknownError)
                return
            }

            // TODO #14754: implement custom dApp notification
            const app_url = proposal.params.proposer.metadata.url ?? "-"
            const app_domain = SQUtils.StringUtils.extractDomainFromLink(app_url)
            root.displayToastMessage(qsTr("Connected to %1 via WalletConnect").arg(app_domain), Constants.ephemeralNotificationType.success)

            // Persist session
            if(!root.store.addWalletConnectSession(JSON.stringify(session))) {
                console.error("Failed to persist session")
            }

            // Notify client
            root.approveSessionResult(proposalId, err, session.topic)
        }

        function onBuildApprovedNamespacesResult(key, approvedNamespaces, error) {
            if (!d.activeProposals.has(key)) {
                console.error("No active proposal found for key: " + key)
                return
            }

            if(error || !approvedNamespaces) {
                // Check that it contains Non conforming namespaces"
                if (error.includes("Non conforming namespaces")) {
                    root.pairingResponse(Pairing.errors.unsupportedNetwork)
                } else {
                    root.pairingResponse(Pairing.errors.unknownError)
                }
                return
            }

            approvedNamespaces = applyChainAgnosticFix(approvedNamespaces)

            if (d.acceptedSessionProposal) {
                sdk.approveSession(d.acceptedSessionProposal, approvedNamespaces)
            } else {
                const proposal = d.activeProposals.get(key)
                const res = DAppsHelpers.extractChainsAndAccountsFromApprovedNamespaces(approvedNamespaces)
                const chains = res.chains
                const dAppUrl = proposal.params.proposer.metadata.url
                const dAppName = proposal.params.proposer.metadata.name
                const dAppIcons = proposal.params.proposer.metadata.icons
                const dAppIcon = dAppIcons && dAppIcons.length > 0 ? dAppIcons[0] : ""

                root.connectDApp(chains, dAppUrl, dAppName, dAppIcon, key)
            }
        }

        //Special case for chain agnostic dapps
        //WC considers the approved namespace as valid, but there's no chainId or account established
        //Usually this request is declared by using `eip155:0`, but we don't support this chainID, resulting in empty `chains` and `accounts`
        //The established connection will use for all user approved chains and accounts
        //This fix is applied to all valid namespaces that don't have a chainId or account
        function applyChainAgnosticFix(approvedNamespaces) {
            try {
                const an = approvedNamespaces.eip155
                const chainAgnosticRequest = (!an.chains || an.chains.length === 0) && (!an.accounts || an.accounts.length === 0)
                if (!chainAgnosticRequest) {
                    return approvedNamespaces
                }

                // If the `d.acceptedNamespaces` is set it means the user already confirmed the chain and account
                if (!!d.acceptedNamespaces) {
                    approvedNamespaces.eip155.chains = d.acceptedNamespaces.eip155.chains
                    approvedNamespaces.eip155.accounts = d.acceptedNamespaces.eip155.accounts
                    return approvedNamespaces
                }

                // Show to the user all possible chains
                const supportedNamespacesStr = DAppsHelpers.buildSupportedNamespacesFromModels(
                    root.networksModel, root.accountsModel, SessionRequest.getSupportedMethods())
                const supportedNamespaces = JSON.parse(supportedNamespacesStr)

                approvedNamespaces.eip155.chains = supportedNamespaces.eip155.chains
                approvedNamespaces.eip155.accounts = supportedNamespaces.eip155.accounts
            } catch (e) {
                console.warn("WC Error applying chain agnostic fix", e)
            }

            return approvedNamespaces
        }

        function onSessionProposal(sessionProposal) {
            const key = sessionProposal.id
            d.activeProposals.set(key, sessionProposal)

            const supportedNamespacesStr = DAppsHelpers.buildSupportedNamespacesFromModels(
                  root.networksModel, root.accountsModel, SessionRequest.getSupportedMethods())
            sdk.buildApprovedNamespaces(key, sessionProposal.params, JSON.parse(supportedNamespacesStr))
        }

        function onPairResponse(ok) {
            root.pairingResponse(ok)
        }

        function onSessionRequestEvent(event) {
            const res = d.resolveAsync(event)
            if (res.code == d.resolveAsyncResult.error) {
                let error = true
                sdk.rejectSessionRequest(event.topic, event.id, error)
                return
            }
            if (res.code == d.resolveAsyncResult.ignored) {
                return
            }
            if (!res.obj) {
                console.error("Unexpected res.obj value!")
                return
            }
            requests.enqueue(res.obj)
        }

        function onSessionRequestUserAnswerResult(topic, id, accept, error) {
            let request = requests.findRequest(topic, id)
            if (request === null) {
                console.error("Error finding event for topic", topic, "id", id)
                return
            }

            let methodStr = SessionRequest.methodToUserString(request.method)
            if (!methodStr) {
                console.error("Error finding user string for method", request.method)
                return
            }

            const appUrl = request.dappUrl
            const appDomain = SQUtils.StringUtils.extractDomainFromLink(appUrl)
            const requestExpired = request.isExpired()

            requests.removeRequest(topic, id)

            if (error) {
                root.displayToastMessage(qsTr("Fail to %1 from %2").arg(methodStr).arg(appDomain), Constants.ephemeralNotificationType.danger)
                sdk.rejectSessionRequest(topic, id, true /*hasError*/)
                console.error(`Error accepting session request for topic: ${topic}, id: ${id}, accept: ${accept}, error: ${error}`)
                return
            }

            if (!requestExpired) {
                let actionStr = accept ? qsTr("accepted") : qsTr("rejected")
                root.displayToastMessage("%1 %2 %3".arg(appDomain).arg(methodStr).arg(actionStr), Constants.ephemeralNotificationType.success)
                return
            }

            root.displayToastMessage("%1 sign request timed out".arg(appDomain), Constants.ephemeralNotificationType.normal)
        }

        function onSessionRequestExpired(sessionId) {
            // Expired event coming from WC
            // Handling as a failsafe in case the event is not processed by the SDK
            let request = requests.findById(sessionId)
            if (request === null) {
                console.error("Error finding event for session id", sessionId)
                return
            }

            if (request.isExpired()) {
                return //nothing to do. The request is already expired
            }

            request.setExpired()
        }

        function onSessionDelete(topic, err) {
            d.disconnectSessionRequested(topic, err)
        }
    }

    SiweRequestPlugin {
        id: siwePlugin

        sdk: root.sdk
        store: root.store
        accountsModel: root.accountsModel
        networksModel: root.networksModel

        onRegisterSignRequest: (request) => {
            requests.enqueue(request)
        }

        onUnregisterSignRequest: (requestId) => {
            const request = requests.findById(requestId)
            if (request === null) {
                console.error("SiweRequestPlugin::onUnregisterSignRequest: Error finding event for requestId", requestId)
                return
            }
            requests.removeRequest(request.topic, requestId)
        }

        onConnectDApp: (chains, dAppUrl, dAppName, dAppIcon, key) => {
            root.connectDApp(chains, dAppUrl, dAppName, dAppIcon, key)
        }

        onSiweFailed: (id, error, topic) => {
            root.approveSessionResult(id, error, topic)
        }

        onSiweSuccessful: (id, topic) => {
            d.lookupSession(topic, function(session) {
                // TODO #14754: implement custom dApp notification
                let meta = session.peer.metadata
                const dappUrl = meta.url ?? "-"
                const dappDomain = SQUtils.StringUtils.extractDomainFromLink(dappUrl)
                root.displayToastMessage(qsTr("Connected to %1 via WalletConnect").arg(dappDomain), Constants.ephemeralNotificationType.success)

                // Persist session
                if(!root.store.addWalletConnectSession(JSON.stringify(session))) {
                    console.error("Failed to persist session")
                }

                root.approveSessionResult(id, "", topic)
            })
        }
    }

    SQUtils.QObject {
        id: d

        property int selectedFeesMode: Constants.FeesMode.Medium

        function getFeesForFeesMode(feesObj) {
            if (!(feesObj.hasOwnProperty("maxFeePerGasL") &&
                  feesObj.hasOwnProperty("maxFeePerGasM") &&
                  feesObj.hasOwnProperty("maxFeePerGasH"))) {
                throw new Error("inappropriate fees object provided")
            }

            switch (d.selectedFeesMode) {
            case Constants.FeesMode.Low:
                return feesObj.maxFeePerGasL
            case Constants.FeesMode.Medium:
                return feesObj.maxFeePerGasM
            case Constants.FeesMode.High:
                return feesObj.maxFeePerGasH
            default:
                throw new Error("unknown selected mode")
            }
        }

        property var feesSubscriptions: []

        function findSubscriptionIndex(topic, id) {
            for (let i = 0; i < d.feesSubscriptions.length; i++) {
                const subscription = d.feesSubscriptions[i]
                if (subscription.topic == topic && subscription.id == id) {
                    return i
                }
            }
            return -1
        }

        function findChainIndex(chainId) {
            for (let i = 0; i < feesSubscription.chainIds.length; i++) {
                if (feesSubscription.chainIds[i] == chainId) {
                    return i
                }
            }
            return -1
        }

        function subscribeForFeeUpdates(topic, id) {
            const request = requests.findRequest(topic, id)
            if (request === null) {
                console.error("Error finding event for subscribing for fees for topic", topic, "id", id)
                return
            }

            const index = d.findSubscriptionIndex(topic, id)
            if (index >= 0) {
                return
            }

            d.feesSubscriptions.push({
                                         topic: topic,
                                         id: id,
                                         chainId: request.chainId
                                     })

            for (let i = 0; i < feesSubscription.chainIds.length; i++) {
                if (feesSubscription.chainIds == request.chainId) {
                    return
                }
            }

            feesSubscription.chainIds.push(request.chainId)
            feesSubscription.restart()
        }

        function unsubscribeForFeeUpdates(topic, id) {
            const index = d.findSubscriptionIndex(topic, id)
            if (index == -1) {
                return
            }

            const chainId = d.feesSubscriptions[index].chainId
            d.feesSubscriptions.splice(index, 1)

            const chainIndex = d.findChainIndex(chainId)
            if (index == -1) {
                return
            }

            let found = false
            for (let i = 0; i < d.feesSubscriptions.length; i++) {
                if (d.feesSubscriptions[i].chainId == chainId) {
                    found = true
                    break
                }
            }

            if (found) {
                return
            }

            feesSubscription.chainIds.splice(chainIndex, 1)
            if (feesSubscription.chainIds.length == 0) {
                feesSubscription.stop()
            }
        }

        readonly property QtObject resolveAsyncResult: QtObject {
            readonly property int error: 0
            readonly property int ok: 1
            readonly property int ignored: 2
        }

        property var activeProposals: new Map() // key: proposalId, value: sessionProposal
        property var acceptedSessionProposal: null
        property var acceptedNamespaces: null

        // returns {
        //   obj: obj or nil
        //   code: resolveAsyncResult codes
        // }
        function resolveAsync(event) {
            const method = event.params.request.method
            const { accountAddress, success } = lookupAccountFromEvent(event, method)
            if(!success) {
                console.info("Error finding accountAddress for event", JSON.stringify(event))
                return { obj: null, code: resolveAsyncResult.error }
            }

            if (!accountAddress) {
                console.info("Account not found for event", JSON.stringify(event))
                return { obj: null, code: resolveAsyncResult.ignored }
            }

            let chainId = lookupNetworkFromEvent(event, method)
            if(!chainId) {
                console.error("Error finding chainId for event", JSON.stringify(event))
                return { obj: null, code: resolveAsyncResult.error }
            }

            const data = extractMethodData(event, method)
            if(!data) {
                console.error("Error in event data lookup", JSON.stringify(event))
                return { obj: null, code: resolveAsyncResult.error }
            }

            const interpreted = d.prepareData(method, data, chainId)

            const enoughFunds = !d.isTransactionMethod(method)
            const requestExpiry = event.params.request.expiryTimestamp

            let obj = sessionRequestComponent.createObject(null, {
                event,
                topic: event.topic,
                requestId: event.id,
                method,
                accountAddress,
                chainId,
                data,
                preparedData: interpreted.preparedData,
                maxFeesText: "?",
                maxFeesEthText: "?",
                expirationTimestamp: requestExpiry
            })
            if (obj === null) {
                console.error("Error creating SessionRequestResolved for event")
                return { obj: null, code: resolveAsyncResult.error }
            }

            // Check later to have a valid request object
            if (!SessionRequest.getSupportedMethods().includes(method)) {
                console.error("Unsupported method", method)
                return { obj: null, code: resolveAsyncResult.error }
            }

            d.lookupSession(obj.topic, function(session) {
                if (session === null) {
                    console.error("DAppsRequestHandler.lookupSession: error finding session for topic", obj.topic)
                    return
                }

                obj.resolveDappInfoFromSession(session)
                root.sessionRequest(obj.requestId)

                d.updateFeesParamsToPassedObj(obj)
            })

            return {
                obj: obj,
                code: resolveAsyncResult.ok
            }
        }

        function updateFeesParamsToPassedObj(obj) {
            if (!d.isTransactionMethod(obj.method)) {
                return
            }

            obj.estimatedTimeCategory = getEstimatedTimeInterval(obj.data, obj.method, obj.chainId)

            const mainNet = lookupMainnetNetwork()
            let mainChainId = obj.chainId
            if (!!mainNet) {
                mainChainId = mainNet.chainId
            } else {
                console.error("Error finding mainnet network")
            }

            const interpreted = d.prepareData(obj.method, obj.data, obj.chainId)

            let st = getEstimatedFeesStatus(obj.data, obj.method, obj.chainId, mainChainId)
            let fundsStatus = checkFundsStatus(st.feesInfo.maxFees, st.feesInfo.l1GasFee, obj.accountAddress, obj.chainId, mainNet.chainId, interpreted.value)
            obj.fiatMaxFees = st.fiatMaxFees
            obj.ethMaxFees = st.maxFeesEth
            obj.haveEnoughFunds = fundsStatus.haveEnoughFunds
            obj.haveEnoughFees = fundsStatus.haveEnoughForFees
            obj.feesInfo = st.feesInfo
        }

        /// returns {
        ///   accountAddress
        ///   success
        /// }
        /// if account is null and success is true it means that the account was not found
        function lookupAccountFromEvent(event, method) {
            let address = ""
            if (method === SessionRequest.methods.personalSign.name) {
                if (event.params.request.params.length < 2) {
                    return { accountAddress: "", success: false }
                }
                address = event.params.request.params[1]
            } else if (method === SessionRequest.methods.sign.name) {
                if (event.params.request.params.length === 1) {
                    return { accountAddress: "", success: false }
                }
                address = event.params.request.params[0]
            } else if(method === SessionRequest.methods.signTypedData_v4.name ||
                      method === SessionRequest.methods.signTypedData.name)
            {
                if (event.params.request.params.length < 2) {
                    return { accountAddress: "", success: false }
                }
                address = event.params.request.params[0]
            } else if (d.isTransactionMethod(method)) {
                if (event.params.request.params.length == 0) {
                    return { accountAddress: "", success: false }
                }
                address = event.params.request.params[0].from
            } else {
                console.error("Unsupported method to lookup account: ", method)
                return { accountAddress: "", success: false }
            }
            const account = SQUtils.ModelUtils.getFirstModelEntryIf(root.accountsModel, (account) => {
                return account.address.toLowerCase() === address.toLowerCase();
            })

            if (!account) {
                return { accountAddress: "", success: true }
            }

            return { accountAddress: account.address, success: true }
        }

        /// Returns null if the network is not found
        function lookupNetworkFromEvent(event, method) {
            if (SessionRequest.getSupportedMethods().includes(method) === false) {
                return null
            }
            const chainId = DAppsHelpers.chainIdFromEip155(event.params.chainId)
            const network = SQUtils.ModelUtils.getByKey(root.networksModel, "chainId", chainId)

            if (!network) {
                return null
            }

            return network.chainId
        }

        /// Returns null if the network is not found
        function lookupMainnetNetwork() {
            return SQUtils.ModelUtils.getByKey(root.networksModel, "layer", 1)
        }

        function extractMethodData(event, method) {
            if (method === SessionRequest.methods.personalSign.name ||
                method === SessionRequest.methods.sign.name)
            {
                if (event.params.request.params.length < 1) {
                    return null
                }
                let message = ""
                const messageIndex = (method === SessionRequest.methods.personalSign.name ? 0 : 1)
                const messageParam = event.params.request.params[messageIndex]
                // There is no standard on how data is encoded. Therefore we support hex or utf8
                if (DAppsHelpers.isHex(messageParam)) {
                    message = DAppsHelpers.hexToString(messageParam)
                } else {
                    message = messageParam
                }
                return SessionRequest.methods.personalSign.buildDataObject(message)
            } else if (method === SessionRequest.methods.signTypedData_v4.name ||
                       method === SessionRequest.methods.signTypedData.name)
            {
                if (event.params.request.params.length < 2) {
                    return null
                }
                const jsonMessage = event.params.request.params[1]
                const methodObj = method === SessionRequest.methods.signTypedData_v4.name
                      ? SessionRequest.methods.signTypedData_v4
                      : SessionRequest.methods.signTypedData
                return methodObj.buildDataObject(jsonMessage)
            } else if (method === SessionRequest.methods.signTransaction.name) {
                if (event.params.request.params.length == 0) {
                    return null
                }
                const tx = event.params.request.params[0]
                return SessionRequest.methods.signTransaction.buildDataObject(tx)
            } else if (method === SessionRequest.methods.sendTransaction.name) {
                if (event.params.request.params.length == 0) {
                    return null
                }
                const tx = event.params.request.params[0]
                return SessionRequest.methods.sendTransaction.buildDataObject(tx)
            } else {
                return null
            }
        }

        function lookupSession(topicToLookup, callback) {
            sdk.getActiveSessions((res) => {
                Object.keys(res).forEach((topic) => {
                    if (topic === topicToLookup) {
                        let session = res[topic]
                        callback(session)
                    }
                })
            })
        }

        function executeSessionRequest(request, password, pin, payload) {
            if (!SessionRequest.getSupportedMethods().includes(request.method)) {
                console.error("Unsupported method to execute: ", request.method)
                return false
            }

            if (password === "") {
                console.error("No password provided to sign message")
                return false
            }

            if (request.method === SessionRequest.methods.sign.name) {
                store.signMessageUnsafe(request.topic,
                                        request.requestId,
                                        request.accountAddress,
                                        SessionRequest.methods.personalSign.getMessageFromData(request.data),
                                        password,
                                        pin)
            } else if (request.method === SessionRequest.methods.personalSign.name) {
                store.signMessage(request.topic,
                                  request.requestId,
                                  request.accountAddress,
                                  SessionRequest.methods.personalSign.getMessageFromData(request.data),
                                  password,
                                  pin)
            } else if (request.method === SessionRequest.methods.signTypedData_v4.name ||
                       request.method === SessionRequest.methods.signTypedData.name)
            {
                let legacy = request.method === SessionRequest.methods.signTypedData.name
                store.safeSignTypedData(request.topic,
                                        request.requestId,
                                        request.accountAddress,
                                        SessionRequest.methods.signTypedData.getMessageFromData(request.data),
                                        request.chainId,
                                        legacy,
                                        password,
                                        pin)
            } else if (d.isTransactionMethod(request.method)) {
                let txObj = d.getTxObject(request.method, request.data)
                if (!!payload) {
                    let feesInfoJson = payload
                    let hexFeesJson = root.store.convertFeesInfoToHex(feesInfoJson)
                    if (!!hexFeesJson) {
                        let feesInfo = JSON.parse(hexFeesJson)
                        if (feesInfo.maxFeePerGas) {
                            txObj.maxFeePerGas = feesInfo.maxFeePerGas
                        }
                        if (feesInfo.maxPriorityFeePerGas) {
                            txObj.maxPriorityFeePerGas = feesInfo.maxPriorityFeePerGas
                        }
                    }
                    delete txObj.gasLimit
                    delete txObj.gasPrice
                }
                // Remove nonce from txObj to be auto-filled by the wallet
                delete txObj.nonce

                if (request.method === SessionRequest.methods.signTransaction.name) {
                    store.signTransaction(request.topic,
                                          request.requestId,
                                          request.accountAddress,
                                          request.chainId,
                                          txObj,
                                          password,
                                          pin)
                } else if (request.method === SessionRequest.methods.sendTransaction.name) {
                    store.sendTransaction(
                                request.topic,
                                request.requestId,
                                request.accountAddress,
                                request.chainId,
                                txObj,
                                password,
                                pin)
                }
            }

            return true
        }

        // Returns Constants.TransactionEstimatedTime
        function getEstimatedTimeInterval(data, method, chainId) {
            let tx = {}
            let maxFeePerGas = ""
            if (d.isTransactionMethod(method)) {
                tx = d.getTxObject(method, data)
                // Empty string instructs getEstimatedTime to fetch the blockchain value
                if (!!tx.maxFeePerGas) {
                    maxFeePerGas = tx.maxFeePerGas
                } else if (!!tx.gasPrice) {
                    maxFeePerGas = tx.gasPrice
                }
            }

            return root.store.getEstimatedTime(chainId, maxFeePerGas)
        }

        // Returns {
        //      maxFees -> Big number in Gwei
        //      maxFeePerGas
        //      maxPriorityFeePerGas
        //      gasPrice
        // }
        function getEstimatedMaxFees(data, method, chainId, mainNetChainId) {
            let tx = {}
            if (d.isTransactionMethod(method)) {
                tx = d.getTxObject(method, data)
            }

            let BigOps = SQUtils.AmountsArithmetic
            let gasLimit = BigOps.fromString("21000")
            let gasPrice, maxFeePerGas, maxPriorityFeePerGas
            let l1GasFee = BigOps.fromNumber(0)

            // Beware, the tx values are standard blockchain hex big number values; the fees values are nim's float64 values, hence the complex conversions
            if (!!tx.maxFeePerGas && !!tx.maxPriorityFeePerGas) {
                maxFeePerGas = hexToGwei(tx.maxFeePerGas)
                maxPriorityFeePerGas = hexToGwei(tx.maxPriorityFeePerGas)

                // TODO: check why we need to set gasPrice here and why if it's not checked we cannot send the tx and fees are unknown????
                gasPrice = hexToGwei(tx.maxFeePerGas)
            } else {
                let fees = root.store.getSuggestedFees(chainId)
                maxPriorityFeePerGas = fees.maxPriorityFeePerGas
                if (fees.eip1559Enabled) {
                    if (!!fees.maxFeePerGasM) {
                        gasPrice = BigOps.fromNumber(fees.maxFeePerGasM)
                        maxFeePerGas = fees.maxFeePerGasM
                    } else if(!!tx.maxFeePerGas) {
                        let maxFeePerGasDec = root.store.hexToDec(tx.maxFeePerGas)
                        gasPrice = BigOps.fromString(maxFeePerGasDec)
                        maxFeePerGas = maxFeePerGasDec
                    } else {
                        console.error("Error fetching maxFeePerGas from fees or tx objects")
                        return
                    }
                } else {
                    if (!!fees.gasPrice) {
                        gasPrice = BigOps.fromNumber(fees.gasPrice)
                    } else {
                        console.error("Error fetching suggested fees")
                        return
                    }
                }
                l1GasFee = BigOps.fromNumber(fees.l1GasFee)
            }

            let maxFees = BigOps.times(gasLimit, gasPrice)
            return {maxFees, maxFeePerGas, maxPriorityFeePerGas, gasPrice, l1GasFee}
        }

        // Returned values are Big numbers
        function getEstimatedFeesStatus(data, method, chainId, mainNetChainId) {
            let BigOps = SQUtils.AmountsArithmetic

            let feesInfo = getEstimatedMaxFees(data, method, chainId, mainNetChainId)

            let totalMaxFees = BigOps.sum(feesInfo.maxFees, feesInfo.l1GasFee)
            let maxFeesEth = BigOps.div(totalMaxFees, BigOps.fromNumber(1, 9))

            let maxFeesEthStr = maxFeesEth.toString()
            let fiatMaxFeesStr = root.currenciesStore.getFiatValue(maxFeesEthStr, Constants.ethToken)
            let fiatMaxFees = BigOps.fromString(fiatMaxFeesStr)
            let symbol = root.currenciesStore.currentCurrency

            return {fiatMaxFees, maxFeesEth, symbol, feesInfo}
        }

        function getBalanceInEth(balances, address, chainId) {
            const BigOps = SQUtils.AmountsArithmetic
            let accEth = SQUtils.ModelUtils.getFirstModelEntryIf(balances, (balance) => {
                return balance.account.toLowerCase() === address.toLowerCase() && balance.chainId == chainId
            })
            if (!accEth) {
                console.error("Error balance lookup for account ", address, " on chain ", chainId)
                return null
            }
            let accountFundsWei = BigOps.fromString(accEth.balance)
            return BigOps.div(accountFundsWei, BigOps.fromNumber(1, 18))
        }

        // Returns {haveEnoughForFees, haveEnoughFunds} and true in case of error not to block request
        function checkFundsStatus(maxFees, l1GasFee, address, chainId, mainNetChainId, valueEth) {
            let BigOps = SQUtils.AmountsArithmetic

            let haveEnoughForFees = true
            let haveEnoughFunds = true

            let token = SQUtils.ModelUtils.getByKey(root.assetsStore.groupedAccountAssetsModel, "tokensKey", Constants.ethToken)
            if (!token || !token.balances) {
                console.error("Error token balances lookup for ETH")
                return {haveEnoughForFees, haveEnoughFunds}
            }

            let chainBalance = getBalanceInEth(token.balances, address, chainId)
            if (!chainBalance) {
                console.error("Error fetching chain balance")
                return {haveEnoughForFees, haveEnoughFunds}
            }
            haveEnoughFunds = BigOps.cmp(chainBalance, valueEth) >= 0
            if (haveEnoughFunds) {
                chainBalance = BigOps.sub(chainBalance, valueEth)

                if (chainId == mainNetChainId) {
                    const finalFees = BigOps.sum(maxFees, l1GasFee)
                    let feesEth = BigOps.div(finalFees, BigOps.fromNumber(1, 9))
                    haveEnoughForFees = BigOps.cmp(chainBalance, feesEth) >= 0
                } else {
                    const feesChain = BigOps.div(maxFees, BigOps.fromNumber(1, 9))
                    const haveEnoughOnChain = BigOps.cmp(chainBalance, feesChain) >= 0

                    const mainBalance = getBalanceInEth(token.balances, address, mainNetChainId)
                    if (!mainBalance) {
                        console.error("Error fetching mainnet balance")
                        return {haveEnoughForFees, haveEnoughFunds}
                    }
                    const feesMain = BigOps.div(l1GasFee, BigOps.fromNumber(1, 9))
                    const haveEnoughOnMain = BigOps.cmp(mainBalance, feesMain) >= 0

                    haveEnoughForFees = haveEnoughOnChain && haveEnoughOnMain
                }
            } else {
                haveEnoughForFees = false
            }

            return {haveEnoughForFees, haveEnoughFunds}
        }

        function isTransactionMethod(method) {
            return method === SessionRequest.methods.signTransaction.name
                || method === SessionRequest.methods.sendTransaction.name
        }

        function getTxObject(method, data) {
            let tx
            if (method === SessionRequest.methods.signTransaction.name) {
                tx = SessionRequest.methods.signTransaction.getTxObjFromData(data)
            } else if (method === SessionRequest.methods.sendTransaction.name) {
                tx = SessionRequest.methods.sendTransaction.getTxObjFromData(data)
            } else {
                console.error("Not a transaction method")
            }
            return tx
        }

        // returns {
        //   preparedData,
        //   value // null or ETH Big number
        // }
        function prepareData(method, data, chainId) {
            let payload = null
            switch(method) {
                case SessionRequest.methods.personalSign.name: {
                    payload = SessionRequest.methods.personalSign.getMessageFromData(data)
                    break
                }
                case SessionRequest.methods.sign.name: {
                    payload = SessionRequest.methods.sign.getMessageFromData(data)
                    break
                }
                case SessionRequest.methods.signTypedData_v4.name: {
                    const stringPayload = SessionRequest.methods.signTypedData_v4.getMessageFromData(data)
                    payload = JSON.stringify(JSON.parse(stringPayload), null, 2)
                    break
                }
                case SessionRequest.methods.signTypedData.name: {
                    const stringPayload = SessionRequest.methods.signTypedData.getMessageFromData(data)
                    payload = JSON.stringify(JSON.parse(stringPayload), null, 2)
                    break
                }
                case SessionRequest.methods.signTransaction.name:
                case SessionRequest.methods.sendTransaction.name:
                    // For transactions we process the data in a different way as follows
                    break
                default:
                    console.error("Unhandled method", method)
                    break;
            }

            let value = SQUtils.AmountsArithmetic.fromNumber(0)
            if (d.isTransactionMethod(method)) {
                let txObj = d.getTxObject(method, data)
                let tx = Object.assign({}, txObj)
                let fees = root.store.getSuggestedFees(chainId)
                if (tx.value) {
                    value = hexToEth(tx.value)
                    tx.value = value.toString()
                }

                if (tx.hasOwnProperty("maxFeePerGas")) {
                    if (tx.maxFeePerGas) {
                        tx.maxFeePerGas = hexToGwei(tx.maxFeePerGas).toString()
                    } else if (fees.eip1559Enabled) {
                        try {
                            tx.maxFeePerGas = d.getFeesForFeesMode(fees)
                        } catch (e) {
                            console.warn(e)
                        }
                    }
                }

                if (tx.hasOwnProperty("maxPriorityFeePerGas")) {
                    if (tx.maxPriorityFeePerGas) {
                        tx.maxPriorityFeePerGas = hexToGwei(tx.maxPriorityFeePerGas).toString()
                    } else if (fees.eip1559Enabled) {
                        tx.maxPriorityFeePerGas = fees.maxPriorityFeePerGas
                    }
                }

                if (tx.hasOwnProperty("gasPrice")) {
                    if (tx.gasPrice) {
                        tx.gasPrice = hexToGwei(tx.gasPrice)
                    } else if (!fees.eip1559Enabled) {
                        tx.gasPrice = fees.gasPrice
                    }
                }

                if (tx.gasLimit) {
                    tx.gasLimit = parseInt(root.store.hexToDec(tx.gasLimit))
                }

                if (tx.nonce) {
                    tx.nonce = parseInt(root.store.hexToDec(tx.nonce))
                }

                payload = JSON.stringify(tx, null, 2)
            }
            return {
                    preparedData: payload,
                    value: value
                }
        }

        function hexToEth(value) {
            return hexToEthDenomination(value, "eth")
        }
        function hexToGwei(value) {
            return hexToEthDenomination(value, "gwei")
        }
        function hexToEthDenomination(value, ethUnit) {
            let unitMapping = {
                "gwei": 9,
                "eth": 18
            }
            let BigOps = SQUtils.AmountsArithmetic
            let decValue = root.store.hexToDec(value)
            if (!!decValue) {
                return BigOps.div(BigOps.fromNumber(decValue), BigOps.fromNumber(1, unitMapping[ethUnit]))
            }
            return BigOps.fromNumber(0)
        }

        function disconnectSessionRequested(topic, err) {
            // Get all sessions and filter the active ones for known accounts
            // Act on the first matching session with the same topic
            const activeSessionsCallback = (allSessions, success) => {
                root.store.activeSessionsReceived.disconnect(activeSessionsCallback)
                
                if (!success) {
                    // TODO #14754: implement custom dApp notification
                    root.dappDisconnected("", "", true)
                    return
                }
                
                // Convert to original format
                const webSdkSessions = allSessions.map((session) => {
                    return JSON.parse(session.sessionJson)
                })

                const sessions = DAppsHelpers.filterActiveSessionsForKnownAccounts(webSdkSessions, root.accountsModel)
                
                for (const sessionID in sessions) {
                    const session = sessions[sessionID]
                    if (session.topic == topic) {
                        root.store.deactivateWalletConnectSession(topic)
                        
                        const dappUrl = session.peer.metadata.url ?? "-"
                        root.dappDisconnected(topic, dappUrl, err)
                        break
                    }
                }
            }

            root.store.activeSessionsReceived.connect(activeSessionsCallback)
            if (!root.store.getActiveSessions()) {
                root.store.activeSessionsReceived.disconnect(activeSessionsCallback)
                // TODO #14754: implement custom dApp notification
            }
        }
    }

    /// The queue is used to ensure that the events are processed in the order they are received but they could be
    /// processed handled randomly on user intervention through activity center
    SessionRequestsModel {
        id: requests
    }

    Component {
        id: sessionRequestComponent

        SessionRequestWithAuth {
            id: request
            sourceId: Constants.DAppConnectors.WalletConnect
            store: root.store

            function signedHandler(topic, id, data) {
                if (topic != request.topic || id != request.requestId) {
                    return
                }
                root.store.signingResult.disconnect(request.signedHandler)

                let hasErrors = (data == "")
                if (!hasErrors) {
                    // acceptSessionRequest will trigger an sdk.sessionRequestUserAnswerResult signal
                    sdk.acceptSessionRequest(topic, id, data)
                } else {
                    request.reject(true)
                }
            }

            onAccepted: () => {
                d.unsubscribeForFeeUpdates(request.topic, request.requestId)
            }

            onRejected: (hasError) => {
                d.unsubscribeForFeeUpdates(request.topic, request.requestId)
                sdk.rejectSessionRequest(request.topic, request.requestId, hasError)
            }

            onAuthFailed: () => {
                const appDomain = SQUtils.StringUtils.extractDomainFromLink(request.dappUrl)
                const methodStr = SessionRequest.methodToUserString(request.method)
                if (!methodStr) {
                    return
                }
                root.displayToastMessage(qsTr("Failed to authenticate %1 from %2").arg(methodStr).arg(appDomain), Constants.ephemeralNotificationType.danger)
            }

            onExecute: (password, pin) => {
                root.store.signingResult.connect(request.signedHandler)
                let executed = false
                try {
                    executed = d.executeSessionRequest(request, password, pin, request.feesInfo)
                } catch (e) {
                    console.error("Error executing session request", e)
                }
                
                if (!executed) {
                    sdk.rejectSessionRequest(request.topic, request.requestId, true /*hasError*/)
                    root.store.signingResult.disconnect(request.signedHandler)
                }
            }
        }
    }

    Timer {
        id: feesSubscription

        property var chainIds: []

        interval: 5000
        repeat: true
        running: Qt.application.state === Qt.ApplicationActive

        onTriggered: {
            for (let i = 0; i < chainIds.length; i++) {
                for (let j = 0; j < d.feesSubscriptions.length; j++) {
                    let subscription = d.feesSubscriptions[j]
                    if (subscription.chainId == chainIds[i]) {
                        let request = requests.findRequest(subscription.topic, subscription.id)
                        if (request === null) {
                            console.error("Error updating fees for topic", subscription.topic, "id", subscription.id)
                            continue
                        }
                        d.updateFeesParamsToPassedObj(request)
                    }
                }
            }
        }
    }
}
