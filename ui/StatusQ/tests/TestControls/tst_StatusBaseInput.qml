import QtQuick
import QtTest

import StatusQ.Controls
import StatusQ.Controls.Validators

import StatusQ.TestHelpers

Item {
    width: 300
    height: 100

    StatusBaseInput {
        id: statusInput
        text: "Control under test"
        placeholderText: "Placeholder"
        focus: true
    }

    TestCase {
        id: testCase
        name: "StatusBaseInput"

        when: windowShown

        //
        // Test guards

        function init() {
            qtOuput.restartCapturing()
        }

        function cleanup() {
            statusInput.text = ""
        }

        //
        // Tests

        function test_initial_empty_is_valid() {
            mouseClick(statusInput)
            // Do some editing
            TestUtils.pressKeyAndWait(testCase, statusInput, Qt.Key_B)
            TestUtils.pressKeyAndWait(testCase, statusInput, Qt.Key_Left)
            TestUtils.pressKeyAndWait(testCase, statusInput, Qt.Key_A)
            verify(qtOuput.qtOuput().length === 0, `No output expected. Found:\n"${qtOuput.qtOuput()}"\n`)
        }
    }

    MonitorQtOutput {
        id: qtOuput
    }
}
