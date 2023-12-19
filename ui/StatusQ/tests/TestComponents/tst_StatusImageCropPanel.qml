import QtQuick 2.0
import QtTest 1.0

import StatusQ 0.1 // https://github.com/status-im/status-desktop/issues/10218

import StatusQ.Components 0.1
import StatusQ.Controls 0.1

import StatusQ.TestHelpers 0.1

Item {
    id: root
    width: 400
    height: 300

    Component {
        id: noSourceComponent

        StatusImageCropPanel {
            anchors.fill: parent

            windowStyle: StatusImageCrop.WindowStyle.Rounded
        }
    }

    property url testImageUrl: `${Qt.resolvedUrl(".")}../../sandbox/demoapp/data/logo-test-image.png`

    Component {
        id: withSourceComponent

        StatusImageCropPanel {
            anchors.fill: parent

            // TODO: generate test image and break the sandbox dependency
            source: root.testImageUrl
            windowStyle: StatusImageCrop.WindowStyle.Rectangular
            Component.onCompleted: setCropRect(Qt.rect(10, 0, sourceSize.width - 20, sourceSize.height))
        }
    }

    Loader {
        id: testLoader

        anchors.fill: parent
        active: false
    }

    TestCase {
        id: qmlWarningsTest

        name: "StatusImageCropPanel"

        when: windowShown

        //
        // Test guards

        function init() {
            qtOuput.restartCapturing()
        }

        function cleanup() {
            testLoader.active = false
        }

        //
        // Tests

        function test_no_source_initialization() {
            testLoader.sourceComponent = noSourceComponent
            testLoader.active = true
            verify(waitForRendering(testLoader.item))
            testLoader.active = false
            verify(qtOuput.qtOuput().length === 0, `No output expected. Found:\n"${qtOuput.qtOuput()}"\n`)
        }

        function test_with_source_initialization() {
            testLoader.sourceComponent = withSourceComponent
            testLoader.active = true
            verify(waitForRendering(testLoader.item))
            testLoader.active = false
            verify(qtOuput.qtOuput().length === 0, `No output expected. Found:\n"${qtOuput.qtOuput()}"\n`)
        }

        function test_setCrop_error_if_no_source_regression() {
            testLoader.sourceComponent = noSourceComponent
            testLoader.active = true
            verify(waitForRendering(testLoader.item))
            testLoader.item.setCropRect(Qt.rect(10, 10, 300, 300))
            verify(qtOuput.qtOuput().length !== 0, `No output expected. Found:\n"${qtOuput.qtOuput()}"\n`)
            qtOuput.restartCapturing()
            testLoader.item.source = root.testImageUrl
            verify(waitForRendering(testLoader.item))
            testLoader.active = false
            verify(qtOuput.qtOuput().length === 0, `No output expected. Found:\n"${qtOuput.qtOuput()}"\n`)
        }
    }

    MonitorQtOutput {
        id: qtOuput
    }
}
