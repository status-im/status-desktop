import QtQuick 2.0
import QtTest 1.0

import StatusQ.Controls 0.1

import StatusQ.TestHelpers 0.1

Item {
    width: 400
    height: 300

    Component {
        id: noSourceComponent

        StatusImageCrop {
            anchors.fill: parent

            windowStyle: StatusImageCrop.WindowStyle.Rounded
        }
    }

    Component {
        id: withSourceComponent

        StatusImageCrop {
            anchors.fill: parent

            // TODO: generate test image and break the sandbox dependency
            source: `${Qt.resolvedUrl(".")}../../sandbox/demoapp/data/logo-test-image.png`
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

        name: "StatusImageCrop-CheckQmlWarnings"

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
    }

    StatusImageCrop {
        id: testControl

        // TODO: generate test image and break the sandbox dependency
        source: `${Qt.resolvedUrl(".")}../../sandbox/demoapp/data/logo-test-image.png`
        windowStyle: StatusImageCrop.WindowStyle.Rectangular
        Component.onCompleted: setCropRect(Qt.rect(10, 0, sourceSize.width - 20, sourceSize.height))
    }

    TestCase {
        name: "StatusImageCrop-Functionality"

        //
        // Test guards

        function init() {
            qtOuput.restartCapturing()
        }

        function cleanup() {
        }

        //
        // Tests

        function test_inflateRect_by2() {
            const refRect = Qt.rect(2,2,5,6)
            const infateResult = testControl.inflateRectBy(refRect, 2)
            const inflatedBy2Rect = Qt.rect(-0.5, -1, 10, 12)
            compare(infateResult, inflatedBy2Rect, "Inflating rectangle failed")
            verify(qtOuput.qtOuput().length === 0, `No output expected. Found:\n"${qtOuput.qtOuput()}"\n`)
        }

        function test_inflateRectBy_deflateByHalf() {
            const refRect = Qt.rect(3,4,2,3)
            const inflateResult = testControl.inflateRectBy(refRect, 0.5)
            const defaltedByHalfRect = Qt.rect(3.5, 4.75, 1, 1.5)
            compare(inflateResult, defaltedByHalfRect, "Inflating rectangle failed")
            verify(qtOuput.qtOuput().length === 0, `No output expected. Found:\n"${qtOuput.qtOuput()}"\n`)
        }

        function test_rectCenter() {
            compare(testControl.rectCenter(Qt.rect(2, 3, 2, 4)), Qt.point(3, 5), "Fail to retrieve center");
            compare(testControl.rectCenter(Qt.rect(-1, 3, 1, 3)), Qt.point(-0.5, 4.5), "Fail to retrieve center");
        }

        function test_recenterRect() {
            compare(testControl.recenterRect(Qt.rect(1.5, 2, 3, 4), Qt.point(0, 0)), Qt.rect(-1.5, -2, 3, 4))
            compare(testControl.recenterRect(Qt.rect(0, 0, 1.5, 3), Qt.point(0.75, 1.5)), Qt.rect(0, 0, 1.5, 3))
        }
    }

    MonitorQtOutput {
        id: qtOuput
    }
}
