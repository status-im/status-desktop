import QtQuick 2.15
import QtTest 1.15

import StatusQ.Controls 0.1

import Models 1.0

Item {
    id: root
    width: 600
    height: 400

    Component {
        id: componentUnderTest
        StatusButton {
            anchors.centerIn: parent
        }
    }

    SignalSpy {
        id: signalSpy
        target: controlUnderTest
        signalName: "clicked"
    }

    property StatusButton controlUnderTest: null

    TestCase {
        name: "StatusButton"
        when: windowShown

        function cleanup() {
            if (!!controlUnderTest)
                controlUnderTest.destroy()
            signalSpy.clear()
        }

        function test_defaults() {
            controlUnderTest = createTemporaryObject(componentUnderTest, root, { text: "Hello" })
            verify(!!controlUnderTest)
            verify(controlUnderTest.width > 0)
            verify(controlUnderTest.height > 0)
            verify(controlUnderTest.interactive)
            verify(controlUnderTest.enabled)
            verify(!controlUnderTest.loading)
            verify(!controlUnderTest.loadingWithText)
            verify(!controlUnderTest.isRoundIcon)
        }

        function test_text() {
            const textToTest = "Hello"
            controlUnderTest = createTemporaryObject(componentUnderTest, root, { text: textToTest })
            verify(!!controlUnderTest)

            const buttonText = findChild(controlUnderTest, "buttonText")
            verify(!!buttonText)
            verify(buttonText.visible)
            compare(buttonText.text, textToTest)

            // verify the icon is not visible
            const buttonIcon = findChild(controlUnderTest, "buttonIcon")
            verify(!!buttonIcon)
            compare(buttonIcon.item, null)
        }

        function test_textLeftRight() {
            const textToTest = "Hello"
            controlUnderTest = createTemporaryObject(componentUnderTest, root, { text: textToTest, "icon.name": "gif" })
            verify(!!controlUnderTest)
            compare(controlUnderTest.textPosition, StatusBaseButton.TextPosition.Right)

            const leftTextLoader = findChild(controlUnderTest, "leftTextLoader")
            verify(!!leftTextLoader)
            verify(!leftTextLoader.active)

            const rightTextLoader = findChild(controlUnderTest, "rightTextLoader")
            verify(!!rightTextLoader)
            verify(rightTextLoader.active)

            // set the text to appear on the right, verify the text position
            controlUnderTest.textPosition = StatusBaseButton.TextPosition.Left
            verify(leftTextLoader.active)
            verify(!rightTextLoader.active)
        }

        function test_elideText() {
            const textToTest = "This is a very long text that should be elided"
            controlUnderTest = createTemporaryObject(componentUnderTest, root, { text: textToTest })
            verify(!!controlUnderTest)
            controlUnderTest.width = 100

            // verify the text is visible and truncated (elided)
            const buttonText = findChild(controlUnderTest, "buttonText")
            verify(!!buttonText)
            verify(buttonText.visible)
            verify(buttonText.truncated)
        }

        function test_icon_data() {
            return [
                { tag: "empty", name: "", iconVisible: false },
                { tag: "gif", name: "gif", iconVisible: true },
                { tag: "invalid", name: "bflmpsvz", iconVisible: false },
                { tag: "blob", name: ModelsData.icons.status, iconVisible: true },
                { tag: "fileUrl", name: ModelsData.assets.snt, iconVisible: true },
            ]
        }

        function test_icon(data) {
            controlUnderTest = createTemporaryObject(componentUnderTest, root, { "icon.name": data.name })
            verify(!!controlUnderTest)

            const buttonIcon = findChild(controlUnderTest, "buttonIcon")
            verify(!!buttonIcon)

            if (data.iconVisible)
                verify(buttonIcon.item.visible)

            // verify the button is square with rounded edges
            compare(controlUnderTest.width, controlUnderTest.height)
            verify(controlUnderTest.radius != controlUnderTest.width/2)

            // verify the text is not visible
            const buttonText = findChild(controlUnderTest, "buttonText")
            compare(buttonText, null)
        }

        function test_roundIcon() {
            controlUnderTest = createTemporaryObject(componentUnderTest, root, { "icon.name": "gif", "isRoundIcon": true })
            verify(!!controlUnderTest)

            const buttonIcon = findChild(controlUnderTest, "buttonIcon")
            verify(!!buttonIcon)
            verify(buttonIcon.item.visible)

            // verify that the button is rounded
            compare(controlUnderTest.width, controlUnderTest.height)
            compare(controlUnderTest.radius, controlUnderTest.width/2)
        }

        function test_emoji() {
            controlUnderTest = createTemporaryObject(componentUnderTest, root, { text: "Hello" })
            verify(!!controlUnderTest)

            const buttonEmoji = findChild(controlUnderTest, "buttonEmoji")
            verify(!!buttonEmoji)
            verify(!buttonEmoji.visible)

            // set some emoji, verify it's visible
            controlUnderTest.asset.emoji = "💩"
            verify(buttonEmoji.visible)

            // unset the emoji, verify it's not visible
            controlUnderTest.asset.emoji = ""
            verify(!buttonEmoji.visible)
        }

        function test_textAndIcon_data() {
            return test_icon_data()
        }

        function test_textAndIcon(data) {
            const textToTest = "Hello"
            controlUnderTest = createTemporaryObject(componentUnderTest, root, { text: textToTest, "icon.name": data.name })
            verify(!!controlUnderTest)

            const buttonIcon = findChild(controlUnderTest, "buttonIcon")
            verify(!!buttonIcon)

            if (data.iconVisible)
                verify(buttonIcon.item.visible)

            // verify the button is not square/round
            verify(controlUnderTest.width > controlUnderTest.height)

            // verify the text is visible too
            const buttonText = findChild(controlUnderTest, "buttonText")
            verify(!!buttonText)
            verify(buttonText.visible)
            compare(buttonText.text, textToTest)
        }

        function test_interactiveAndEnabled_data() {
            return [
                { tag: "enabled", enabled: true, interactive: true, spyCount: 1, tooltip: true },
                { tag: "not enabled + interactive", enabled: false, interactive: true, spyCount: 0, tooltip: false },
                { tag: "enabled + not interactive", enabled: true, interactive: false, spyCount: 0, tooltip: true },
                { tag: "not enabled + not interactive", enabled: false, interactive: false, spyCount: 0, tooltip: false },
            ]
        }

        function test_interactiveAndEnabled(data) {
            controlUnderTest = createTemporaryObject(componentUnderTest, root, { text: "Hello", "tooltip.text": "This is a tooltip" })
            verify(!!controlUnderTest)
            controlUnderTest.enabled = data.enabled
            controlUnderTest.interactive = data.interactive

            // verify the tooltip is visible in interactive or enabled when hovered
            const buttonTooltip = findChild(controlUnderTest, "buttonTooltip")
            verify(!!buttonTooltip)
            mouseMove(controlUnderTest, controlUnderTest.width/2, controlUnderTest.height/2)
            waitForItemPolished(buttonTooltip.contentItem)
            tryCompare(buttonTooltip, "opened", data.tooltip)

            // verify the click goes thru (or not) as expected
            mouseClick(controlUnderTest)
            compare(signalSpy.count, data.spyCount)
        }

        function test_loadingIndicators() {
            controlUnderTest =
                    createTemporaryObject(componentUnderTest, root,
                                          { text: "Hello", "icon.name": "gif", "asset.emoji": "💩", "tooltip.text": "This is a tooltip" })
            verify(!!controlUnderTest)

            const buttonIcon = findChild(controlUnderTest, "buttonIcon")
            verify(!!buttonIcon)
            compare(buttonIcon.visible, true)

            const buttonText = findChild(controlUnderTest, "buttonText")
            verify(!!buttonText)
            compare(buttonText.visible, true)

            const buttonEmoji = findChild(controlUnderTest, "buttonEmoji")
            verify(!!buttonEmoji)
            compare(buttonEmoji.visible, true)

            const loadingIndicator = findChild(controlUnderTest, "loadingIndicator")
            verify(!!loadingIndicator)
            compare(loadingIndicator.visible, false)
            compare(controlUnderTest.contentItem.opacity, 1)

            // verify when the overall indicator is running, nothing else is visible
            controlUnderTest.loading = true
            compare(loadingIndicator.visible, true)
            compare(controlUnderTest.contentItem.opacity, 0) // the loading indicator is above the contentItem

            // stop the loadingIndicator, verify icon, emoji and text are visible again
            controlUnderTest.loading = false
            compare(loadingIndicator.visible, false)
            compare(controlUnderTest.contentItem.opacity, 1)
            compare(buttonIcon.visible, true)
            compare(buttonText.visible, true)
            compare(buttonEmoji.visible, true)

            // start the loadingWithText indicator, verify it and text are visible, icon and emoji not
            const loadingWithTextIndicator = findChild(controlUnderTest, "loadingWithTextIndicator")
            verify(!!loadingWithTextIndicator)
            verify(!controlUnderTest.loadingWithText)
            compare(loadingWithTextIndicator.visible, false)

            controlUnderTest.loadingWithText = true
            compare(loadingWithTextIndicator.visible, true)
            compare(buttonIcon.visible, false)
            compare(buttonText.visible, true)
            compare(buttonEmoji.visible, false)
        }
    }
}
