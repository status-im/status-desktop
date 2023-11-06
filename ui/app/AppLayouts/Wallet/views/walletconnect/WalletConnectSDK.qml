import QtQuick 2.15
import QtWebView 1.15
// TODO #12434: remove debugging WebEngineView code
// import QtWebEngine 1.10
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import StatusQ.Core.Utils 0.1 as SQUtils

// Control used to instantiate and run the the WalletConnect web SDK
// The view is not used to draw anything, but has to be visible to be able to run JS code
// Use the \c backgroundColor property to blend in with the background
// \warning A too smaller height might cause rendering errors
// TODO #12434: remove debugging WebEngineView code
WebView {
//WebEngineView {
    id: root

    implicitWidth: 1
    implicitHeight: 1

    required property string projectId
    required property color backgroundColor

    readonly property alias sdkReady: d.sdkReady
    readonly property alias pairingsModel: d.pairingsModel

    signal sdkInit(bool success, var result)
    signal pairSessionProposal(bool success, var sessionProposal)
    signal pairAcceptedResult(bool success, var sessionType)
    signal pairRejectedResult(bool success, var result)
    signal sessionRequestEvent(var sessionRequest)
    signal sessionRequestUserAnswerResult(bool accept, string error)
    signal responseTimeout()

    // TODO: proper report
    signal statusChanged(string message)

    function pair(pairLink) {
        let callStr = d.generateSdkCall("pair", `"${pairLink}"`, RequestCodes.PairSuccess, RequestCodes.PairError)
        d.requestSdkAsync(callStr)
    }

    function approvePairSession(sessionProposal, supportedNamespaces) {
        let callStr = d.generateSdkCall("approvePairSession", `${JSON.stringify(sessionProposal)}, ${JSON.stringify(supportedNamespaces)}`, RequestCodes.ApprovePairSuccess, RequestCodes.ApprovePairSuccess)

        d.requestSdkAsync(callStr)
    }

    function rejectPairSession(id) {
        let callStr = d.generateSdkCall("rejectPairSession", id, RequestCodes.RejectPairSuccess, RequestCodes.RejectPairError)

        d.requestSdkAsync(callStr)
    }

    function acceptSessionRequest(topic, id, signature) {
        let callStr = d.generateSdkCall("respondSessionRequest", `"${topic}", ${id}, "${signature}"`, RequestCodes.AcceptSessionSuccess, RequestCodes.AcceptSessionError)

        d.requestSdkAsync(callStr)
    }

    function rejectSessionRequest(topic, id, error) {
        let callStr = d.generateSdkCall("rejectSessionRequest", `"${topic}", ${id}, ${error}`, RequestCodes.RejectSessionSuccess, RequestCodes.RejectSessionError)

        d.requestSdkAsync(callStr)
    }

    // TODO #12434: remove debugging WebEngineView code
    onLoadingChanged: function(loadRequest) {
        console.debug(`@dd WalletConnectSDK.onLoadingChanged; status: ${loadRequest.status}; error: ${loadRequest.errorString}`)
        switch(loadRequest.status) {
            case WebView.LoadSucceededStatus:
            // case WebEngineView.LoadSucceededStatus:
                d.init(root.projectId)
                break
            case WebView.LoadFailedStatus:
            // case WebEngineView.LoadFailedStatus:
                root.statusChanged(`<font color="red">Failed loading SDK JS code; error: "${loadRequest.errorString}"</font>`)
                break
            case WebView.LoadStartedStatus:
            // case WebEngineView.LoadStartedStatus:
                root.statusChanged(`<font color="blue">Loading SDK JS code</font>`)
                break
        }
    }

    Component.onCompleted: {
        console.debug(`@dd WalletConnectSDK onCompleted`)
        var scriptSrc = SQUtils.StringUtils.readTextFile(":/app/AppLayouts/Wallet/views/walletconnect/sdk/generated/bundle.js")
        // Load bundle from disk if not found in resources (Storybook)
        if (scriptSrc === "") {
            scriptSrc = SQUtils.StringUtils.readTextFile("./AppLayouts/Wallet/views/walletconnect/sdk/generated/bundle.js")
            if (scriptSrc === "") {
                console.error("Failed to read WalletConnect SDK bundle")
                return
            }
        }

        let htmlSrc = `<!DOCTYPE html><html><head><!--<title>TODO: Test</title>--><script type='text/javascript'>${scriptSrc}</script></head><body style='background-color: ${root.backgroundColor.toString()};'></body></html>`

        console.debug(`@dd WalletConnectSDK.loadHtml; htmlSrc len: ${htmlSrc.length}`)
        root.loadHtml(htmlSrc, "https://status.app")
    }

    Timer {
        id: timer

        interval: 100
        repeat: true
        running: false
        triggeredOnStart: true

        property int errorCount: 0

        onTriggered: {
            root.runJavaScript(
                "wcResult",
                function(wcResult) {
                    if (!wcResult) {
                        return
                    }

                    let done = false
                    if (wcResult.error) {
                        console.debug(`WC JS error response - ${JSON.stringify(wcResult)}`)
                        done = true
                        if (!d.sdkReady) {
                            root.statusChanged(`<font color="red">[${timer.errorCount++}] Failed SDK init; error: ${wcResult.error}</font>`)
                        } else {
                            root.statusChanged(`<font color="red">[${timer.errorCount++}] Operation error: ${wcResult.error}</font>`)
                        }
                    }

                    if (wcResult.state !== undefined) {
                        switch (wcResult.state) {
                            case RequestCodes.SdkInitSuccess:
                                d.sdkReady = true
                                root.sdkInit(true, "")
                                d.startListeningForEvents()
                                break
                            case RequestCodes.SdkInitError:
                                d.sdkReady = false
                                root.sdkInit(false, wcResult.error)
                                break
                            case RequestCodes.PairSuccess:
                                root.pairSessionProposal(true, wcResult.result)
                                d.getPairings()
                                break
                            case RequestCodes.PairError:
                                root.pairSessionProposal(false, wcResult.error)
                                break
                            case RequestCodes.ApprovePairSuccess:
                                root.pairAcceptedResult(true, "")
                                d.getPairings()
                                break
                            case RequestCodes.ApprovePairError:
                                root.pairAcceptedResult(false, wcResult.error)
                                d.getPairings()
                                break
                            case RequestCodes.RejectPairSuccess:
                                root.pairRejectedResult(true, "")
                                break
                            case RequestCodes.RejectPairError:
                                root.pairRejectedResult(false, wcResult.error)
                                break
                            case RequestCodes.AcceptSessionSuccess:
                                root.sessionRequestUserAnswerResult(true, "")
                                break
                            case RequestCodes.AcceptSessionError:
                                root.sessionRequestUserAnswerResult(true, wcResult.error)
                                break
                            case RequestCodes.RejectSessionSuccess:
                                root.sessionRequestUserAnswerResult(false, "")
                                break
                            case RequestCodes.RejectSessionError:
                                root.sessionRequestUserAnswerResult(false, wcResult.error)
                                break
                            case RequestCodes.GetPairings:
                                d.populatePairingsModel(wcResult.result)
                                break
                            case RequestCodes.GetPairingsError:
                                console.error(`WalletConnectSDK - getPairings error: ${wcResult.error}`)
                                break
                            default: {
                                root.statusChanged(`<font color="red">[${timer.errorCount++}] Unknown state: ${wcResult.state}</font>`)
                            }
                        }

                        done = true
                    }

                    if (done) {
                        timer.stop()
                    }
                }
            )
        }
    }

    Timer {
        id: responseTimeoutTimer

        interval: 10000
        repeat: false
        running: timer.running

        onTriggered: {
            timer.stop()
            root.responseTimeout()
        }
    }

    Timer {
        id: eventsTimer

        interval: 100
        repeat: true
        running: false

        onTriggered: {
            root.runJavaScript("window.wcEventResult ? window.wcEventResult.shift() : null", function(event) {
                if (event) {
                    switch(event.name) {
                        case "session_request":
                            root.sessionRequestEvent(event.payload)
                            break
                        default:
                            console.error("WC unknown event type: ", event.type)
                            break
                    }
                }
            })
        }
    }

    QtObject {
        id: d

        property var sessionProposal: null
        property var sessionType: null
        property bool sdkReady: false

        property ListModel pairingsModel: pairings

        onSdkReadyChanged: {
            if (sdkReady) {
                d.getPairings()
            }
        }

        function populatePairingsModel(pairList) {
            pairings.clear();
            for (let i = 0; i < pairList.length; i++) {
                pairings.append({
                    active: pairList[i].active,
                    topic: pairList[i].topic,
                    expiry: pairList[i].expiry
                });
            }
        }


        function isWaitingForSdk() {
            return timer.running
        }

        function generateSdkCall(methodName, paramsStr, successState, errorState) {
            return "wcResult = {}; try { wc." + methodName  + "(" + paramsStr + ").then((callRes) => { wcResult = {state: " + successState + ", error: null, result: callRes}; }).catch((error) => { wcResult = {state: " + errorState + ", error: error}; }); } catch (e) { wcResult = {state: " + errorState + ", error: \"Exception: \" + e.message}; }; wcResult"
        }
        function requestSdkAsync(jsCode) {
            root.runJavaScript(jsCode,
                function(result) {
                    timer.restart()
                }
            )
        }

        function requestSdk(methodName, paramsStr, successState, errorState) {
            const jsCode = "wcResult = {}; try { const callRes = wc." + methodName + "(" + (paramsStr ? (paramsStr) : "") + "); wcResult = {state: " + successState + ", error: null, result: callRes}; } catch (e) { wcResult = {state: " + errorState + ", error: \"Exception: \" + e.message};  }; wcResult"
            root.runJavaScript(jsCode,
                function(result) {
                    timer.restart()
                }
            )
        }

        function startListeningForEvents() {
            const jsCode = "
                try {
                    function processWCEvents() {
                        window.wcEventResult = [];
                        window.wcEventError = null
                        window.wc.registerForSessionRequest((event) => {
                            window.wcEventResult.push({name: 'session_request', payload: event});
                        });
                    }
                    processWCEvents();
                } catch (e) {
                    window.wcEventError = e
                }
                window.wcEventError"

            root.runJavaScript(jsCode,
                function(result) {
                    if (result) {
                        console.error("startListeningForEvents: processWCEvents error", result)
                        return
                    }
                }
            )
            eventsTimer.start()
        }

        function init(projectId) {
            d.requestSdkAsync(generateSdkCall("init", `"${projectId}"`, RequestCodes.SdkInitSuccess, RequestCodes.SdkInitError))
        }

        function getPairings(projectId) {
            d.requestSdk("getPairings", `null`, RequestCodes.GetPairings, RequestCodes.GetPairingsError)
        }
    }

    ListModel {
        id: pairings
    }
}