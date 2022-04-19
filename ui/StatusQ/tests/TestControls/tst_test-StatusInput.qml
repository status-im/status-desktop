import QtQuick 2.0
import QtTest 1.0

import StatusQ.Controls 0.1
import StatusQ.Controls.Validators 0.1

import StatusQ.TestHelpers 0.1

Item {
    width: 300
    height: 100

    property int _defaultValidationMode

    Component.onCompleted: {
        _defaultValidationMode = statusInput.validationMode
    }
    StatusInput {
        id: statusInput
        label: "Control under test"
        charLimit: 30
        input.placeholderText: `Must match regex(${validators[0].regularExpression.toString()}) and <= 30 chars`
        focus: true

        validators: [
            StatusRegularExpressionValidator {
                regularExpression: /^[0-9A-Za-z_\$-\s]*$/
            }
        ]
    }

    TestCase {
        id: regexTC

        name: "RegexValidationTest"

        when: windowShown

        //
        // Test guards
        function init() {
            qtOuput.restartCapturing()
            mouseClick(statusInput)
        }

        function cleanup() {
            statusInput.text = ""
            statusInput.validationMode = _defaultValidationMode
        }

        //
        // Tests
        function test_initial_empty_is_valid() {
            verify(statusInput.valid, "Expected valid input")
        }

        function test_regex_validation() {
            TestUtils.pressKeyAndWait(regexTC, statusInput, Qt.Key_1)
            verify(statusInput.valid, "Expected valid input")
            TestUtils.pressKeyAndWait(regexTC, statusInput, Qt.Key_Ampersand)
            verify(!statusInput.valid, "Expected invalid input")
        }

        function test_no_invalid_input() {
            statusInput.validationMode = StatusInput.ValidationMode.IgnoreInvalidInput

            verify(statusInput.valid, "Expected valid input")
            verify(statusInput.text.length === 0, "Expected no input")
            TestUtils.pressKeyAndWait(regexTC, statusInput, Qt.Key_2)
            verify(statusInput.valid, "Expected valid input")
            verify(statusInput.text === "2", "Expect one character")
            TestUtils.pressKeyAndWait(regexTC, statusInput, Qt.Key_Ampersand)
            verify(statusInput.valid, "Expected invalid input")
            verify(statusInput.text === "2", "Expect the same input")
        }

        // Use case expected in case new validation changes are enabled with old unvalid data
        function test_user_can_delete_initial_invalid_input() {
            const appendInvalidChars = "#@!*"

            statusInput.text = "invalid $" + appendInvalidChars
            TestUtils.pressKeyAndWait(regexTC, statusInput, Qt.Key_End)
            verify(!statusInput.valid, "Expected invalid input due to characters not matching")
            // Delete invalid characters to get a valid text
            for(let i = 0; i < appendInvalidChars.length; ++i)
                TestUtils.pressKeyAndWait(regexTC, statusInput, Qt.Key_Backspace)
            verify(statusInput.valid, "Expected valid input")
        }
    }

    TestCase {
        id: qmlWarnTC

        name: "CheckQmlWarnings"

        when: windowShown

        //
        // Test guards

        function initTestCase() {
        }

        function cleanup() {
            statusInput.text = ""
            statusInput.validationMode = _defaultValidationMode
        }

        //
        // Tests

        function test_initial_empty_is_valid() {
            mouseClick(statusInput)
            verify(qtOuput.qtOuput().length === 0, `No output expected. Found:\n"${qtOuput.qtOuput()}"\n`)
        }
    }

    MonitorQtOutput {
        id: qtOuput
    }
}
