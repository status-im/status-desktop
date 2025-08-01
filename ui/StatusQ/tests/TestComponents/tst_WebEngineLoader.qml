import QtQuick
import QtTest

import QtWebEngine
import QtWebChannel

import StatusQ.Components
import StatusQ.TestHelpers

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
            url: Qt.resolvedUrl("./WebEngineLoader/test.html")
            webChannelObjects: [testObject]

            waitForInternet: false
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

        webEngineLoadedSpy.wait(1000)
        verify(webEngine.instance !== null , "The WebEngineView should be available")

        pageLoadedSpy.wait(1000)
        webEngine.active = false
        engineUnloadedSpy.wait(1000);

        verify(webEngine.instance === null , "The WebEngineView should be unavailable")
    }

    SignalSpy { id: wcInitOkSpy; target: testObject; signalName: "webChannelInitOk" }
    SignalSpy { id: wcInitErrorSpy; target: testObject; signalName: "webChannelError" }
    function test_executeCode() {
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
