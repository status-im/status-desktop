import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import QtWebEngine 1.10
import QtWebChannel 1.15

import StatusQ.Core.Utils 0.1 as SQUtils
import StatusQ.Components 0.1

import "types"

WalletConnectSDKBase {
    id: root

    readonly property alias sdkReady: d.sdkReady

    // Enable the WalletConnect SDK
    property alias enableSdk: loader.active
    property alias userUID: loader.profileName
    readonly property alias url: loader.url

    implicitWidth: 1
    implicitHeight: 1

    /// Generates \c pairResponse signal and expects to receive
    /// a \c sessionProposal signal with the sessionProposal object
    pair: function(pairLink) {
        wcCalls.pair(pairLink)
    }

    getPairings: function(callback) {
        wcCalls.getPairings(callback)
    }

    getActiveSessions: function(callback) {
        wcCalls.getActiveSessions(callback)
    }

    disconnectSession: function(topic) {
        wcCalls.disconnectSession(topic)
    }

    disconnectPairing: function(topic) {
        wcCalls.disconnectPairing(topic)
    }

    ping: function(topic) {
        wcCalls.ping(topic)
    }

    buildApprovedNamespaces: function(id, params, supportedNamespaces) {
        wcCalls.buildApprovedNamespaces(id, params, supportedNamespaces)
    }

    approveSession: function(sessionProposal, supportedNamespaces) {
        wcCalls.approveSession(sessionProposal, supportedNamespaces)
    }

    rejectSession: function(id) {
        wcCalls.rejectSession(id)
    }

    acceptSessionRequest: function(topic, id, signature) {
        wcCalls.acceptSessionRequest(topic, id, signature)
    }

    rejectSessionRequest: function(topic, id, error) {
        wcCalls.rejectSessionRequest(topic, id, error)
    }

    QtObject {
        id: d

        property bool sdkReady: false
        property WebEngineView engine: loader.instance
    }

    QtObject {
        id: wcCalls

        function init() {
            console.debug(`WC WalletConnectSDK.wcCall.init; root.projectId: ${root.projectId}`)

            d.engine.runJavaScript(`
                wc.init("${root.projectId}")
                .then(()=> {
                    wc.statusObject.sdkInitialized("");
                })
                .catch((error) => {
                    wc.statusObject.sdkInitialized("SDK init error: "+error)
                })
            `)
        }

        function getPairings(callback) {
            console.debug(`WC WalletConnectSDK.wcCall.getPairings;`)

            if (d.engine) {
                d.engine.runJavaScript(`wc.getPairings()`, function(result) {
                    console.debug(`WC WalletConnectSDK.wcCall.getPairings; result: ${JSON.stringify(result)}`)

                    if (callback && result) {
                        callback(result)
                    }
                })
            }
        }

        function getActiveSessions(callback) {
            console.debug(`WC WalletConnectSDK.wcCall.getActiveSessions;`)

            if (d.engine) {
                d.engine.runJavaScript(`wc.getActiveSessions()`, function(result) {
                    if (callback && result) {
                        callback(result)
                    }
                })
            }
        }

        function pair(pairLink) {
            console.debug(`WC WalletConnectSDK.wcCall.pair; pairLink: ${pairLink}`)

            d.engine.runJavaScript(`
                                    wc.pair("${pairLink}")
                                    .then((value) => {
                                        wc.statusObject.onPairResponse("")
                                    })
                                    .catch((e) => {
                                        wc.statusObject.onPairResponse(e.message)
                                    })
                                   `
            )
        }

        function buildApprovedNamespaces(pairingId, params, supportedNamespaces) {
            console.debug(`WC WalletConnectSDK.wcCall.buildApprovedNamespaces; id: ${pairingId}, params: ${JSON.stringify(params)}, supportedNamespaces: ${JSON.stringify(supportedNamespaces)}`)

            d.engine.runJavaScript(`
                                    wc.buildApprovedNamespaces(${JSON.stringify(params)}, ${JSON.stringify(supportedNamespaces)})
                                    .then((approvedNamespaces) => {
                                        wc.statusObject.onBuildApprovedNamespacesResponse(${pairingId}, approvedNamespaces, "")
                                    })
                                    .catch((e) => {
                                        wc.statusObject.onBuildApprovedNamespacesResponse(${pairingId}, "", e.message)
                                    })
                                   `
            )
        }

        function approveSession(sessionProposal, supportedNamespaces) {
            console.debug(`WC WalletConnectSDK.wcCall.approveSession; sessionProposal: ${JSON.stringify(sessionProposal)}, supportedNamespaces: ${JSON.stringify(supportedNamespaces)}`)

            d.engine.runJavaScript(`
                                    wc.approveSession(${JSON.stringify(sessionProposal)}, ${JSON.stringify(supportedNamespaces)})
                                    .then((session) => {
                                        wc.statusObject.onApproveSessionResponse(${sessionProposal.id}, session, "")
                                    })
                                    .catch((e) => {
                                        wc.statusObject.onApproveSessionResponse(${sessionProposal.id}, "", e.message)
                                    })
                                   `
            )
        }

        function rejectSession(id) {
            console.debug(`WC WalletConnectSDK.wcCall.rejectSession; id: ${id}`)

            d.engine.runJavaScript(`
                                    wc.rejectSession(${id})
                                    .then((value) => {
                                        wc.statusObject.onRejectSessionResponse(${id}, "")
                                    })
                                    .catch((e) => {
                                        wc.statusObject.onRejectSessionResponse(${id}, e.message)
                                    })
                                   `
            )
        }

        function acceptSessionRequest(topic, id, signature) {
            console.debug(`WC WalletConnectSDK.wcCall.acceptSessionRequest; topic: "${topic}", id: ${id}, signature: "${signature}"`)

            d.engine.runJavaScript(`
                                    wc.respondSessionRequest("${topic}", ${id}, "${signature}")
                                    .then((value) => {
                                        wc.statusObject.onAcceptSessionRequestResponse("${topic}", ${id}, "")
                                    })
                                    .catch((e) => {
                                        wc.statusObject.onAcceptSessionRequestResponse("${topic}", ${id}, e.message)
                                    })
                                   `
            )
        }

        function rejectSessionRequest(topic, id, error) {
            console.debug(`WC WalletConnectSDK.wcCall.rejectSessionRequest; topic: "${topic}", id: ${id}, error: "${error}"`)

            d.engine.runJavaScript(`
                                    wc.rejectSessionRequest("${topic}", ${id}, ${error})
                                    .then((value) => {
                                        wc.statusObject.onRejectSessionRequestResponse("${topic}", ${id}, "")
                                    })
                                    .catch((e) => {
                                        wc.statusObject.onRejectSessionRequestResponse("${topic}", ${id}, e.message)
                                    })
                                   `
            )
        }

        function disconnectSession(topic) {
            console.debug(`WC WalletConnectSDK.wcCall.disconnectSession; topic: "${topic}"`)

            d.engine.runJavaScript(`
                                    wc.disconnect("${topic}")
                                    .then(() => {
                                        wc.statusObject.onDisconnectSessionResponse("${topic}", "")
                                    })
                                    .catch((e) => {
                                        wc.statusObject.onDisconnectSessionResponse("", e.message)
                                    })
                                   `
            )
        }

        function disconnectPairing(topic) {
            console.debug(`WC WalletConnectSDK.wcCall.disconnectPairing; topic: "${topic}"`)

            d.engine.runJavaScript(`
                                    wc.disconnect("${topic}")
                                    .then(() => {
                                        wc.statusObject.onDisconnectPairingResponse("${topic}", "")
                                    })
                                    .catch((e) => {
                                        wc.statusObject.onDisconnectPairingResponse("", e.message)
                                    })
                                   `
            )
        }

        function ping(topic) {
            console.debug(`WC WalletConnectSDK.wcCall.ping; topic: "${topic}"`)

            d.engine.runJavaScript(`
                                    wc.ping("${topic}")
                                    .then((value) => {
                                        wc.statusObject.onPingResponse("")
                                    })
                                    .catch((e) => {
                                        wc.statusObject.onPingResponse(e.message)
                                    })
                                   `
            )
        }
    }

    QtObject {
        id: statusObject

        WebChannel.id: "statusObject"

        function echo(type, message) {
            if (type === "warn") {
                console.warn(message)
            } else if (type === "debug") {
                console.debug(message)
            } else if (type === "error") {
                console.error(message)
            } else {
                console.log(message)
            }
        }

        function sdkInitialized(error) {
            console.debug(`WC WalletConnectSDK.sdkInitialized: ${!!error ?  "error: " + error : "success"}`)
            d.sdkReady = !error
            root.sdkInit(d.sdkReady, error)
        }

        function onPairResponse(error) {
            console.debug(`WC WalletConnectSDK.onPairResponse; error: ${error}`)
            root.pairResponse(error == "")
        }

        function onPingResponse(error) {
            console.debug(`WC WalletConnectSDK.onPingResponse; error: ${error}`)
        }

        function onDisconnectSessionResponse(topic, error) {
            console.debug(`WC WalletConnectSDK.onDisconnectSessionResponse; topic: ${topic}, error: ${error}`)
            root.sessionDelete(topic, error)
        }

        function onDisconnectPairingResponse(topic, error) {
            console.debug(`WC WalletConnectSDK.onDisconnectPairingResponse; topic: ${topic}, error: ${error}`)
        }

        function onBuildApprovedNamespacesResponse(id, approvedNamespaces, error) {
            console.debug(`WC WalletConnectSDK.onBuildApprovedNamespacesResponse; id: ${id}, approvedNamespaces: ${approvedNamespaces ? JSON.stringify(approvedNamespaces) : "-"}, error: ${error}`)
            root.buildApprovedNamespacesResult(id, approvedNamespaces, error)
        }

        function onApproveSessionResponse(proposalId, session, error) {
            console.debug(`WC WalletConnectSDK.onApproveSessionResponse; proposalId: ${proposalId}, sessionTopic: ${JSON.stringify(session)}, error: ${error}`)
            root.approveSessionResult(proposalId, session, error)
        }

        function onRejectSessionResponse(proposalId, error) {
            console.debug(`WC WalletConnectSDK.onRejectSessionResponse; proposalId: ${proposalId}, error: ${error}`)
            root.rejectSessionResult(proposalId, error)
        }

        function onAcceptSessionRequestResponse(topic, id, error) {
            console.debug(`WC WalletConnectSDK.onAcceptSessionRequestResponse; topic: ${topic}, id: ${id} error: ${error}`)
            let responseToAccept = true
            root.sessionRequestUserAnswerResult(topic, id, responseToAccept, error)
        }

        function onRejectSessionRequestResponse(topic, id, error) {
            console.debug(`WC WalletConnectSDK.onRejectSessionRequestResponse; topic: ${topic}, id: ${id}, error: ${error}`)
            let responseToAccept = false
            root.sessionRequestUserAnswerResult(topic, id, responseToAccept, error)
        }

        function onSessionProposal(details) {
            console.debug(`WC WalletConnectSDK.onSessionProposal; details: ${JSON.stringify(details)}`)
            root.sessionProposal(details)
        }

        function onSessionUpdate(details) {
            console.debug(`WC TODO WalletConnectSDK.onSessionUpdate; details: ${JSON.stringify(details)}`)
        }

        function onSessionExtend(details) {
            console.debug(`WC TODO WalletConnectSDK.onSessionExtend; details: ${JSON.stringify(details)}`)
        }

        function onSessionPing(details) {
            console.debug(`WC TODO WalletConnectSDK.onSessionPing; details: ${JSON.stringify(details)}`)
        }

        function onSessionDelete(details) {
            console.debug(`WC WalletConnectSDK.onSessionDelete; details: ${JSON.stringify(details)}`)
            root.sessionDelete(details.topic, "")
        }

        function onSessionExpire(details) {
            console.debug(`WC TODO WalletConnectSDK.onSessionExpire; details: ${JSON.stringify(details)}`)
        }

        function onSessionRequest(details) {
            console.debug(`WC WalletConnectSDK.onSessionRequest; details: ${JSON.stringify(details)}`)
            root.sessionRequestEvent(details)
        }

        function onSessionRequestSent(details) {
            console.debug(`WC TODO WalletConnectSDK.onSessionRequestSent; details: ${JSON.stringify(details)}`)
        }

        function onSessionEvent(details) {
            console.debug(`WC TODO WalletConnectSDK.onSessionEvent; details: ${JSON.stringify(details)}`)
        }

        function onProposalExpire(details) {
            console.debug(`WC WalletConnectSDK.onProposalExpire; details: ${JSON.stringify(details)}`)
            root.sessionProposalExpired()
        }

        function onSessionRequestExpire(id) {
            console.debug(`WC WalletConnectSDK.onSessionRequestExpire; id: ${id}`)
            root.sessionRequestExpired(id)
        }
    }

    WebEngineLoader {
        id: loader

        anchors.fill: parent

        url: "qrc:/app/AppLayouts/Wallet/services/dapps/sdk/src/index.html"
        webChannelObjects: [ statusObject ]

        onPageLoaded: function() {
            wcCalls.init()
        }
        onPageLoadingError: function(error) {
            console.error("WebEngineLoader.onPageLoadingError: ", error)
        }
    }
}
