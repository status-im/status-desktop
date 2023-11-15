import QtQuick 2.15
import QtWebView 1.15

// Specialization of \c WebView that provides a bridge between QML and JS code in the web page
// The bridge uses a polling mechanism for handing async responses
// TODO: stop timer when there is nothing to poll to
// TODO: simpler events
WebView {
    id: root

    // object name under the window object that will be used to cache internal runtime state
    property string globalObjectName: "statusq"

    signal contentReady();
    signal contentFailedLoading(string errorString);

    function asyncCall(callName, paramsStr) {
        return d.call(callName, paramsStr, d.callTypeAsync)
    }

    function call(callName, paramsStr) {
        return d.call(callName, paramsStr, d.callTypeSync)
    }

    // callback of type (result, error) => {}
    function onCallback(callName, callback) {
        d.call(callName, null, d.callTypeCallback).then(function(result) {
            callback(result, false)
        }).error(function(error) {
            callback(error, true)
        });
    }

    Timer {
        id: timer
        interval: 100
        repeat: true
        running: false

        onTriggered: {
            root.runJavaScript(`${d.ctx}.popCalls = ${d.ctx}.calls; ${d.ctx}.calls = null; ${d.ctx}.popCalls`, function(results) {
                if (!results) {
                    return;
                }
                d.pendingResults = d.pendingResults.concat(results);

                d.processPendingResults();
            });
        }
    }

    QtObject {
        id: d

        readonly property int successState: 1
        readonly property int errorState: 2
        readonly property int exceptionState: 3

        readonly property int callTypeAsync: 1
        readonly property int callTypeSync: 2
        readonly property int callTypeCallback: 3

        readonly property string ctx: `window.${root.globalObjectName}`

        property int nextCallIndex: 0
        property var callbacks: ({})
        property var pendingResults: []

        function call(callName, paramsStr, callType) {
            const currentCallIndex = d.nextCallIndex++;
            var jsCode = `
                if (!${d.ctx}) {
                    ${d.ctx} = {};
                }
                function reportCallResult(callIndex, state, result) {
                    if (!${d.ctx}.calls) {
                        ${d.ctx}.calls = [];
                    }
                    const callRes = {state: state, result: result, callIndex: callIndex};
                    ${d.ctx}.calls.push(callRes);
                }

                try {
                    switch(${callType}) {
                        case ${d.callTypeAsync}:
                            ${callName}(${paramsStr}).then((callRes) => {
                                reportCallResult(${currentCallIndex}, ${d.successState}, callRes);
                            }).catch((error) => {
                                reportCallResult(${currentCallIndex}, ${d.errorState}, error);
                            });
                        break;
                        case ${d.callTypeSync}:
                            const callRes = ${callName}(${paramsStr});
                            reportCallResult(${currentCallIndex}, ${d.successState}, callRes);
                        break;
                        case ${d.callTypeCallback}:
                            ${callName}(${paramsStr}, function(callRes) {
                                reportCallResult(${currentCallIndex}, ${d.successState}, callRes);
                            });
                    }
                } catch (e) {
                    ${d.ctx}.errorRes = {state: ${d.exceptionState}, result: e.message, callIndex: ${currentCallIndex}};
                }
                ${d.ctx}.errorRes
            `;

            let promise = promiseComponent.createObject(null, {callIndex: currentCallIndex})
            root.runJavaScript(jsCode, function(result) {
                d.callbacks[currentCallIndex] = promise;
                if (!result) {
                    timer.restart();
                    return;
                }

                // Process it now
                d.pendingResults = d.pendingResults.concat(result);
                d.processPendingResults();
            });

            return promise;
        }

        function processPendingResults() {
            while(pendingResults.length != 0) {
                const res = pendingResults[0]
                if(d.callbacks[res.callIndex]) {
                    const callback = d.callbacks[res.callIndex]
                    if (res.state === d.successState && callback.hasSuccess()) {
                        callback.successCallback(res.result)
                    } else if (res.state !== d.successState && callback.hasError()) {
                        callback.errorCallback(res.result)
                    } else {
                        callback.result = res
                    }
                    d.callbacks[res.callIndex] = null
                }

                pendingResults.splice(0, 1)
            }
        }
    }

    Component {
        id: promiseComponent

        QtObject {
            id: callbackObj

            function then(callback) {
                successCallback = callback;
                // If the callback is set after the result is available
                if (result && result.state === d.successState) {
                    successCallback(result.result);
                }
                return this;
            }

            function error(callback) {
                errorCallback = callback;
                // If the callback is set after the result is available
                if (result && result.state !== d.successState) {
                    successCallback(result.result);
                }
                return this;
            }

            function hasSuccess() {
                return successCallback !== null
            }
            function hasError() {
                return errorCallback !== null
            }

            property var successCallback: null
            property var errorCallback: null
            property int callIndex: -1
            property var result: null
        }
    }

    onLoadingChanged: function(loadRequest) {
        switch(loadRequest.status) {
            case WebView.LoadSucceededStatus:
                root.contentReady();
                break
            case WebView.LoadFailedStatus:
                root.contentFailedLoading(loadRequest.errorString);
                break
        }
    }
}