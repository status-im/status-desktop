import QtQuick 2.15
import QtTest 1.0

import StatusQ.Core.Utils 0.1

TestCase {
    id: testCase
    name: "TestEmoji"

    // Test if the knowledge of the first and last index of the flags is still valid or need to be updated
    function test_flags_indexes_are_valid() {
        let emojis = Emoji.emojiJSON.emoji_json
        let firstIndex = emojis.findIndex(function(emoji) {
            return (emoji.category === "flags")
        })
        compare(Emoji.firstFlagIndex, firstIndex, "First flag index is still valid")

        let lastIndex = -1;
        for (let i = emojis.length - 1; i >= 0; i--) {
            if (emojis[i].category === "flags") {
                lastIndex = i;
                break; // Exit the loop once the last flag is found
            }
        }
        compare(Emoji.lastFlagIndex, lastIndex, "Last flag index is still valid")
    }
}

