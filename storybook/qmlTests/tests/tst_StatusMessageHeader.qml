import QtQuick
import QtTest

import StatusQ.Components

/*
 Perf guard: the sender display name is rendered ~17 times per chat switch.
 A TextEdit (selection machinery, cursor, input handling) is much heavier to
 create than a plain Text and the name is not an input field — name
 selection is not part of the message-selection flow.
*/
Item {
    id: root

    width: 500
    height: 200

    Component {
        id: headerComp

        StatusMessageHeader {
            width: parent.width
            sender: StatusMessageSenderDetails {
                displayName: "Alice"
            }
            timestamp: Date.now()
        }
    }

    SignalSpy {
        id: clickSpy
        signalName: "clicked"
    }

    TestCase {
        name: "StatusMessageHeader"
        when: windowShown

        function init() {
            clickSpy.target = null
            clickSpy.clear()
        }

        function displayName(header) {
            const label = findChild(header, "StatusMessageHeader_DisplayName")
            verify(!!label)
            return label
        }

        function test_displayNameRenders() {
            const header = createTemporaryObject(headerComp, root)
            verify(!!header)
            waitForRendering(header)

            compare(displayName(header).text, "Alice")
        }

        function test_displayNameShowsYouForOwnMessages() {
            const header = createTemporaryObject(headerComp, root,
                                                 {amISender: true})
            verify(!!header)
            waitForRendering(header)

            compare(displayName(header).text, qsTr("You"))
        }

        function test_displayNameClickEmitsSignal() {
            const header = createTemporaryObject(headerComp, root)
            verify(!!header)
            waitForRendering(header)

            clickSpy.target = header
            const label = displayName(header)
            mouseClick(label, label.width / 2, label.height / 2)

            tryCompare(clickSpy, "count", 1)
        }

        // The name is rendered from the emoji font now, not rewritten into Twemoji
        // <img> markup, so the raw string reaches the label unchanged.
        function test_displayNameKeepsEmojiAsText() {
            const header = createTemporaryObject(headerComp, root)
            verify(!!header)
            header.sender.displayName = "Alice \u{1F600}"
            waitForRendering(header)

            compare(displayName(header).text, "Alice \u{1F600}")
        }

        // A display name comes from another user, so markup in it must be shown
        // literally. AutoText would hand it to the rich text engine instead - which
        // also fetches <img> sources.
        function test_displayNameWithMarkupIsRenderedLiterally() {
            const header = createTemporaryObject(headerComp, root)
            verify(!!header)
            header.sender.displayName = "<b>bob</b>"
            waitForRendering(header)

            const label = displayName(header)
            compare(label.textFormat, Text.PlainText)
            compare(label.text, "<b>bob</b>")
        }

        function test_displayNameIsNotATextEdit() {
            const header = createTemporaryObject(headerComp, root)
            verify(!!header)
            waitForRendering(header)

            verify(!(displayName(header) instanceof TextEdit),
                   "display name must be a plain Text, not an input item")
        }
    }
}
