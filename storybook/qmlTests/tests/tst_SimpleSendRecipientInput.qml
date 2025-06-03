import QtQuick 2.15
import QtTest 1.15

import StatusQ 0.1
import StatusQ.Core.Utils 0.1 as StatusQUtils

import shared.popups.send.controls 1.0

Item {
    id: root
    width: 600
    height: 400

    Component {
        id: componentUnderTest
        SendRecipientInput {
            anchors.centerIn: parent
            focus: true
        }
    }

    SignalSpy {
        id: signalSpyClearClicked
        target: controlUnderTest
        signalName: "clearClicked"
    }

    SignalSpy {
        id: signalSpyValidateInputRequested
        target: controlUnderTest
        signalName: "validateInputRequested"
    }

    property SendRecipientInput controlUnderTest: null

    TestCase {
        name: "SendRecipientInput"
        when: windowShown

        function init() {
            controlUnderTest = createTemporaryObject(componentUnderTest, root)
            signalSpyClearClicked.clear()
            signalSpyValidateInputRequested.clear()
            ClipboardUtils.clear()
        }

        function test_basicGeometry() {
            verify(!!controlUnderTest)
            verify(controlUnderTest.width > 0)
            verify(controlUnderTest.height > 0)
        }

        function test_textInput() {
            verify(!!controlUnderTest)

            verify(controlUnderTest.input.edit.focus)
            verify(controlUnderTest.interactive)
            compare(controlUnderTest.placeholderText, qsTr("Enter an ENS name or address"))

            keyClick(Qt.Key_0)
            keyClick(Qt.Key_X)
            keyClick(Qt.Key_D)
            keyClick(Qt.Key_E)
            keyClick(Qt.Key_A)
            keyClick(Qt.Key_D)
            keyClick(Qt.Key_B)
            keyClick(Qt.Key_E)
            keyClick(Qt.Key_E)
            keyClick(Qt.Key_F)

            const plainText = StatusQUtils.StringUtils.plainText(controlUnderTest.text)

            // input's text should be what we typed,
            compare(plainText, "0xdeadbeef")
            // ... and for each letter pressed the signal `validateInputRequested` should be emitted
            compare(signalSpyValidateInputRequested.count, plainText.length)
        }

        function test_interactive() {
            verify(!!controlUnderTest)
            verify(controlUnderTest.input.edit.focus)
            verify(controlUnderTest.interactive)

            controlUnderTest.interactive = false

            keyClick(Qt.Key_A)
            keyClick(Qt.Key_B)
            keyClick(Qt.Key_C)

            const plainText = StatusQUtils.StringUtils.plainText(controlUnderTest.text)

            // when non-interactive, any text input should be ignored
            compare(plainText, "")
        }

        function test_pasteButton() {
            verify(!!controlUnderTest)
            const pasteButton = findChild(controlUnderTest, "pasteButton")
            verify(!!pasteButton)
            compare(pasteButton.visible, false)

            // copy sth to clipboard
            controlUnderTest.text = "0xdeadbeef"
            controlUnderTest.input.edit.selectAll()
            controlUnderTest.input.edit.copy()

            // paste button should be visible if input is empty and clipboard is not
            compare(pasteButton.visible, false)
            controlUnderTest.input.edit.clear()
            compare(pasteButton.visible, true)
        }

        function test_pasteUsingButton() {
            verify(!!controlUnderTest)
            const pasteButton = findChild(controlUnderTest, "pasteButton")
            verify(!!pasteButton)
            tryCompare(pasteButton, "visible", false)

            const richTextToTest = "<b>this is bold text</b>"

            // copy rich text to clipboard
            controlUnderTest.text = richTextToTest
            controlUnderTest.input.edit.selectAll()
            controlUnderTest.input.edit.copy()
            controlUnderTest.input.edit.clear()
            compare(controlUnderTest.input.edit.length , 0)

            compare(pasteButton.visible, true)
            mouseClick(pasteButton)
            verify(!controlUnderTest.text.includes("<b>this is bold text</b>"))
        }

        function test_pasteUsingKbdShortcut() {
            verify(!!controlUnderTest)
            const pasteButton = findChild(controlUnderTest, "pasteButton")
            verify(!!pasteButton)
            tryCompare(pasteButton, "visible", false)

            const richTextToTest = "<b>this is bold text</b>"

            // copy rich text to clipboard
            controlUnderTest.text = richTextToTest
            controlUnderTest.input.edit.selectAll()
            controlUnderTest.input.edit.copy()
            controlUnderTest.input.edit.clear()
            compare(controlUnderTest.input.edit.length , 0)

            compare(pasteButton.visible, true)
            keySequence(StandardKey.Paste)
            verify(!controlUnderTest.text.includes("<b>this is bold text</b>"))
        }

        function test_clearButton() {
            verify(!!controlUnderTest)
            verify(controlUnderTest.input.edit.focus)
            verify(controlUnderTest.interactive)

            const clearButton = findChild(controlUnderTest, "clearButton")
            compare(clearButton.visible, false)

            controlUnderTest.text = "0xdeadbeef"

            waitForRendering(controlUnderTest)

            // clear button should be visible with some text
            verify(clearButton.visible)
            mouseClick(clearButton)
            compare(StatusQUtils.StringUtils.plainText(controlUnderTest.text), "")
            compare(signalSpyClearClicked.count, 1)

            // and when interactive
            controlUnderTest.interactive = false
            compare(clearButton.visible, false)
        }

        function test_checkmark() {
            verify(!!controlUnderTest)
            compare(controlUnderTest.checkMarkVisible, false)
            controlUnderTest.checkMarkVisible = true
            const checkmarkIcon = findChild(controlUnderTest, "checkmarkIcon")
            verify(!!checkmarkIcon)
            verify(checkmarkIcon.visible)
        }

        function test_loading() {
            verify(!!controlUnderTest)
            compare(controlUnderTest.loading, false)
            controlUnderTest.loading = true
            controlUnderTest.text = "replicator.eth" // loadingIndicator visible only with some text
            const loadingIndicator = findChild(controlUnderTest, "loadingIndicator")
            verify(!!loadingIndicator)
            verify(loadingIndicator.visible)
        }
    }
}
