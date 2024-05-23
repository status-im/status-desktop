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
        StatusButtonRow {
            anchors.centerIn: parent
        }
    }

    property StatusButtonRow controlUnderTest: null

    TestCase {
        name: "StatusButtonRow"
        when: windowShown

        function init() {
            controlUnderTest = createTemporaryObject(componentUnderTest, root)
        }

        function test_basicGeometry() {
            verify(!!controlUnderTest)
            verify(controlUnderTest.width > 0)
            verify(controlUnderTest.height > 0)
        }

        function test_defaultValueIsCurrentAndValid() {
            verify(!!controlUnderTest)
            verify(controlUnderTest.currentValue === controlUnderTest.defaultValue)
            verify(controlUnderTest.valid)
        }

        function test_selectPresetValues() {
            verify(!!controlUnderTest)
            const buttonsRepeater = findChild(controlUnderTest, "buttonsRepeater")
            verify(!!buttonsRepeater)
            for (let i = 0; i < buttonsRepeater.count; i++) {
                const button = buttonsRepeater.itemAt(i)
                verify(!!button)
                mouseClick(button)
                tryCompare(button, "checked", true)
                tryCompare(button, "type", StatusBaseButton.Type.Primary)
                tryCompare(controlUnderTest, "currentValue", controlUnderTest.model[i])
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

            tryCompare(controlUnderTest, "currentValue", 1.42)
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
            const firstButton = buttonsRepeater.itemAt(0)
            verify(!!firstButton)
            mouseClick(firstButton)
            tryCompare(controlUnderTest, "currentValue", firstButton.value)
            verify(controlUnderTest.valid)
        }

        function test_setCustomInitialValue() {
            controlUnderTest.destroy()
            controlUnderTest = createTemporaryObject(componentUnderTest, root, {currentValue: 1.42})

            verify(!!controlUnderTest)
            verify(controlUnderTest.valid)
            const customInput = findChild(controlUnderTest, "customInput")
            verify(!!customInput)
            tryCompare(customInput, "cursorVisible", true)
            tryCompare(customInput, "value", 1.42)
        }

        function test_resetDefaults() {
            verify(!!controlUnderTest)
            const buttonsRepeater = findChild(controlUnderTest, "buttonsRepeater")
            verify(!!buttonsRepeater)
            const firstButton = buttonsRepeater.itemAt(0)
            verify(!!firstButton)
            mouseClick(firstButton)
            tryCompare(controlUnderTest, "currentValue", firstButton.value)
            tryCompare(controlUnderTest, "currentValue", controlUnderTest.model[0])

            controlUnderTest.reset()
            tryCompare(controlUnderTest, "currentValue", controlUnderTest.defaultValue)
            verify(controlUnderTest.valid)
        }

        function test_customSymbolValue() {
            const customSymbol = "+++"
            verify(!!controlUnderTest)
            controlUnderTest.symbolValue = customSymbol

            const buttonsRepeater = findChild(controlUnderTest, "buttonsRepeater")
            verify(!!buttonsRepeater)
            for (let i = 0; i < buttonsRepeater.count; i++) {
                const button = buttonsRepeater.itemAt(i)
                verify(!!button)
                verify(button.text.endsWith(customSymbol))
            }

            const customButton = findChild(controlUnderTest, "customButton")
            verify(!!customButton)
            mouseClick(customButton)
            const customInput = findChild(controlUnderTest, "customInput")
            verify(!!customInput)
            verify(customInput.currencySymbol === customSymbol)
        }

        function test_customModel() {
            controlUnderTest.destroy()
            controlUnderTest = createTemporaryObject(componentUnderTest, root,
                                                     {model: [.1, .2, .3, .4, .5]})

            verify(!!controlUnderTest)
            verify(controlUnderTest.currentValue === controlUnderTest.defaultValue)
            verify(controlUnderTest.valid)

            const buttonsRepeater = findChild(controlUnderTest, "buttonsRepeater")
            verify(!!buttonsRepeater)
            verify(buttonsRepeater.count === controlUnderTest.model.length)
            const firstButton = buttonsRepeater.itemAt(0)
            verify(!!firstButton)
            mouseClick(firstButton)
            tryCompare(firstButton, "checked", true)
            tryCompare(controlUnderTest, "currentValue", firstButton.value)
            tryCompare(controlUnderTest, "currentValue", controlUnderTest.model[0])
            verify(controlUnderTest.valid)
        }
    }
}
