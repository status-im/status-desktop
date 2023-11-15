import QtQuick 2.15
import QtTest 1.0

//import StatusQ 0.1 // https://github.com/status-im/status-desktop/issues/10218

import StatusQ.Components 0.1

import StatusQ.TestHelpers 0.1

TestCase {
    id: root
    name: "StatusWebView"

    Component {
        id: webViewComponent
        StatusWebView {
            id: webView
            url: "StatusWebView/test.html"

            anchors.fill: parent
        }
    }

    SignalSpy {
        id: spyLoaded
        target: webView
        signalName: "contentReady"
    }

    Component {
        id: promiseResultComponent
        QtObject {
            property var result: null
            property bool success: false
            property bool completed: false
        }
    }

    property StatusWebView webView: null

    function init() {
        webView = webViewComponent.createObject(root);
    }

    function cleanup() {
        webView.destroy();
    }

    function test_asyncFunction() {
        spyLoaded.wait(1000);
        const callbackInfo = promiseResultComponent.createObject(null);
        var promise = webView.asyncCall("window.asyncFunction", "'asyncFunctionParam'");

        promise.then(function(result) {
            callbackInfo.result = result;
            callbackInfo.completed = true;
            callbackInfo.success = true;
        }).error(function(error) {
            callbackInfo.result = error;
            callbackInfo.completed = true;
            callbackInfo.success = false;
        });
        tryCompare(callbackInfo, "completed", true, 1000, "The promise should complete");
        compare(callbackInfo.result, "asyncFunctionParam", "The promise should return the success result")
        compare(callbackInfo.success, true, "The promise should succeed")
    }

    function test_rejectAsyncFunction() {
        spyLoaded.wait(1000);
        const callbackInfo = promiseResultComponent.createObject(null);
        var promise = webView.asyncCall("window.asyncRejectFunction", "'asyncRejectFunctionParam'");

        promise.then(function(result) {
            callbackInfo.result = result;
            callbackInfo.completed = true;
            callbackInfo.success = true;
        }).error(function(error) {
            callbackInfo.result = error;
            callbackInfo.completed = true;
            callbackInfo.success = false;
        });
        tryCompare(callbackInfo, "completed", true, 1000, "The promise should complete");
        compare(callbackInfo.result, "asyncRejectFunctionParam", "The promise should return the success result")
        compare(callbackInfo.success, false, "The promise should fail")
    }

    function test_asyncCallMissing() {
        spyLoaded.wait(1000);
        const callbackInfo = promiseResultComponent.createObject(null);
        var promise = webView.asyncCall("window.missingFunction", "'exceptionAsyncFunctionParam'");

        promise.then(function(result) {
            callbackInfo.result = result;
            callbackInfo.completed = true;
            callbackInfo.success = true;
        }).error(function(error) {
            callbackInfo.result = error;
            callbackInfo.completed = true;
            callbackInfo.success = false;
        });
        tryCompare(callbackInfo, "completed", true, 1000, "The promise should complete");
        compare(callbackInfo.result, "window.missingFunction is not a function", "The promise should return a specific error message")
        compare(callbackInfo.success, false, "The promise should fail")
    }

    function test_registerLate() {
        spyLoaded.wait(1000);
        let asyncFinalized = {done: false}
        var promise = webView.call("window.syncFunction", "'syncFunctionParam'");
        var asyncPromise = webView.asyncCall("window.asyncFunction", "'asyncFunctionParam'");

        asyncPromise.then(function(result) {
            asyncFinalized.done = true;
        });
        tryCompare(asyncFinalized, "done", true, 1000, "The promise should complete");

        const callbackInfo = promiseResultComponent.createObject(null);
        promise.then(function(result) {
            callbackInfo.result = result;
            callbackInfo.completed = true;
            callbackInfo.success = true
        }).error(function(error) {
            callbackInfo.result = error;
            callbackInfo.completed = true;
            callbackInfo.success = false;
        })
        compare(callbackInfo.completed, true, "The synchronous promise should complete serially");
        compare(callbackInfo.result, "syncFunctionParam", ".then should report the passed param")
        compare(callbackInfo.success, true, "The promise should succeed")
    }

    function test_synchronousCall() {
        spyLoaded.wait(1000);

        const callbackInfo = promiseResultComponent.createObject(null);

        var promise = webView.call("window.syncFunction", "'syncFunctionParam'");

        promise.then(function(result) {
            callbackInfo.result = result;
            callbackInfo.completed = true;
            callbackInfo.success = true
        }).error(function(error) {
            callbackInfo.result = error;
            callbackInfo.completed = true;
            callbackInfo.success = false;
        })
        tryCompare(callbackInfo, "completed", true, 1000, "The synchronous promise should complete");
        compare(callbackInfo.result, "syncFunctionParam", ".then should report the passed param")
        compare(callbackInfo.success, true, "The promise should succeed")
    }

    function test_synchronousCallThrows() {
        spyLoaded.wait(1000);

        const callbackInfo = promiseResultComponent.createObject(null);

        var promise = webView.call("window.syncFunctionThrows", "'syncFunctionThrowsParam'");

        promise.then(function(result) {
            callbackInfo.result = result;
            callbackInfo.completed = true;
            callbackInfo.success = true
        }).error(function(error) {
            callbackInfo.result = error;
            callbackInfo.completed = true;
            callbackInfo.success = false;
        })
        tryCompare(callbackInfo, "completed", true, 1000, "The synchronous promise should complete");
        compare(callbackInfo.result, "Test exception", ".error should report a specific exception message")
        compare(callbackInfo.success, false, "The promise should succeed")
    }

    function test_synchronousCallMissing() {
        spyLoaded.wait(1000);

        const callbackInfo = promiseResultComponent.createObject(null);

        var promise = webView.call("window.missingFunction", "'missingFunctionParam'");

        promise.then(function(result) {
            callbackInfo.completed = true;
            callbackInfo.success = true
        }).error(function(error) {
            callbackInfo.result = error;
            callbackInfo.completed = true;
            callbackInfo.success = false;
        })
        tryCompare(callbackInfo, "completed", true, 1000, "The synchronous promise should complete");
        compare(callbackInfo.success, false, "The promise should succeed")
        compare(callbackInfo.result, "window.missingFunction is not a function", ".error should report a specific error message")
    }

    // function test_onCallback() {
    //     spyLoaded.wait(1000);

    //     const callbackInfo = promiseResultComponent.createObject(null);

    //     let testInfo = {counter: 0}

    //     webView.onCallback("document.addEventListener", `"testEvent"`, function(payload, error) {
    //         compare(payload, "testDetail", "The payload should be passed to the callback")
    //         testInfo.counter++;
    //     })

    //     webView.call("window.sendEvent", "'testDetail'");

    //     tryCompare(testInfo, "counter", 2, 1000, "Expects a specific number of calls");
    // }
}
