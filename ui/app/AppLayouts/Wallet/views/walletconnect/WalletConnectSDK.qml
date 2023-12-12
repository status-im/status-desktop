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
    signal approveSessionResult(var sessionProposal, string error)
    signal rejectSessionResult(string error)
    signal sessionRequestEvent(var sessionRequest)
    signal sessionRequestUserAnswerResult(bool accept, string error)

    signal authRequest(var request)
    signal authSignMessage(string message, string address)
    signal authRequestUserAnswerResult(bool accept, string error)

    signal sessionDelete(var deletePayload)

    function pair(pairLink) {
        wcCalls.pair(pairLink)
    }

    function disconnectTopic(topic) {
        wcCalls.disconnectTopic(topic)
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
                console.debug(`WC WalletConnectSDK.wcCall.getActiveSessions; result: ${JSON.stringify(result, null, 2)}`)

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
                                    .then((value) => {
                                        wc.statusObject.onApproveSessionResponse(${JSON.stringify(sessionProposal)}, "")
                                    })
                                    .catch((e) => {
                                        wc.statusObject.onApproveSessionResponse(${JSON.stringify(sessionProposal)}, e.message)
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

            d.engine.runJavaScript(`wc.respondSessionRequest("${topic}", ${id}, "${signature}")`, function(result) {

                console.debug(`WC WalletConnectSDK.wcCall.acceptSessionRequest; response: ${JSON.stringify(result, null, 2)}`)

                if (result) {
                    if (!!result.error)
                    {
                        console.error("respondSessionRequest: ", result.error)
                        root.sessionRequestUserAnswerResult(true, result.error)
                        return
                    }
                    root.sessionRequestUserAnswerResult(true, result.error)
                }

                d.resetPairingsModel()
                d.resetSessionsModel()
            })
        }

        function rejectSessionRequest(topic, id, error) {
            console.debug(`WC WalletConnectSDK.wcCall.rejectSessionRequest; topic: "${topic}", id: ${id}, error: "${error}"`)

            d.engine.runJavaScript(`wc.rejectSessionRequest("${topic}", ${id}, "${error}")`, function(result) {

                console.debug(`WC WalletConnectSDK.wcCall.rejectSessionRequest; response: ${JSON.stringify(result, null, 2)}`)

                d.resetPairingsModel()
                d.resetSessionsModel()

                if (result) {
                    if (!!result.error)
                    {
                        console.error("rejectSessionRequest: ", result.error)
                        root.sessionRequestUserAnswerResult(false, result.error)
                        return
                    }
                    root.sessionRequestUserAnswerResult(false, result.error)
                }
            })
        }

        function disconnectTopic(topic) {
            console.debug(`WC WalletConnectSDK.wcCall.disconnectTopic; topic: "${topic}"`)

            d.engine.runJavaScript(`
                                    wc.disconnect("${topic}")
                                    .then((value) => {
                                        wc.statusObject.onDisconnectResponse("")
                                    })
                                    .catch((e) => {
                                        wc.statusObject.onDisconnectResponse(e.message)
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

            d.engine.runJavaScript(`wc.auth("${authLink}")`, function(result) {
                console.debug(`WC WalletConnectSDK.wcCall.auth; response: ${JSON.stringify(result, null, 2)}`)

                if (result) {
                    if (!!result.error) {
                        console.error("auth: ", result.error)
                        return
                    }
                }
            })
        }

        function formatAuthMessage(cacaoPayload, address) {
            console.debug(`WC WalletConnectSDK.wcCall.auth; cacaoPayload: ${JSON.stringify(cacaoPayload)}, address: ${address}`)

            d.engine.runJavaScript(`wc.formatAuthMessage(${JSON.stringify(cacaoPayload)}, "${address}")`, function(result) {
                console.debug(`WC WalletConnectSDK.wcCall.formatAuthMessage; response: ${JSON.stringify(result, null, 2)}`)

                if (result) {
                    if (!!result.error) {
                        console.error("formatAuthMessage: ", result.error)
                        return
                    }
                }

                root.authSignMessage(result.result, address)
            })
        }

        function authApprove(authRequest, address, signature) {
            console.debug(`WC WalletConnectSDK.wcCall.authApprove; authRequest: ${JSON.stringify(authRequest)}, address: ${address}, signature: ${signature}`)

            d.engine.runJavaScript(`wc.approveAuth(${JSON.stringify(authRequest)}, "${address}", "${signature}")`, function(result) {
                console.debug(`WC WalletConnectSDK.wcCall.approveAuth; response: ${JSON.stringify(result, null, 2)}`)

                if (result) {
                    if (!!result.error)
                    {
                        console.error("approveAuth: ", result.error)
                        root.authRequestUserAnswerResult(true, result.error)
                        return
                    }
                    root.authRequestUserAnswerResult(true, result.error)
                }
            })
        }

        function authReject(id, address) {
            console.debug(`WC WalletConnectSDK.wcCall.authReject; id: ${id}, address: ${address}`)

            d.engine.runJavaScript(`wc.rejectAuth(${id}, "${address}")`, function(result) {
                console.debug(`WC WalletConnectSDK.wcCall.rejectAuth; response: ${JSON.stringify(result, null, 2)}`)

                if (result) {
                    if (!!result.error)
                    {
                        console.error("rejectAuth: ", result.error)
                        root.authRequestUserAnswerResult(false, result.error)
                        return
                    }
                    root.authRequestUserAnswerResult(false, result.error)
                }
            })
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

        function onDisconnectResponse(error) {
            console.debug(`WC WalletConnectSDK.onDisconnectResponse; error: ${error}`)
            d.resetPairingsModel()
            d.resetSessionsModel()
        }

        function onApproveSessionResponse(sessionProposal, error) {
            console.debug(`WC WalletConnectSDK.onApproveSessionResponse; sessionProposal: ${JSON.stringify(sessionProposal, null, 2)}, error: ${error}`)

            // Update the temporary expiry with the one from the pairing
            d.resetPairingsModel((pairing) => {
                if (pairing.topic === sessionProposal.params.pairingTopic) {
                    sessionProposal.params.expiry = pairing.expiry
                    root.approveSessionResult(sessionProposal, error)
                }
            })
            d.resetSessionsModel()
        }

        function onRejectSessionResponse(error) {
            console.debug(`WC WalletConnectSDK.onRejectSessionResponse; error: ${error}`)
            root.rejectSessionResult(error)
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
            root.sessionDelete(details)
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
