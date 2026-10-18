pragma Singleton

import QtQuick

import StatusQ

QtObject {
    readonly property var size: {
        "veryBig": "86x86",
        "big": "72x72",
        "middle": "32x32",
        "small": "18x18",
        "verySmall": "16x16"
    }
    readonly property alias emojiJSON: emojiModel.emojiJson

    readonly property StatusEmojiModel emojiModel: StatusEmojiModel { id: emojiModel }

    function getEmojiCodepoint(iconCodePoint) {
        // Split the codepoint to get all the parts and then encode them from hex to utf8
        const splitCodePoint = iconCodePoint.split('-')
        let codePointParts = []
        splitCodePoint.forEach(function (codePoint) {
            codePointParts.push(`0x${codePoint}`)
        })
        return String.fromCodePoint(...codePointParts);
    }

    // Used to exclude flags emojis from the random emoji picker
    // Based on the knowledge that flags emojis are contiguous in the emoji list
    readonly property int firstFlagIndex: 3504
    readonly property int lastFlagIndex: 3772
    readonly property int flagsCount: lastFlagIndex - firstFlagIndex + 1

    // Returns a random emoji (the character as the catalogue stores it), excluding flags
    // WARNING: use status-go RandomWalletEmoji instead.
    // More details here: https://github.com/status-im/status-go/issues/5663
    function getRandomEmoji() {
        const emojisLength = emojiJSON.length
        if (emojisLength <= 0)
            return ""

        let whitelistedIndex = Math.floor(Math.random() * (emojisLength - flagsCount))
        // Compensating for the missing flags emojis index
        if (whitelistedIndex >= firstFlagIndex) {
            whitelistedIndex += flagsCount
        }
        // The character, not a rebuild from `unicode`: that follows Twemoji's filename
        // convention and drops U+FE0F, which emoji presentation depends on.
        return emojiJSON[whitelistedIndex].emoji
    }

    function getSuggestions(input: string) : var {
        return emojiModel.getSuggestions(input)
    }

    // Length of the longest ASCII emoticon, to bound the look-back when matching one.
    function maxAsciiEmojiLength(): int {
        return emojiModel.maxAsciiEmojiAliasLength()
    }

    // Returns the emoji character for an ASCII emoticon, or "" when it isn't one.
    function getAsciiEmoji(text: string): string {
        return emojiModel.getEmojiFromAsciiAlias(text)
    }
}
