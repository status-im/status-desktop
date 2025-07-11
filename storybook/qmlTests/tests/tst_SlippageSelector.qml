import QtQuick
import QtTest

import StatusQ.Controls

import shared.controls

Item {
    id: root
    width: 600
    height: 400

    Component {
        id: componentUnderTest
        SlippageSelector {
            anchors.centerIn: parent
        }
    }

    property SlippageSelector controlUnderTest: null

    TestCase {
        name: "SlippageSelector"
        when: windowShown

        function init() {
            controlUnderTest = createTemporaryObject(componentUnderTest, root)
        }

        function test_basicSetup() {
            verify(!!controlUnderTest)
            verify(controlUnderTest.width > 0)
            verify(controlUnderTest.height > 0)
            verify(controlUnderTest.valid)
        }

        function test_selectPresetValues() {
            verify(!!controlUnderTest)
            const buttonsRepeater = findChild(controlUnderTest, "buttonsRepeater")
            verify(!!buttonsRepeater)
            waitForRendering(buttonsRepeater)
            for (let i = 0; i < buttonsRepeater.count; i++) {
                const button = buttonsRepeater.itemAt(i)
                verify(!!button)
                mouseClick(button)
                tryCompare(button, "checked", true)
                tryCompare(button, "type", StatusBaseButton.Type.Primary)
                tryCompare(controlUnderTest, "value", button.value)
                verify(controlUnderTest.valid)
            }
        }

        function test_setAndTypeCustomValue() {
            verify(!!controlUnderTest)
            const customButton = findChild(controlUnderTest, "customButton")
            verify(!!customButton)
            mouseClick(customButton)
            const customInput = findChild(controlUnderTest, "customInput")
            verify(!!customInput)
            tryCompare(customInput, "cursorVisible", true)

            // input "1.42"
            keyClick(Qt.Key_1)
            keyClick(Qt.Key_Period)
            keyClick(Qt.Key_4)
            keyClick(Qt.Key_2)

            tryCompare(controlUnderTest, "value", 1.42)
            verify(controlUnderTest.valid)

            // delete contents (4x)
            keyClick(Qt.Key_Backspace)
            keyClick(Qt.Key_Backspace)
            keyClick(Qt.Key_Backspace)
            keyClick(Qt.Key_Backspace)

            tryCompare(customInput, "text", "")
            tryCompare(customInput, "valid", false)
            tryCompare(controlUnderTest, "valid", false)

            // click again the first button
            const buttonsRepeater = findChild(controlUnderTest, "buttonsRepeater")
            verify(!!buttonsRepeater)
            waitForRendering(buttonsRepeater)
            const firstButton = buttonsRepeater.itemAt(0)
            verify(!!firstButton)
            mouseClick(firstButton)
            tryCompare(controlUnderTest, "value", firstButton.value)
            verify(controlUnderTest.valid)
            tryCompare(customButton, "visible", true)
            tryCompare(customInput, "visible", false)
        }

        function test_setCustomValue_data() {
            return [
                {tag: "valid", value: 1.42, valid: true},
                {tag: "invalid", value: 111.42, valid: false},
            ]
        }

        function test_setCustomValue(data) {
            const theValue = data.value

            verify(!!controlUnderTest)
            verify(controlUnderTest.valid)
            controlUnderTest.value = theValue

            const customInput = findChild(controlUnderTest, "customInput")
            verify(!!customInput)
            tryCompare(customInput, "cursorVisible", true)
            tryCompare(customInput, "value", theValue)
            tryCompare(customInput, "text", customInput.asString)

            verify(controlUnderTest.value, theValue)
            compare(controlUnderTest.valid, data.valid)
        }

        function test_setCustomValueAndReset_data() {
            return [
                {tag: "valid", value: 1.42, valid: true, isDefault: false},
                {tag: "default", value: 0.5, valid: true, isDefault: true},
                {tag: "invalid", value: 111.42, valid: false, isDefault: false},
                {tag: "hundred", value: 100, valid: false, isDefault: false},
            ]
        }

        function test_setCustomValueAndReset(data) {
            verify(!!controlUnderTest)

            let defaultValue = NaN
            let defaultButton = null
            const isDefault = data.isDefault

            // get the default (checked/selected) button and value
            const buttonsRepeater = findChild(controlUnderTest, "buttonsRepeater")
            verify(!!buttonsRepeater)
            for (let i = 0; i < buttonsRepeater.count; i++) {
                const button = buttonsRepeater.itemAt(i)
                if (button && button.checked) {
                    defaultButton = button
                    defaultValue = button.value
                    break
                }
            }

            verify(!!defaultButton)
            verify(defaultValue !== NaN)

            // verify that by default, the custom button is visible, and custom input not
            const customButton = findChild(controlUnderTest, "customButton")
            verify(!!customButton)
            tryCompare(customButton, "visible", true)
            const customInput = findChild(controlUnderTest, "customInput")
            verify(!!customInput)
            tryCompare(customInput, "visible", false)
            tryCompare(controlUnderTest, "valid", true)

            // assign a new (custom) value
            const theValue = data.value
            controlUnderTest.value = theValue
            tryCompare(controlUnderTest, "valid", data.valid)

            // verify the custom input has the new value (and text), and Custom button is not visible
            tryCompare(customInput, "visible", !isDefault)
            tryCompare(customInput, "activeFocus", !isDefault)
            tryCompare(customButton, "visible", isDefault)
            if (!isDefault) {
                tryCompare(customInput, "value", theValue)
                tryCompare(customInput, "text", customInput.asString)
            }

            // call reset()
            controlUnderTest.reset()

            // verify that after reset, the Custom button is back
            tryCompare(customInput, "visible", false)
            tryCompare(customInput, "activeFocus", false)
            tryCompare(customButton, "visible", true)

            // verify that the button with default value is selected again
            tryCompare(defaultButton, "checked", true)
            tryCompare(controlUnderTest, "value", defaultValue)
            tryCompare(controlUnderTest, "valid", true)
        }

        function test_resetDefaults() {
            verify(!!controlUnderTest)
            const initialValue = controlUnderTest.value
            const buttonsRepeater = findChild(controlUnderTest, "buttonsRepeater")
            verify(!!buttonsRepeater)
            waitForRendering(buttonsRepeater)
            const firstButton = buttonsRepeater.itemAt(0)
            waitForRendering(firstButton)
            tryCompare(firstButton, "visible", true)
            mouseClick(firstButton)
            tryCompare(controlUnderTest, "value", firstButton.value)

            controlUnderTest.reset()
            tryCompare(controlUnderTest, "value", initialValue)
            verify(controlUnderTest.valid)

            const customButton = findChild(controlUnderTest, "customButton")
            tryCompare(customButton, "visible", true)

            const customInput = findChild(controlUnderTest, "customInput")
            tryCompare(customInput, "visible", false)
        }
    }
}
