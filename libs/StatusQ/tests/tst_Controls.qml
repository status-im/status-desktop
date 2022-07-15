import QtQuick
import QtQml
import QtTest

import Status.Controls.Navigation

import Status.TestHelpers

/// \todo use mocked values
Item {
    id: root
    width: 400
    height: 300

    Component {
        id: macTrafficLightsComponent

        Item {
            MacTrafficLights {
                anchors.left: parent.left
                anchors.margins: 13
                anchors.top: parent.top
                z: parent.z + 1
            }
        }
    }

    Loader {
        id: testLoader

        anchors.fill: parent
        active: false
    }

    TestCase {
        id: qmlWarningsTest

        name: "TestQmlWarnings"

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

        /// \todo check if data driven testing is possible for checking all the controls with its defaults
        function test_macTrafficLightsInitialization() {
            testLoader.sourceComponent = macTrafficLightsComponent
            testLoader.active = true
            verify(waitForRendering(testLoader.item))
            testLoader.active = false
            verify(qtOuput.qtOuput().length === 0, `No output expected. Found:\n"${qtOuput.qtOuput()}"\n`)
        }
    }

    MonitorQtOutput {
        id: qtOuput
    }
}
