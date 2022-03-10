import QtQuick 2.0
import QtTest 1.0

import StatusQ.Controls 0.1
import StatusQ.Controls.Validators 0.1

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
        name: "RegexValidationTest"

        when: windowShown

        //
        // Test guards
        function initTestCase() {
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
            keyClick(Qt.Key_1)
            verify(statusInput.valid, "Expected valid input")
            keyClick(Qt.Key_Ampersand)
            verify(!statusInput.valid, "Expected invalid input")
        }

        function test_no_invalid_input() {
            statusInput.validationMode = StatusInput.ValidationMode.IgnoreInvalidInput

            verify(statusInput.valid, "Expected valid input")
            verify(statusInput.text.length === 0, "Expected no input")
            keyClick(Qt.Key_2)
            verify(statusInput.valid, "Expected valid input")
            verify(statusInput.text === "2", "Expect one character")
            keyClick(Qt.Key_Ampersand)
            verify(statusInput.valid, "Expected invalid input")
            verify(statusInput.text === "2", "Expect the same input")
        }

        // Use case expected in case new validation changes are enabled with old unvalid data
        function test_user_can_delete_initial_invalid_input() {
            const appendInvalidChars = "#@!*"

            statusInput.text = "invalid $" + appendInvalidChars
            keyClick(Qt.Key_End)
            verify(!statusInput.valid, "Expected invalid input due to characters not matching")
            // Delete invalid characters to get a valid text
            for(let i = 0; i < appendInvalidChars.length; ++i)
                keyClick(Qt.Key_Backspace)
            verify(statusInput.valid, "Expected valid input")
        }
    }
}
