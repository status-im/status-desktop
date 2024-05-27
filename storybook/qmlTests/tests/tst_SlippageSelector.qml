import QtQuick 2.15
import QtTest 1.15

import StatusQ.Controls 0.1

import shared.controls 1.0

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
        }

        function test_setCustomValue() {
            const theValue = 1.42

            verify(!!controlUnderTest)
            verify(controlUnderTest.valid)
            controlUnderTest.value = theValue

            const customInput = findChild(controlUnderTest, "customInput")
            verify(!!customInput)
            tryCompare(customInput, "cursorVisible", true)
            tryCompare(customInput, "value", theValue)

            verify(controlUnderTest.value, theValue)
            verify(controlUnderTest.valid)
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
