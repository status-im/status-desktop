import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import QtWebEngine 1.10
import QtWebChannel 1.15

import StatusQ.Core.Utils 0.1 as SQUtils
import StatusQ.Components 0.1

import utils 1.0

Item {
    id: root

    required property string projectId
    readonly property alias sdkReady: d.sdkReady
    readonly property alias pairingsModel: d.pairingsModel
    readonly property alias sessionsModel: d.sessionsModel
    readonly property alias webEngineLoader: loader

    property alias active: loader.active
    property alias url: loader.url

    implicitWidth: 1
    implicitHeight: 1

    signal statusChanged(string message)
    signal sdkInit(bool success, var result)
    signal sessionProposal(var sessionProposal)
    signal sessionProposalExpired()
    signal approveSessionResult(var session, string error)
    signal rejectSessionResult(string error)
    signal sessionRequestEvent(var sessionRequest)
    signal sessionRequestUserAnswerResult(bool accept, string error)

    signal authRequest(var request)
    signal authMessageFormated(string formatedMessage, string address)
    signal authRequestUserAnswerResult(bool accept, string error)

    signal sessionDelete(var topic, string error)

    function pair(pairLink) {
        wcCalls.pair(pairLink)
    }

    function getPairings(callback) {
        wcCalls.getPairings(callback)
    }

    function getActiveSessions(callback) {
        wcCalls.getActiveSessions(callback)
    }

    function disconnectSession(topic) {
        wcCalls.disconnectSession(topic)
    }

    function disconnectPairing(topic) {
        wcCalls.disconnectPairing(topic)
    }

    function ping(topic) {
        wcCalls.ping(topic)
    }

    function approveSession(sessionProposal, supportedNamespaces) {
        wcCalls.approveSession(sessionProposal, supportedNamespaces)
    }

    function rejectSession(id) {
        wcCalls.rejectSession(id)
    }

    function acceptSessionRequest(topic, id, signature) {
        wcCalls.acceptSessionRequest(topic, id, signature)
    }

    function rejectSessionRequest(topic, id, error) {
        wcCalls.rejectSessionRequest(topic, id, error)
    }

    function auth(authLink) {
        wcCalls.auth(authLink)
    }

    function formatAuthMessage(cacaoPayload, address) {
        wcCalls.formatAuthMessage(cacaoPayload, address)
    }

    function authApprove(authRequest, address, signature) {
        wcCalls.authApprove(authRequest, address, signature)
    }

    function authReject(id, address) {
        wcCalls.authReject(id, address)
    }

    QtObject {
        id: d

        property bool sdkReady: false
        property ListModel pairingsModel: pairings
        property ListModel sessionsModel: sessions

        property WebEngineView engine: loader.instance

        onSdkReadyChanged: {
            if (sdkReady)
            {
                d.resetPairingsModel()
                d.resetSessionsModel()
            }
        }

        function resetPairingsModel(entryCallback)
        {
            pairings.clear();

            // We have to postpone `getPairings` call, cause otherwise:
            // - the last made pairing will always have `active` prop set to false
            // - expiration date won't be the correct one, but one used in session proposal
            // - the list of pairings will display succesfully made pairing as inactive
            Backpressure.debounce(this, 250, () => {
                                      wcCalls.getPairings((pairList) => {
                                                              for (let i = 0; i < pairList.length; i++) {
                                                                  pairings.append(pairList[i]);

                                                                  if (entryCallback) {
                                                                      entryCallback(pairList[i])
                                                                  }
                                                              }
                                                          });
                                  })();
        }

        function resetSessionsModel() {
            sessions.clear();

            Backpressure.debounce(this, 250, () => {
                                      wcCalls.getActiveSessions((sessionList) => {
                                                                    for (var topic of Object.keys(sessionList)) {
                                                                        sessions.append(sessionList[topic]);
                                                                    }
                                                                });
                                  })();
        }

        function getPairingTopicFromPairingUrl(url)
        {
            if (!url.startsWith("wc:"))
            {
                return null;
            }

            const atIndex = url.indexOf("@");
            if (atIndex < 0)
            {
                return null;
            }

            return url.slice(3, atIndex);
        }
    }

    QtObject {
        id: wcCalls

        function init() {
            console.debug(`WC WalletConnectSDK.wcCall.init; root.projectId: ${root.projectId}`)

            d.engine.runJavaScript(`wc.init("${root.projectId}").catch((error) => {wc.statusObject.sdkInitialized("SDK init error: "+error);})`, function(result) {

                console.debug(`WC WalletConnectSDK.wcCall.init; response: ${JSON.stringify(result, null, 2)}`)

                if (result && !!result.error)
                {
                    console.error("init: ", result.error)
                }
            })
        }

        function getPairings(callback) {
            console.debug(`WC WalletConnectSDK.wcCall.getPairings;`)

            d.engine.runJavaScript(`wc.getPairings()`, function(result) {
                console.debug(`WC WalletConnectSDK.wcCall.getPairings; result: ${JSON.stringify(result, null, 2)}`)

                if (callback && result) {
                    callback(result)
                }
            })
        }

        function getActiveSessions(callback) {
            console.debug(`WC WalletConnectSDK.wcCall.getActiveSessions;`)

            d.engine.runJavaScript(`wc.getActiveSessions()`, function(result) {
                let allSessions = ""
                for (var key of Object.keys(result)) {
                    allSessions += `\nsessionTopic: ${key}  relatedPairingTopic: ${result[key].pairingTopic}`;
                }
                console.debug(`WC WalletConnectSDK.wcCall.getActiveSessions; result: ${allSessions}`)

                if (callback && result) {
                    callback(result)
                }
            })
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

        function approveSession(sessionProposal, supportedNamespaces) {
            console.debug(`WC WalletConnectSDK.wcCall.approveSession; sessionProposal: ${JSON.stringify(sessionProposal)}, supportedNamespaces: ${JSON.stringify(supportedNamespaces)}`)

            d.engine.runJavaScript(`
                                    wc.approveSession(${JSON.stringify(sessionProposal)}, ${JSON.stringify(supportedNamespaces)})
                                    .then((session) => {
                                        wc.statusObject.onApproveSessionResponse(session, "")
                                    })
                                    .catch((e) => {
                                        wc.statusObject.onApproveSessionResponse("", e.message)
                                    })
                                   `
            )
        }

        function rejectSession(id) {
            console.debug(`WC WalletConnectSDK.wcCall.rejectSession; id: ${id}`)

            d.engine.runJavaScript(`
                                    wc.rejectSession(${id})
                                    .then((value) => {
                                        wc.statusObject.onRejectSessionResponse("")
                                    })
                                    .catch((e) => {
                                        wc.statusObject.onRejectSessionResponse(e.message)
                                    })
                                   `
            )
        }

        function acceptSessionRequest(topic, id, signature) {
            console.debug(`WC WalletConnectSDK.wcCall.acceptSessionRequest; topic: "${topic}", id: ${id}, signature: "${signature}"`)

            d.engine.runJavaScript(`
                                    wc.respondSessionRequest("${topic}", ${id}, "${signature}")
                                    .then((value) => {
                                        wc.statusObject.onRespondSessionRequestResponse("")
                                    })
                                    .catch((e) => {
                                        wc.statusObject.onRespondSessionRequestResponse(e.message)
                                    })
                                   `
            )
        }

        function rejectSessionRequest(topic, id, error) {
            console.debug(`WC WalletConnectSDK.wcCall.rejectSessionRequest; topic: "${topic}", id: ${id}, error: "${error}"`)

            d.engine.runJavaScript(`
                                    wc.rejectSessionRequest("${topic}", ${id}, "${error}")
                                    .then((value) => {
                                        wc.statusObject.onRejectSessionRequestResponse("")
                                    })
                                    .catch((e) => {
                                        wc.statusObject.onRejectSessionRequestResponse(e.message)
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

        function auth(authLink) {
            console.debug(`WC WalletConnectSDK.wcCall.auth; authLink: ${authLink}`)

            d.engine.runJavaScript(`
                                    wc.auth("${authLink}")
                                    .then((value) => {
                                        wc.statusObject.onAuthResponse("")
                                    })
                                    .catch((e) => {
                                        wc.statusObject.onAuthResponse(e.message)
                                    })
                                   `
            )
        }

        function formatAuthMessage(cacaoPayload, address) {
            console.debug(`WC WalletConnectSDK.wcCall.auth; cacaoPayload: ${JSON.stringify(cacaoPayload)}, address: ${address}`)

            d.engine.runJavaScript(`wc.formatAuthMessage(${JSON.stringify(cacaoPayload)}, "${address}")`, function(result) {
                console.debug(`WC WalletConnectSDK.wcCall.formatAuthMessage; response: ${JSON.stringify(result, null, 2)}`)

                root.authMessageFormated(result, address)
            })
        }

        function authApprove(authRequest, address, signature) {
            console.debug(`WC WalletConnectSDK.wcCall.authApprove; authRequest: ${JSON.stringify(authRequest)}, address: ${address}, signature: ${signature}`)

            d.engine.runJavaScript(`
                                    wc.approveAuth(${JSON.stringify(authRequest)}, "${address}", "${signature}")
                                    .then((value) => {
                                        wc.statusObject.onApproveAuthResponse("")
                                    })
                                    .catch((e) => {
                                        wc.statusObject.onApproveAuthResponse(e.message)
                                    })
                                   `
            )
        }

        function authReject(id, address) {
            console.debug(`WC WalletConnectSDK.wcCall.authReject; id: ${id}, address: ${address}`)

            d.engine.runJavaScript(`
                                    wc.rejectAuth(${id}, "${address}")
                                    .then((value) => {
                                        wc.statusObject.onRejectAuthResponse("")
                                    })
                                    .catch((e) => {
                                        wc.statusObject.onRejectAuthResponse(e.message)
                                    })
                                   `
            )
        }
    }

    QtObject {
        id: statusObject

        WebChannel.id: "statusObject"

        function bubbleConsoleMessage(type, message) {
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
            console.debug(`WC WalletConnectSDK.sdkInitialized; error: ${error}`)
            d.sdkReady = !error
            root.sdkInit(d.sdkReady, error)
        }

        function onPairResponse(error) {
            console.debug(`WC WalletConnectSDK.onPairResponse; error: ${error}`)
        }

        function onPingResponse(error) {
            console.debug(`WC WalletConnectSDK.onPingResponse; error: ${error}`)
        }

        function onDisconnectSessionResponse(topic, error) {
            console.debug(`WC WalletConnectSDK.onDisconnectSessionResponse; topic: ${topic}, error: ${error}`)
            d.resetSessionsModel()
            root.sessionDelete(topic, error)
        }

        function onDisconnectPairingResponse(topic, error) {
            console.debug(`WC WalletConnectSDK.onDisconnectPairingResponse; topic: ${topic}, error: ${error}`)
            d.resetPairingsModel()
        }

        function onApproveSessionResponse(session, error) {
            console.debug(`WC WalletConnectSDK.onApproveSessionResponse; sessionTopic: ${JSON.stringify(session, null, 2)}, error: ${error}`)
            d.resetPairingsModel()
            d.resetSessionsModel()
            root.approveSessionResult(session, error)
        }

        function onRejectSessionResponse(error) {
            console.debug(`WC WalletConnectSDK.onRejectSessionResponse; error: ${error}`)
            root.rejectSessionResult(error)
            d.resetPairingsModel()
            d.resetSessionsModel()
        }

        function onRespondSessionRequestResponse(error) {
            console.debug(`WC WalletConnectSDK.onRespondSessionRequestResponse; error: ${error}`)
            root.sessionRequestUserAnswerResult(true, error)
            d.resetPairingsModel()
            d.resetSessionsModel()
        }

        function onRejectSessionRequestResponse(error) {
            console.debug(`WC WalletConnectSDK.onRejectSessionRequestResponse; error: ${error}`)
            root.sessionRequestUserAnswerResult(false, error)
            d.resetPairingsModel()
            d.resetSessionsModel()
        }

        function onSessionProposal(details) {
            console.debug(`WC WalletConnectSDK.onSessionProposal; details: ${JSON.stringify(details, null, 2)}`)
            root.sessionProposal(details)
        }

        function onSessionUpdate(details) {
            console.debug(`WC TODO WalletConnectSDK.onSessionUpdate; details: ${JSON.stringify(details, null, 2)}`)
        }

        function onSessionExtend(details) {
            console.debug(`WC TODO WalletConnectSDK.onSessionExtend; details: ${JSON.stringify(details, null, 2)}`)
        }

        function onSessionPing(details) {
            console.debug(`WC TODO WalletConnectSDK.onSessionPing; details: ${JSON.stringify(details, null, 2)}`)
        }

        function onSessionDelete(details) {
            console.debug(`WC WalletConnectSDK.onSessionDelete; details: ${JSON.stringify(details, null, 2)}`)
            root.sessionDelete(details.topic, "")
            d.resetPairingsModel()
            d.resetSessionsModel()
        }

        function onSessionExpire(details) {
            console.debug(`WC TODO WalletConnectSDK.onSessionExpire; details: ${JSON.stringify(details, null, 2)}`)
        }

        function onSessionRequest(details) {
            console.debug(`WC WalletConnectSDK.onSessionRequest; details: ${JSON.stringify(details, null, 2)}`)
            root.sessionRequestEvent(details)
        }

        function onSessionRequestSent(details) {
            console.debug(`WC TODO WalletConnectSDK.onSessionRequestSent; details: ${JSON.stringify(details, null, 2)}`)
        }

        function onSessionEvent(details) {
            console.debug(`WC TODO WalletConnectSDK.onSessionEvent; details: ${JSON.stringify(details, null, 2)}`)
        }

        function onProposalExpire(details) {
            console.debug(`WC WalletConnectSDK.onProposalExpire; details: ${JSON.stringify(details, null, 2)}`)
            root.sessionProposalExpired()
        }

        function onAuthRequest(details) {
            console.debug(`WC WalletConnectSDK.onAuthRequest; details: ${JSON.stringify(details, null, 2)}`)
            root.authRequest(details)
        }

        function onAuthResponse(error) {
            console.debug(`WC WalletConnectSDK.onAuthResponse; error: ${error}`)
        }

        function onApproveAuthResponse(error) {
            console.debug(`WC WalletConnectSDK.onApproveAuthResponse; error: ${error}`)
            root.authRequestUserAnswerResult(true, error)
        }

        function onRejectAuthResponse(error) {
            console.debug(`WC WalletConnectSDK.onRejectAuthResponse; error: ${error}`)
            root.authRequestUserAnswerResult(false, error)
        }
    }

    ListModel {
        id: pairings
    }

    ListModel {
        id: sessions
    }

    WebEngineLoader {
        id: loader

        anchors.fill: parent

        url: "qrc:/app/AppLayouts/Wallet/views/walletconnect/sdk/src/index.html"
        webChannelObjects: [ statusObject ]

        onPageLoaded: function() {
            wcCalls.init()
        }
        onPageLoadingError: function(error) {
            console.error("WebEngineLoader.onPageLoadingError: ", error)
        }
    }
}
