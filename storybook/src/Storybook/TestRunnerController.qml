import QtQml 2.15

import Storybook 1.0

QtObject {
    id: root

    readonly property alias running: d.running
    readonly property alias aborted: d.aborted

    signal started
    signal finished(int failedTests, bool aborted, bool crashed)

    function getTestsCount(testFileName) {
        return TestsRunner.testsCount(testFileName)
    }

    function getTestsPath() {
        return Qt.resolvedUrl(TestsRunner.testsPath())
    }

    function runTests(testFileName) {
        if (d.testProcess) {
            d.testProcess.finished.disconnect(d.processFinishedHandler)
            d.testProcess.kill()
            d.aborted = false
        }

        const process = TestsRunner.runTests(testFileName)
        d.testProcess = process
        d.running = true

        process.finished.connect(d.processFinishedHandler)

        started()
    }

    function abort() {
        d.aborted = true
        d.testProcess.kill()
    }

    readonly property QtObject _d: QtObject {
        id: d

        property var testProcess: null
        property bool aborted: false
        property bool running: false

        function processFinishedHandler(exitCode, exitStatus) {
            root.finished(exitCode, d.aborted, exitStatus !== 0)

            d.running = false
            d.aborted = false
        }
    }
}
