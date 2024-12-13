import QtQuick 2.15

import AppLayouts.Wallet.services.dapps 1.0
import StatusQ.Core.Utils 0.1 as SQUtils

import shared.stores 1.0
import utils 1.0

/*
    SiweRequestPlugin is a plugin that listens for siwe requests and manages the lifecycle of the request.
*/
SQUtils.QObject {
    id: root
    
    required property WalletConnectSDKBase sdk
    // Store object expected with sign and autheticate methods and signals
    required property DAppsStore store
    // Account model with the following roles:
    // - address
    required property var accountsModel
    // Networks model with the following roles:
    // - chainId
    required property var networksModel

    readonly property bool enabled: sdk.enabled

    // Trigger a connection request to the dApp
    // Expected `connectionApproved` to be called with the key and the approved namespaces
    signal connectDApp(var chains, string dAppUrl, string dAppName, string dAppIcon, var key)
    // Register a SessionRequestResolved object to be presented to the user for signing
    signal registerSignRequest(var request)
    // Unregister the SessionRequestResolved object
    signal unregisterSignRequest(var requestId)
    // Signal that the request was successful
    signal siweSuccessful(var requestId, var topicId)
    // Signal that the request failed
    signal siweFailed(var requestId, string error, var topicId)

    // return true if the request was found and approved
    function connectionApproved(key, approvedNamespaces) {
        const siweLifeCycle = d.getSiweLifeCycle(key)
        if (!siweLifeCycle) {
            return false
        }

        siweLifeCycle.sessionApproved(key, approvedNamespaces)
        return true
    }

    // return true if the request was found and rejected
    function connectionRejected(key) {
        const siweLifeCycle = d.getSiweLifeCycle(key)
        if (!siweLifeCycle) {
            return false
        }

        siweLifeCycle.sessionRejected(key)
        return true
    }

    function getProposalChains(key) {
        const siweLifeCycle = d.getSiweLifeCycle(key)
        if (!siweLifeCycle) {
            return []
        }

        return DAppsHelpers.extractChainsFromAuthenticationProposal(siweLifeCycle.request)
    }

    function getDAppUrl(key) {
        const siweLifeCycle = d.getSiweLifeCycle(key)
        if (!siweLifeCycle) {
            return ""
        }

        return ((((siweLifeCycle.request || {}).params || {}).requester || {}).metadata || {}).url || ""
    }

    Instantiator {
        id: requestLifecycle
        model: d.requests
        // When a new request is added, we create a new SiweLifeCycle object that starts working on it
        delegate: SiweLifeCycle {
            required property var model
            required property int index

            sdk: root.sdk
            store: root.store
            accountsModel: root.accountsModel
            networksModel: root.networksModel
            request: model
            onFinished: (error) => {
                if (error) {
                    root.siweFailed(request.id, error, request.topic)
                    Qt.callLater(() => {
                        d.requests.remove(index, 1)
                    })
                    return
                }

                sdk.getActiveSessions((allSessions) => {
                    for (const topic in allSessions) {
                        if (allSessions[topic].pairingTopic != request.topic) {
                            continue
                        }
                        root.siweSuccessful(request.id, topic)
                        return
                    }
                    // No new session was created
                    // Should not happen
                    root.siweSuccessful(request.id, "")
                })
            }
            onRequestSessionApproval: (chains, dAppUrl, dAppName, dAppIcon, key) => {
                root.connectDApp(chains, dAppUrl, dAppName, dAppIcon, key)
            }
            onRegisterSignRequest: (request) => {
                root.registerSignRequest(request)
            }
            onUnregisterSignRequest: (id) => {
                root.unregisterSignRequest(id)
            }
        }

        onObjectAdded: (_, obj) => {
            obj.start()
        }
    }

    Connections {
        target: sdk
        enabled: root.enabled

        function onSessionAuthenticateRequest(sessionData) {
            if (!sessionData || !sessionData.id) {
                console.warn("Error in SiweRequestPlugin: Invalid session authenticate request", sessionData)
                return
            }

            if (d.getSiweLifeCycle(sessionData.id)) {
                console.warn("Error in SiweRequestPlugin: Session request already exists", sessionData.id)
                return
            }
            d.requests.append(sessionData)
        }
    }

    QtObject {
        id: d
        property ListModel requests: ListModel {}

        function getSiweLifeCycle(requestId) {
            for (let i = 0; i < requestLifecycle.count; i++) {
                const siweLifeCycle = requestLifecycle.objectAt(i)
                if (siweLifeCycle.request.id == requestId) {
                    return siweLifeCycle
                }
            }

            return null
        }
    }
}