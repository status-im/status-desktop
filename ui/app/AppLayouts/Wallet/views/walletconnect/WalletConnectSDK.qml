import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import QtWebEngine 1.10
import QtWebChannel 1.15

import StatusQ.Core.Utils 0.1 as SQUtils
import StatusQ.Components 0.1

Item {
    id: root

    required property string projectId
    readonly property alias sdkReady: d.sdkReady
    readonly property alias pairingsModel: d.pairingsModel
    readonly property alias webEngineLoader: loader

    property alias active: loader.active
    property alias url: loader.url

    implicitWidth: 1
    implicitHeight: 1

    signal statusChanged(string message)
    signal sdkInit(bool success, var result)
    signal pairSessionProposal(bool success, var sessionProposal)
    signal pairSessionProposalExpired()
    signal pairAcceptedResult(var sessionProposal, bool success, var sessionType)
    signal pairRejectedResult(bool success, var result)
    signal sessionRequestEvent(var sessionRequest)
    signal sessionRequestUserAnswerResult(bool accept, string error)

    function pair(pairLink)
    {
        wcCalls.pair(pairLink)
    }

    function approvePairSession(sessionProposal, supportedNamespaces)
    {
        wcCalls.approvePairSession(sessionProposal, supportedNamespaces)
    }

    function rejectPairSession(id)
    {
        wcCalls.rejectPairSession(id)
    }

    function acceptSessionRequest(topic, id, signature) {
        wcCalls.acceptSessionRequest(topic, id, signature)
    }

    function rejectSessionRequest(topic, id, error) {
        wcCalls.rejectSessionRequest(topic, id, error)
    }

    QtObject {
        id: d

        property bool sdkReady: false
        property ListModel pairingsModel: pairings

        property WebEngineView engine: loader.instance

        onSdkReadyChanged: {
            if (sdkReady)
            {
                d.resetPairingsModel()
            }
        }

        function resetPairingsModel(entryCallback)
        {
            pairings.clear();

            wcCalls.getPairings((pairList) => {
                for (let i = 0; i < pairList.length; i++) {
                    pairings.append({
                        active: pairList[i].active,
                        topic: pairList[i].topic,
                        expiry: pairList[i].expiry
                    });
                    if (entryCallback) {
                        entryCallback(pairList[i])
                    }
                }
            })
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

            d.engine.runJavaScript(`wc.init("${root.projectId}")`, function(result) {

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

                console.debug(`WC WalletConnectSDK.wcCall.getPairings; response: ${JSON.stringify(result, null, 2)}`)

                if (result)
                {
                    if (!!result.error) {
                        console.error("getPairings: ", result.error)
                        return
                    }

                    callback(result.result)
                    return
                }
            })
        }

        function pair(pairLink) {
            console.debug(`WC WalletConnectSDK.wcCall.pair; pairLink: ${pairLink}`)

            wcCalls.getPairings((allPairings) => {

                                    console.debug(`WC WalletConnectSDK.wcCall.pair; response: ${JSON.stringify(allPairings, null, 2)}`)

                                    let pairingTopic = d.getPairingTopicFromPairingUrl(pairLink);

                                    // Find pairing by topic
                                    const pairing = allPairings.find((p) => p.topic === pairingTopic);
                                    if (pairing)
                                    {
                                        if (pairing.active) {
                                            console.warn("pair: already paired")
                                            return
                                        }
                                    }

                                    d.engine.runJavaScript(`wc.pair("${pairLink}")`, function(result) {
                                        if (result && !!result.error)
                                        {
                                            console.error("pair: ", result.error)
                                        }
                                    })
                                }
                                )
        }

        function approvePairSession(sessionProposal, supportedNamespaces) {
            console.debug(`WC WalletConnectSDK.wcCall.approvePairSession; sessionProposal: ${JSON.stringify(sessionProposal)}, supportedNamespaces: ${JSON.stringify(supportedNamespaces)}`)

            d.engine.runJavaScript(`wc.approvePairSession(${JSON.stringify(sessionProposal)}, ${JSON.stringify(supportedNamespaces)})`, function(result) {

                console.debug(`WC WalletConnectSDK.wcCall.approvePairSession; response: ${JSON.stringify(result, null, 2)}`)

                if (result) {
                    if (!!result.error)
                    {
                        console.error("approvePairSession: ", result.error)
                        root.pairAcceptedResult(sessionProposal, false, result.error)
                        return
                    }
                    // Update the temporary expiry with the one from the pairing
                    d.resetPairingsModel((pairing) => {
                        if (pairing.topic === sessionProposal.params.pairingTopic) {
                            sessionProposal.params.expiry = pairing.expiry
                            root.pairAcceptedResult(sessionProposal, true, result.error)
                        }
                    })
                }
            })
        }

        function rejectPairSession(id) {
            console.debug(`WC WalletConnectSDK.wcCall.rejectPairSession; id: ${id}`)

            d.engine.runJavaScript(`wc.rejectPairSession(${id})`, function(result) {

                console.debug(`WC WalletConnectSDK.wcCall.rejectPairSession; response: ${JSON.stringify(result, null, 2)}`)

                d.resetPairingsModel()
                if (result) {
                    if (!!result.error)
                    {
                        console.error("rejectPairSession: ", result.error)
                        root.pairRejectedResult(false, result.error)
                        return
                    }
                    root.pairRejectedResult(true, result.error)
                }
            })
        }

        function acceptSessionRequest(topic, id, signature) {
            console.debug(`WC WalletConnectSDK.wcCall.acceptSessionRequest; topic: "${topic}", id: ${id}, signature: "${signature}"`)

            d.engine.runJavaScript(`wc.respondSessionRequest("${topic}", ${id}, "${signature}")`, function(result) {

                console.debug(`WC WalletConnectSDK.wcCall.acceptSessionRequest; response: ${JSON.stringify(allPairings, null, 2)}`)

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
            })
        }

        function rejectSessionRequest(topic, id, error) {
            console.debug(`WC WalletConnectSDK.wcCall.rejectSessionRequest; topic: "${topic}", id: ${id}, error: "${error}"`)

            d.engine.runJavaScript(`wc.rejectSessionRequest("${topic}", ${id}, "${error}")`, function(result) {

                console.debug(`WC WalletConnectSDK.wcCall.rejectSessionRequest; response: ${JSON.stringify(result, null, 2)}`)

                if (result) {
                    if (!!result.error)
                    {
                        console.error("rejectSessionRequest: ", result.error)
                        root.sessionRequestUserAnswerResult(false, result.error)
                        return
                    }
                    root.sessionRequestUserAnswerResult(false, result.error)
                }
                d.resetPairingsModel()
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

        function sdkInitialized(error)
        {
            d.sdkReady = !error
            root.sdkInit(d.sdkReady, error)
        }

        function onSessionProposal(details)
        {
            console.debug(`WC WalletConnectSDK.onSessionProposal; details: ${JSON.stringify(details, null, 2)}`)
            root.pairSessionProposal(true, details)
        }

        function onSessionUpdate(details)
        {
            console.debug(`WC TODO WalletConnectSDK.onSessionUpdate; details: ${JSON.stringify(details, null, 2)}`)
        }

        function onSessionExtend(details)
        {
            console.debug(`WC TODO WalletConnectSDK.onSessionExtend; details: ${JSON.stringify(details, null, 2)}`)
        }

        function onSessionPing(details)
        {
            console.debug(`WC TODO WalletConnectSDK.onSessionPing; details: ${JSON.stringify(details, null, 2)}`)
        }

        function onSessionDelete(details)
        {
            console.debug(`WC TODO WalletConnectSDK.onSessionDelete; details: ${JSON.stringify(details, null, 2)}`)
        }

        function onSessionExpire(details)
        {
            console.debug(`WC TODO WalletConnectSDK.onSessionExpire; details: ${JSON.stringify(details, null, 2)}`)
        }

        function onSessionRequest(details)
        {
            console.debug(`WC WalletConnectSDK.onSessionRequest; details: ${JSON.stringify(details, null, 2)}`)
            root.sessionRequestEvent(details)
        }

        function onSessionRequestSent(details)
        {
            console.debug(`WC TODO WalletConnectSDK.onSessionRequestSent; details: ${JSON.stringify(details, null, 2)}`)
        }

        function onSessionEvent(details)
        {
            console.debug(`WC TODO WalletConnectSDK.onSessionEvent; details: ${JSON.stringify(details, null, 2)}`)
        }

        function onProposalExpire(details)
        {
            console.debug(`WC WalletConnectSDK.onProposalExpire; details: ${JSON.stringify(details, null, 2)}`)
            root.pairSessionProposalExpired()
        }
    }

    ListModel {
        id: pairings
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
