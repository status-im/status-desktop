import QtQuick 2.0
import QtTest 1.0

import StatusQ.Controls 0.1
import StatusQ.Controls.Validators 0.1

import StatusQ.TestHelpers 0.1

Item {
    id: root

    width: 300
    height: 100

    function loadControl(test, sourceComponent) {
        let testItem = test.createTemporaryObject(sourceComponent, root)
        test.verify(test.waitForRendering(testItem))
        test.mouseClick(testItem)
        return testItem
    }

    TestCase {
        id: regexTC

        property StatusInput testControl: null

        name: "RegexValidationTest"

        when: windowShown

        Component {
            id: defaultComponent

            StatusInput {
                label: "Control under test"
                charLimit: 30
                placeholderText: `Must match regex(${validators[0].regularExpression.toString()}) and <= 30 chars`

                anchors.fill: parent
                focus: true

                validators: [
                    StatusRegularExpressionValidator {
                        regularExpression: /^[0-9A-Za-z_\$-\s]*$/
                    }
                ]
            }
        }

        //
        // Test guards

        function init() {
            qtOuput.restartCapturing()
            regexTC.testControl = root.loadControl(regexTC, defaultComponent)
        }

        //
        // Tests
        function test_initial_empty_is_valid() {
            verify(!regexTC.testControl.valid, "Expected valid input")

            verify(qtOuput.qtOuput().length === 0, `No output expected. Found:\n"${qtOuput.qtOuput()}"\n`)
        }

        function test_regex_validation() {
            TestUtils.pressKeyAndWait(regexTC, regexTC.testControl, Qt.Key_1)
            verify(regexTC.testControl.valid, "Expected valid input")
            TestUtils.pressKeyAndWait(regexTC, regexTC.testControl, Qt.Key_Ampersand)
            verify(!regexTC.testControl.valid, "Expected invalid input")

            verify(qtOuput.qtOuput().length === 0, `No output expected. Found:\n"${qtOuput.qtOuput()}"\n`)
        }

        function test_no_invalid_input() {
            skip("Test outdated. Needs to be reviewed and fixed.")

            regexTC.testControl.validationMode = StatusInput.ValidationMode.IgnoreInvalidInput

            verify(regexTC.testControl.valid, "Expected valid input")
            verify(regexTC.testControl.text.length === 0, "Expected no input")
            TestUtils.pressKeyAndWait(regexTC, regexTC.testControl, Qt.Key_2)
            verify(regexTC.testControl.valid, "Expected valid input")
            verify(regexTC.testControl.text === "2", "Expect one character")
            TestUtils.pressKeyAndWait(regexTC, regexTC.testControl, Qt.Key_Ampersand)
            verify(regexTC.testControl.valid, "Expected invalid input")
            verify(regexTC.testControl.text === "2", "Expect the same input")

            verify(qtOuput.qtOuput().length === 0, `No output expected. Found:\n"${qtOuput.qtOuput()}"\n`)
        }

        // Use case expected in case new validation changes are enabled with old invalid data
        function test_user_can_delete_initial_invalid_input() {
            const appendInvalidChars = "#@!*"

            regexTC.testControl.text = "invalid $" + appendInvalidChars
            TestUtils.pressKeyAndWait(regexTC, regexTC.testControl, Qt.Key_End)
            verify(!regexTC.testControl.valid, "Expected invalid input due to characters not matching")
            // Delete invalid characters to get a valid text
            for(let i = 0; i < appendInvalidChars.length; ++i)
                TestUtils.pressKeyAndWait(regexTC, regexTC.testControl, Qt.Key_Backspace)
            verify(regexTC.testControl.valid, "Expected valid input")

            verify(qtOuput.qtOuput().length === 0, `No output expected. Found:\n"${qtOuput.qtOuput()}"\n`)
        }
    }

    TestCase {
        id: bindedTC

        property StatusInput testControl: null

        name: "BindedValuesTest"
        when: windowShown

        property QtObject dataObject: QtObject {
            property string text: "Test text"
            property string emoji: "👍"
            property string color: "#FF0000"
        }

        Component {
            id: bindedTextComponent

            StatusInput {
                charLimit: 10
                input.isIconSelectable: true
                placeholderText: qsTr("Enter an account name...")
                text: bindedTC.dataObject.text
                input.asset.emoji: bindedTC.dataObject.emoji
                input.asset.color: bindedTC.dataObject.color

                anchors.fill: parent
                focus: true

                validators: [
                    StatusMinLengthValidator {
                        errorMessage: qsTr("You need to enter an account name")
                        minLength: 1
                    },
                    StatusRegularExpressionValidator {
                        regularExpression: /^[^<>]+$/
                        errorMessage: qsTr("This is not a valid account name")
                    }
                ]
            }
        }

        //
        // Test guards

        function init() {
            bindedTC.testControl = root.loadControl(regexTC, bindedTextComponent)
        }

        //
        // Tests
        function test_assigning_valid_value_works() {
            qtOuput.restartCapturing()

            verify(!testControl.valid, "Expected input not validated yet")
            testControl.validationMode = StatusInput.ValidationMode.Always
            verify(waitForRendering(testControl))
            verify(testControl.valid, "Expected valid input")
            bindedTC.dataObject.text = "Test<New"
            verify(!testControl.valid, "Expected valid input")

            verify(qtOuput.qtOuput().length === 0, `No output expected. Found:\n"${qtOuput.qtOuput()}"\n`)
        }
    }

    MonitorQtOutput {
        id: qtOuput
    }
}
