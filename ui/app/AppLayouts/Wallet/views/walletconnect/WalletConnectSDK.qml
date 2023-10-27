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

    signal sdkInit(bool success, var result)
    signal pairSessionProposal(bool success, var sessionProposal)
    signal pairAcceptedResult(bool success, var sessionType)
    signal pairRejectedResult(bool success, var result)
    signal responseTimeout()

    // TODO: proper report
    signal statusChanged(string message)

    function pair(pairLink) {
        let callStr = d.generateSdkCall("pair", `"${pairLink}"`, RequestCodes.PairSuccess, RequestCodes.PairError)
        d.requestSdk(callStr)
    }

    function approvePairSession(sessionProposal, supportedNamespaces) {
        let callStr = d.generateSdkCall("approvePairSession", `${JSON.stringify(sessionProposal)}, ${JSON.stringify(supportedNamespaces)}`, RequestCodes.ApprovePairSuccess, RequestCodes.ApprovePairSuccess)

        d.requestSdk(callStr)
    }

    function rejectPairSession(id) {
        let callStr = d.generateSdkCall("rejectPairSession", id, RequestCodes.RejectPairSuccess, RequestCodes.RejectPairError)

        d.requestSdk(callStr)
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
            // case WebEngineView.LoadStoppedStatus:
                // root.statusChanged(`<font color="pink">STOPPED loading SDK JS code</font>`)
                // break
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
        root.loadHtml(htmlSrc, "http://status.im")
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
                        console.debug(`@dd wcResult - ${JSON.stringify(wcResult)}`)
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
                                break
                            case RequestCodes.SdkInitError:
                                d.sdkReady = false
                                root.sdkInit(false, wcResult.error)
                                break
                            case RequestCodes.PairSuccess:
                                root.pairSessionProposal(true, wcResult.result)
                                break
                            case RequestCodes.PairError:
                                root.pairSessionProposal(false, wcResult.error)
                                break
                            case RequestCodes.ApprovePairSuccess:
                                root.pairAcceptedResult(true, "")
                                break
                            case RequestCodes.ApprovePairError:
                                root.pairAcceptedResult(false, wcResult.error)
                                break
                            case RequestCodes.RejectPairSuccess:
                                root.pairRejectedResult(true, "")
                                break
                            case RequestCodes.RejectPairError:
                                root.pairRejectedResult(false, wcResult.error)
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

    QtObject {
        id: d

        property var sessionProposal: null
        property var sessionType: null
        property bool sdkReady: false

        function isWaitingForSdk() {
            return timer.running
        }


        function generateSdkCall(methodName, paramsStr, successState, errorState) {
            return "wcResult = {error: null}; try { wc." + methodName  + "(" + paramsStr + ").then((callRes) => { wcResult = {state: " + successState + ", error: null, result: callRes}; }).catch((error) => { wcResult = {state: " + errorState + ", error: error}; }); } catch (e) { wcResult = {state: " + errorState + ", error: \"Exception: \" + e.message}; }; wcResult"
        }
        function requestSdk(jsCode) {
            root.runJavaScript(jsCode,
                function(result) {
                    timer.restart()
                }
            )
        }

        function init(projectId) {
            console.debug(`@dd WC projectId - ${projectId}`)
            d.requestSdk(generateSdkCall("init", `"${projectId}"`, RequestCodes.SdkInitSuccess, RequestCodes.SdkInitError))
        }
    }
}