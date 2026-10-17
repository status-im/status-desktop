import QtQuick
import QtTest

import StatusQ.Core.Utils as SQUtils

import shared.status

/*
 The picker hands out two things per emoji: the character to insert into the text,
 and the hexcode the backend and the recents list are keyed by. They are not
 interchangeable - the hexcode follows Twemoji's filename convention, which drops
 U+FE0F - so the character has to come from the catalogue, not be rebuilt from the
 hexcode.
*/
Item {
    id: root

    width: 600
    height: 600

    StatusEmojiPopup {
        id: picker

        directParent: root
        relativeX: 0
        relativeY: 0
        width: 370
        height: 440
        userUID: "tst_StatusEmojiPopup"
        emojiModel: SQUtils.Emoji.emojiModel
    }

    StatusEmojiSuggestionPopup {
        id: suggestions
        width: 300
    }

    SignalSpy {
        id: spy
        target: picker
        signalName: "emojiSelected"
    }

    TestCase {
        name: "StatusEmojiPopup"
        when: windowShown

        function init() {
            spy.clear()
        }

        // ❤ is stored as "2764", but its character is the fully-qualified "❤️". Without
        // the variation selector the base character defaults to text presentation and
        // renders from a text font instead of the emoji one.
        function test_emojiSelected_carriesTheFullyQualifiedCharacter() {
            picker.addEmoji("2764", "❤️")

            compare(spy.count, 1)
            const emitted = spy.signalArguments[0][0]
            verify(emitted.includes("️"),
                   `payload must keep U+FE0F, got ${JSON.stringify(emitted)}`)
            compare(emitted, "❤️ ") // trailing space keeps adjacent emoji apart
        }

        // The hexcode is a stored identifier: recents are persisted under it and
        // reactions are sent with it, so it must pass through untouched.
        function test_emojiSelected_passesTheHexcodeThrough() {
            picker.addEmoji("2764", "❤️")

            compare(spy.count, 1)
            compare(spy.signalArguments[0][2], "2764")
        }

        // Guards the reason the character is taken from the catalogue.
        function test_rebuildingFromHexcodeWouldDropTheVariationSelector() {
            const rebuilt = SQUtils.Emoji.getEmojiCodepoint("2764")
            compare(rebuilt, "❤")
            verify(!rebuilt.includes("️"))
        }

        // The ":shortname" suggestion list carries the same two values and has the same
        // requirement: `emoji` is what gets typed, `unicode` only identifies the entry.
        function test_suggestions_exposeTheFullyQualifiedCharacter() {
            const entries = SQUtils.Emoji.getSuggestions("heart")
            verify(entries.length > 0, "expected suggestions for ':heart'")

            suggestions.openPopup(entries, "heart")
            suggestions.listView.currentIndex = 0

            compare(suggestions.emoji, entries[0].emoji)
            compare(suggestions.unicode, entries[0].unicode)
            suggestions.close()
        }

        // At least one of them must actually need the selector, or the check above
        // would pass even if the character were rebuilt from the hexcode.
        function test_suggestions_includeAnEmojiThatNeedsTheSelector() {
            const entries = SQUtils.Emoji.getSuggestions("heart")
            const qualified = entries.filter(e => e.emoji.includes("️"))
            verify(qualified.length > 0,
                   "expected a ':heart' suggestion whose character carries U+FE0F")
            verify(!qualified[0].unicode.includes("fe0f"),
                   "...and whose hexcode does not, which is the trap")
        }
    }
}
