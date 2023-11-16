import QtQuick 2.15
import QtWebEngine 1.10
import QtWebChannel 1.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import StatusQ.Core.Utils 0.1 as SQUtils

Item {
    id: root

    required property string projectId
    readonly property alias sdkReady: d.sdkReady
    readonly property alias pairingsModel: d.pairingsModel

    implicitWidth: 1
    implicitHeight: 1

    signal statusChanged(string message)
    signal sdkInit(bool success, var result)
    signal pairSessionProposal(bool success, var sessionProposal)
    signal pairSessionProposalExpired()
    signal pairAcceptedResult(bool success, var sessionType)
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

        onSdkReadyChanged: {
            if (sdkReady)
            {
                d.resetPairingsModel()
            }
        }

        function resetPairingsModel()
        {
            pairings.clear();

            wcCalls.getPairings((pairList) => {
                                    for (let i = 0; i < pairList.length; i++) {
                                        pairings.append({
                                                            active: pairList[i].active,
                                                            topic: pairList[i].topic,
                                                            expiry: pairList[i].expiry
                                                        });
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
            console.debug(`@dd WalletConnectSDK.wcCall.init; root.projectId: ${root.projectId}`)

            webEngineView.runJavaScript(`wc.init("${root.projectId}")`, function(result) {

                console.debug(`@dd WalletConnectSDK.wcCall.init; response: ${JSON.stringify(result, null, 2)}`)

                if (result && !!result.error)
                {
                    console.error("init: ", result.error)
                }
            })
        }

        function getPairings(callback) {
            console.debug(`@dd WalletConnectSDK.wcCall.getPairings;`)

            webEngineView.runJavaScript(`wc.getPairings()`, function(result) {

                console.debug(`@dd WalletConnectSDK.wcCall.getPairings; response: ${JSON.stringify(result, null, 2)}`)

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
            console.debug(`@dd WalletConnectSDK.wcCall.pair; pairLink: ${pairLink}`)

            wcCalls.getPairings((allPairings) => {

                                    console.debug(`@dd WalletConnectSDK.wcCall.pair; response: ${JSON.stringify(allPairings, null, 2)}`)

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

                                    webEngineView.runJavaScript(`wc.pair("${pairLink}")`, function(result) {
                                        if (result && !!result.error)
                                        {
                                            console.error("pair: ", result.error)
                                        }
                                    })
                                }
                                )
        }

        function approvePairSession(sessionProposal, supportedNamespaces) {
            console.debug(`@dd WalletConnectSDK.wcCall.approvePairSession; sessionProposal: ${JSON.stringify(sessionProposal)}, supportedNamespaces: ${JSON.stringify(supportedNamespaces)}`)

            webEngineView.runJavaScript(`wc.approvePairSession(${JSON.stringify(sessionProposal)}, ${JSON.stringify(supportedNamespaces)})`, function(result) {

                console.debug(`@dd WalletConnectSDK.wcCall.approvePairSession; response: ${JSON.stringify(result, null, 2)}`)

                if (result) {
                    if (!!result.error)
                    {
                        console.error("approvePairSession: ", result.error)
                        root.pairAcceptedResult(false, result.error)
                        return
                    }
                    root.pairAcceptedResult(true, result.error)
                }
                d.resetPairingsModel()
            })
        }

        function rejectPairSession(id) {
            console.debug(`@dd WalletConnectSDK.wcCall.rejectPairSession; id: ${id}`)

            webEngineView.runJavaScript(`wc.rejectPairSession(${id})`, function(result) {

                console.debug(`@dd WalletConnectSDK.wcCall.rejectPairSession; response: ${JSON.stringify(result, null, 2)}`)

                if (result) {
                    if (!!result.error)
                    {
                        console.error("rejectPairSession: ", result.error)
                        root.pairRejectedResult(false, result.error)
                        return
                    }
                    root.pairRejectedResult(true, result.error)
                }
                d.resetPairingsModel()
            })
        }

        function acceptSessionRequest(topic, id, signature) {
            console.debug(`@dd WalletConnectSDK.wcCall.acceptSessionRequest; topic: "${topic}", id: ${id}, signature: "${signature}"`)

            webEngineView.runJavaScript(`wc.respondSessionRequest("${topic}", ${id}, "${signature}")`, function(result) {

                console.debug(`@dd WalletConnectSDK.wcCall.acceptSessionRequest; response: ${JSON.stringify(allPairings, null, 2)}`)

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
            console.debug(`@dd WalletConnectSDK.wcCall.rejectSessionRequest; topic: "${topic}", id: ${id}, error: "${error}"`)

            webEngineView.runJavaScript(`wc.rejectSessionRequest("${topic}", ${id}, "${error}")`, function(result) {

                console.debug(`@dd WalletConnectSDK.wcCall.rejectSessionRequest; response: ${JSON.stringify(result, null, 2)}`)

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

        function sdkInitialized(error)
        {
            d.sdkReady = !error
            root.sdkInit(d.sdkReady, error)
        }

        function onSessionProposal(details)
        {
            console.debug(`@dd WalletConnectSDK.onSessionProposal; details: ${JSON.stringify(details, null, 2)}`)
            root.pairSessionProposal(true, details)
        }

        function onSessionUpdate(details)
        {
            console.debug(`@dd TODO WalletConnectSDK.onSessionUpdate; details: ${JSON.stringify(details, null, 2)}`)
        }

        function onSessionExtend(details)
        {
            console.debug(`@dd TODO WalletConnectSDK.onSessionExtend; details: ${JSON.stringify(details, null, 2)}`)
        }

        function onSessionPing(details)
        {
            console.debug(`@dd TODO WalletConnectSDK.onSessionPing; details: ${JSON.stringify(details, null, 2)}`)
        }

        function onSessionDelete(details)
        {
            console.debug(`@dd TODO WalletConnectSDK.onSessionDelete; details: ${JSON.stringify(details, null, 2)}`)
        }

        function onSessionExpire(details)
        {
            console.debug(`@dd TODO WalletConnectSDK.onSessionExpire; details: ${JSON.stringify(details, null, 2)}`)
        }

        function onSessionRequest(details)
        {
            console.debug(`@dd WalletConnectSDK.onSessionRequest; details: ${JSON.stringify(details, null, 2)}`)
            root.sessionRequestEvent(details)
        }

        function onSessionRequestSent(details)
        {
            console.debug(`@dd TODO WalletConnectSDK.onSessionRequestSent; details: ${JSON.stringify(details, null, 2)}`)
        }

        function onSessionEvent(details)
        {
            console.debug(`@dd TODO WalletConnectSDK.onSessionEvent; details: ${JSON.stringify(details, null, 2)}`)
        }

        function onProposalExpire(details)
        {
            console.debug(`@dd WalletConnectSDK.onProposalExpire; details: ${JSON.stringify(details, null, 2)}`)
            root.pairSessionProposalExpired()
        }
    }

    ListModel {
        id: pairings
    }

    WebChannel {
        id: statusChannel
        registeredObjects: [statusObject]
    }

    WebEngineView {
        id: webEngineView

        anchors.fill: parent

        url: "qrc:/app/AppLayouts/Wallet/views/walletconnect/sdk/src/index.html"
        webChannel: statusChannel

        onLoadingChanged: function(loadRequest) {
            console.debug(`@dd WalletConnectSDK.onLoadingChanged; status: ${loadRequest.status}; error: ${loadRequest.errorString}`)
            switch(loadRequest.status) {
            case WebEngineView.LoadSucceededStatus:
                wcCalls.init()
                break
            case WebEngineView.LoadFailedStatus:
                root.statusChanged(`<font color="red">Failed loading SDK JS code; error: "${loadRequest.errorString}"</font>`)
                break
            case WebEngineView.LoadStartedStatus:
                root.statusChanged(`<font color="blue">Loading SDK JS code</font>`)
                break
            }
        }
    }
}
