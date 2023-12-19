import QtQuick 2.15
import QtTest 1.0

import QtWebEngine 1.10
import QtWebChannel 1.15

import StatusQ 0.1 // https://github.com/status-im/status-desktop/issues/10218

import StatusQ.Components 0.1

import StatusQ.TestHelpers 0.1

TestCase {
    id: root
    name: "TestWebEngineLoader"

    QtObject {
        id: testObject

        WebChannel.id: "testObject"

        signal webChannelInitOk()
        signal webChannelError()
        function signalWebChannelInitResult(error) {
            if(error) {
                webChannelError()
            } else {
                webChannelInitOk()
            }
        }
    }

    Loader {
        id: loader

        active: false

        sourceComponent: WebEngineLoader {
            url: "./WebEngineLoader/test.html"
            webChannelObjects: [testObject]
        }
    }
    SignalSpy { id: loadedSpy; target: loader; signalName: "loaded" }

    SignalSpy { id: webEngineLoadedSpy; target: loader.item; signalName: "engineLoaded" }
    SignalSpy { id: pageLoadedSpy; target: loader.item; signalName: "pageLoaded" }
    SignalSpy { id: engineUnloadedSpy; target: loader.item; signalName: "engineUnloaded" }
    SignalSpy { id: pageLoadingErrorSpy; target: loader.item; signalName: "onPageLoadingError" }

    function init() {
        for (var i = 0; i < root.children.length; i++) {
            const child = root.children[i]
            if(child.hasOwnProperty("signalName")) {
                child.clear()
            }
        }
        loader.active = true
        loadedSpy.wait(1000);
    }

    function cleanup() {
        loader.active = false
    }

    function test_loadUnload() {
        const webEngine = loader.item
        compare(webEngine.instance, null, "By default the engine is not loaded")
        webEngine.active = true

        webEngineLoadedSpy.wait(1000);
        verify(webEngine.instance !== null , "The WebEngineView should be available")

        if (Qt.platform.os === "linux") {
            skip("fails to load page on linux")
        }
        pageLoadedSpy.wait(1000);
        webEngine.active = false
        engineUnloadedSpy.wait(1000);

        verify(webEngine.instance === null , "The WebEngineView should be unavailable")
    }

    SignalSpy { id: wcInitOkSpy; target: testObject; signalName: "webChannelInitOk" }
    SignalSpy { id: wcInitErrorSpy; target: testObject; signalName: "webChannelError" }
    function test_executeCode() {
        if (Qt.platform.os === "linux") {
            skip("fails to load page on linux")
        }

        const webEngine = loader.item
        webEngine.active = true
        pageLoadedSpy.wait(1000);

        let errorResult = null
        webEngine.instance.runJavaScript(`
            window.testError = window.statusq.error;
            try {
                window.statusq.channel.objects.testObject.signalWebChannelInitResult("");
            } catch (e) {
                window.testError = e.message;
            }
            window.testError
        `, function(result) {
            errorResult = result
        })

        wcInitOkSpy.wait(1000);
        compare(errorResult, "", "Expected empty error string if all good")
    }
}
