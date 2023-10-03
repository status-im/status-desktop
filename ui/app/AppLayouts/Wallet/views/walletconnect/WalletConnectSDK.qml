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

    readonly property string notReadyState: "not-ready"
    readonly property string disconnectedState: "disconnected"
    readonly property string waitingPairState: "waiting_pairing"
    readonly property string pairedState: "paired"

    state: root.notReadyState

    property string optionalSdkPath: ""

    // TODO: proper report
    signal statusChanged(string message)

    function pair(pairLink) {
        d.requestSdk(
            "wcResult = {error: null}; try { wc.pair(\"" + pairLink + "\").then((sessionProposal) => { wcResult = {state: \"" + root.waitingPairState + "\", error: null, sessionProposal: sessionProposal}; }).catch((error) => { wcResult = {error: error}; }); } catch (e) { wcResult = {error: \"Exception: \" + e.message}; }; wcResult"
        )
    }

    function acceptPairing() {
        d.acceptPair(d.sessionProposal)
    }

    function rejectPairing() {
        d.rejectPair(d.sessionProposal.id)
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
                function(result) {
                    if (!result) {
                        return
                    }

                    let done = false
                    if (result.error) {
                        done = true
                        if (root.state === root.notReadyState) {
                            root.statusChanged(`<font color="red">[${timer.errorCount++}] Failed SDK init; error: ${result.error}</font>`)
                        } else {
                            root.state = root.disconnectedState
                            root.statusChanged(`<font color="red">[${timer.errorCount++}] Operation error: ${result.error}</font>`)
                        }
                    } else if (result.state) {
                        switch (result.state) {
                            case root.disconnectedState: {
                                root.statusChanged(`<font color="green">Ready to pair or auth</font>`)
                                break
                            }
                            case root.waitingPairState: {
                                d.sessionProposal = result.sessionProposal
                                root.statusChanged("Pair ID: " + result.sessionProposal.id + "; Topic: " + result.sessionProposal.params.pairingTopic)
                                break
                            }
                            case root.pairedState: {
                                d.sessionType = result.sessionType
                                root.statusChanged(`<font color="blue">Paired: ${JSON.stringify(result.sessionType)}</font>`)
                                break
                            }
                            case root.disconnectedState: {
                                root.statusChanged(`<font color="orange">User rejected PairID ${d.sessionProposal.id}</font>`)
                                break
                            }
                            default: {
                                root.statusChanged(`<font color="red">[${timer.errorCount++}] Unknown state: ${result.state}</font>`)
                                result.state = root.disconnectedState
                            }
                        }

                        root.state = result.state
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
            root.state = root.disconnectedState
            root.statusChanged(`<font color="red">Timeout waiting for response. The pairing might have been already attempted for the URI.</font>`)
        }
    }

    QtObject {
        id: d

        property var sessionProposal: null
        property var sessionType: null

        function isWaitingForSdk() {
            return timer.running
        }

        function requestSdk(jsCode) {
            console.debug(`@dd WalletConnectSDK.requestSdk; jsCode: ${jsCode}`)
            root.runJavaScript(jsCode,
                function(result) {
                    console.debug(`@dd WalletConnectSDK.requestSdk; result: ${JSON.stringify(result)}`)
                    timer.restart()
                }
            )
        }

        function init(projectId) {
            d.requestSdk(
                "wcResult = {error: null}; try { wc.init(\"" + projectId + "\").then((wc) => { wcResult = {state: \"" + root.disconnectedState + "\", error: null}; }).catch((error) => { wcResult = {error: error}; }); } catch (e) { wcResult = {error: \"Exception: \" + e.message}; }; wcResult"
            )
        }

        function acceptPair(sessionProposal) {
            d.requestSdk(
                "wcResult = {error: null}; try { wc.approveSession(" + JSON.stringify(sessionProposal) + ").then((sessionType) => { wcResult = {state: \"" + root.pairedState + "\", error: null, sessionType: sessionType}; }).catch((error) => { wcResult = {error: error}; }); } catch (e) { wcResult = {error: \"Exception: \" + e.message}; }; wcResult"
            )
        }

        function rejectPair(id) {
            d.requestSdk(
                "wcResult = {error: null}; try { wc.rejectSession(" + JSON.stringify(id) + ").then(() => { wcResult = {state: \"" + root.disconnectedState + "\", error: null}; }).catch((error) => { wcResult = {error: error}; }); } catch (e) { wcResult = {error: \"Exception: \" + e.message}; }; wcResult"
            )
        }
    }
}