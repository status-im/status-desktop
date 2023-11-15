import QtQuick 2.15
import QtWebView 1.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import StatusQ.Core.Utils 0.1 as SQUtils
import StatusQ.Components 0.1

// Control used to instantiate and run the the WalletConnect web SDK
// The view is not used to draw anything, but has to be visible to be able to run JS code
// Use the \c backgroundColor property to blend in with the background
// \warning A too smaller height might cause rendering errors
StatusWebView {
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

    signal statusChanged(string message)

    function pair(pairLink) {
        root.asyncCall("wc.pair", `"${pairLink}"`).then((result) => {
            root.pairSessionProposal(true, result)
            d.getPairings()
        }).error((error) => {
            root.pairSessionProposal(false, error)
        })
    }

    function approvePairSession(sessionProposal, supportedNamespaces) {
        root.asyncCall("wc.approvePairSession", `${JSON.stringify(sessionProposal)}, ${JSON.stringify(supportedNamespaces)}`).then((result) => {
            root.pairAcceptedResult(true, "")
            d.getPairings()
        }).error((error) => {
            root.pairAcceptedResult(false, error)
            d.getPairings()
        })
    }

    function rejectPairSession(id) {
        root.asyncCall("wc.rejectPairSession", id).then((result) => {
            root.pairRejectedResult(true, "")
        }).error((error) => {
            root.pairRejectedResult(false, error)
        })
    }

    function acceptSessionRequest(topic, id, signature) {
        root.asyncCall("wc.respondSessionRequest", `"${topic}", ${id}, "${signature}"`).then((result) => {
            root.sessionRequestUserAnswerResult(true, "")
        }).error((error) => {
            root.sessionRequestUserAnswerResult(true, error)
        })
    }

    function rejectSessionRequest(topic, id, error) {
        root.asyncCall("wc.rejectSessionRequest", `"${topic}", ${id}, ${error}`).then((result) => {
            root.sessionRequestUserAnswerResult(false, "")
        }).error((error) => {
            root.sessionRequestUserAnswerResult(false, error)
        })
    }

    onContentReady: {
        root.asyncCall("wc.init", `"${projectId}"`).then((result) => {
            d.sdkReady = true
            root.sdkInit(true, "")
            d.startListeningForEvents()
            d.getPairings()
        }).error((error) => {
            d.sdkReady = false
            root.sdkInit(false, error)
        })
    }

    onContentFailedLoading: (errorString) => {
        root.statusChanged(`<font color="red">Failed loading SDK JS code; error: "${errorString}"</font>`)
    }

    Component.onCompleted: {
        var scriptSrc = SQUtils.StringUtils.readTextFile(":/app/AppLayouts/Wallet/views/walletconnect/sdk/generated/bundle.js")
        // Load bundle from disk if not found in resources (Storybook)
        if (scriptSrc === "") {
            scriptSrc = SQUtils.StringUtils.readTextFile("./AppLayouts/Wallet/views/walletconnect/sdk/generated/bundle.js")
            if (scriptSrc === "") {
                console.error("Failed to read WalletConnect SDK bundle")
                return
            }
        }

        let htmlSrc = `<!DOCTYPE html><html><head><script type='text/javascript'>${scriptSrc}</script></head><body style='background-color: ${root.backgroundColor.toString()};'></body></html>`

        root.loadHtml(htmlSrc, "https://status.app")
    }


    QtObject {
        id: d

        property var sessionProposal: null
        property var sessionType: null
        property bool sdkReady: false

        property ListModel pairingsModel: pairings

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
        }

        function getPairings(projectId) {
            root.call("wc.getPairings", "").then((result) => {
                d.populatePairingsModel(result)
            }).error((error) => {
                console.error(`WalletConnectSDK - getPairings error: ${error}`)
            })
        }
    }

    ListModel {
        id: pairings
    }
}