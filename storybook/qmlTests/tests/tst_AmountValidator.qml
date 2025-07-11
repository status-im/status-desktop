import QtQuick
import QtQuick.Controls

import QtTest

import StatusQ.Validators

Item {
    id: root

    Component {
        id: componentUnderTest

        TextField {
            validator: AmountValidator {
                id: validator

                decimalPoint: "."
            }
        }
    }

    property TextField textField

    TestCase {
        name: "AmountValidator"
        when: windowShown

        function type(key, times = 1) {
            for (let i = 0; i < times; i++) {
                keyPress(key)
                keyRelease(key)
            }
        }

        function init() {
            textField = createTemporaryObject(componentUnderTest, root)
        }

        function test_empty() {
            compare(textField.acceptableInput, false)
        }

        function test_decimalPointOnly() {
            textField.forceActiveFocus()
            type(Qt.Key_Period)

            compare(textField.acceptableInput, false)
            compare(textField.text, ".")

            type(Qt.Key_Period)

            compare(textField.acceptableInput, false)
            compare(textField.text, ".")

            textField.text = ""

            type(Qt.Key_Comma)

            compare(textField.acceptableInput, false)
            compare(textField.text, ".")

            type(Qt.Key_Comma)
            type(Qt.Key_Period)

            compare(textField.acceptableInput, false)
            compare(textField.text, ".")

            textField.text = ""
            textField.validator.decimalPoint = ","

            type(Qt.Key_Period)

            compare(textField.acceptableInput, false)
            compare(textField.text, ",")

            type(Qt.Key_Comma)
            type(Qt.Key_Period)

            compare(textField.acceptableInput, false)
            compare(textField.text, ",")
        }

        function test_decimalPointWithDigits() {
            textField.forceActiveFocus()
            type(Qt.Key_1)
            type(Qt.Key_Period)

            compare(textField.acceptableInput, true)
            compare(textField.text, "1.")

            type(Qt.Key_1)
            type(Qt.Key_Period)

            compare(textField.acceptableInput, true)
            compare(textField.text, "1.1")

            textField.text = ""
            type(Qt.Key_Period)
            type(Qt.Key_1)

            compare(textField.acceptableInput, true)
            compare(textField.text, ".1")
        }

        function test_maxIntegralDigits() {
            textField.forceActiveFocus()
            textField.validator.maxIntegralDigits = 2

            type(Qt.Key_1)
            type(Qt.Key_1)

            compare(textField.acceptableInput, true)
            compare(textField.text, "11")

            type(Qt.Key_2)
            type(Qt.Key_2)

            compare(textField.acceptableInput, true)
            compare(textField.text, "11")

            type(Qt.Key_Period)
            type(Qt.Key_3)
            type(Qt.Key_3)

            compare(textField.acceptableInput, true)
            compare(textField.text, "11.33")
        }

        function test_maxDecimalDigits() {
            textField.forceActiveFocus()
            textField.validator.maxDecimalDigits = 2

            type(Qt.Key_Period)
            type(Qt.Key_1)
            type(Qt.Key_1)

            compare(textField.acceptableInput, true)
            compare(textField.text, ".11")

            type(Qt.Key_2)
            type(Qt.Key_2)

            compare(textField.acceptableInput, true)
            compare(textField.text, ".11")

            textField.cursorPosition = 0

            type(Qt.Key_2)
            type(Qt.Key_2)

            compare(textField.acceptableInput, true)
            compare(textField.text, "22.11")
        }

        function test_trimmingDecimalDigits() {
            textField.text = ".11"
            textField.forceActiveFocus()
            textField.validator.maxDecimalDigits = 2
            textField.cursorPosition = 1

            type(Qt.Key_2)
            type(Qt.Key_2)

            compare(textField.acceptableInput, true)
            compare(textField.text, ".22")

            type(Qt.Key_3)
            type(Qt.Key_3)

            compare(textField.acceptableInput, true)
            compare(textField.text, ".22")
        }

        function test_maxTotalDigits() {
            textField.text = "1234567891."
            textField.forceActiveFocus()
            textField.validator.maxDecimalDigits = 18
            textField.validator.maxDigits = 15
            textField.cursorPosition = 11

            type(Qt.Key_1)
            type(Qt.Key_2)
            type(Qt.Key_3)
            type(Qt.Key_4)
            type(Qt.Key_5)

            compare(textField.acceptableInput, true)
            compare(textField.text, "1234567891.12345")

            type(Qt.Key_6)

            compare(textField.acceptableInput, true)
            compare(textField.text, "1234567891.12345")
        }
    }
}
