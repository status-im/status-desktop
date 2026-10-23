import QtQuick
import QtTest

import shared.controls.chat

Item {
    id: root

    width: 200
    height: 200

    Component {
        id: reactionComponent

        EmojiReaction {}
    }

    TestCase {
        name: "EmojiReaction"
        when: windowShown

        // The one-time font alias scan warns from whichever test first lays out text.
        function initTestCase() {
            createTemporaryQmlObject('import QtQuick; Text { font.family: "Sans Serif"; text: "x" }', root)
            wait(100)
        }

        function renderedEmoji(reaction) {
            for (const child of reaction.children)
                if (child.emoji !== undefined)
                    return child.emoji
            return null
        }

        // Reaction ids follow Twemoji's filename spelling, which drops U+FE0F. The
        // character must be the catalogue's fully-qualified one, or these render in a
        // text font instead of as emoji.
        function test_idWithoutTheSelectorRendersTheQualifiedCharacter_data() {
            return [
                { tag: "heart", emojiId: "2764", expected: "❤️" },
                { tag: "smiling face", emojiId: "263a", expected: "☺️" },
                { tag: "hand", emojiId: "1f590", expected: "\u{1F590}️" },
                { tag: "no selector needed", emojiId: "1f602", expected: "\u{1F602}" },
            ]
        }

        function test_idWithoutTheSelectorRendersTheQualifiedCharacter(data) {
            const reaction = createTemporaryObject(reactionComponent, root,
                                                   { emojiId: data.emojiId })
            compare(renderedEmoji(reaction), data.expected)
        }

        // An id the catalogue does not know still renders, rebuilt from its code points.
        function test_unknownIdFallsBackToTheCodePoints() {
            const reaction = createTemporaryObject(reactionComponent, root,
                                                   { emojiId: "1f9ff-1f9ff" })
            compare(renderedEmoji(reaction), "\u{1F9FF}\u{1F9FF}")
        }
    }
}
