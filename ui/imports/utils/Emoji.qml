pragma Singleton

import QtQuick 2.13

import shared.status 1.0
import "../assets/twemoji/twemoji.js" as Twemoji

QtObject {
    readonly property var size: {
        "big": "72x72",
        "middle": "32x32",
        "small": "18x18"
    }
    property string base: Qt.resolvedUrl("../assets/twemoji/")
    function parse(text, renderSize = size.small) {
        const renderSizes = renderSize.split("x");
        if (!renderSize.includes("x") || renderSizes.length !== 2) {
            throw new Error("Invalid value for 'renderSize' parameter: ", renderSize);
        }
        
        Twemoji.twemoji.base = base
        Twemoji.twemoji.ext = ".svg"
        Twemoji.twemoji.size = "svg"
        return Twemoji.twemoji.parse(text, {
            attributes: function() { 
              return {
                width: renderSizes[0],
                height: renderSizes[1],
                style: "vertical-align: top"
              }
            }
        })
    }
    function fromCodePoint(value) {
        return Twemoji.twemoji.convert.fromCodePoint(value)
    }
    function deparse(value) {
        return value.replace(/<img src=\"qrc:\/imports\/assets\/twemoji\/.+?" alt=\"(.+?)\" width=\"[0-9]*\" height=\"[0-9]*\" style=\"(.+?)\" ?\/>/g, "$1");
    }
    function deparseFromParse(value) {
        return value.replace(/<img class=\"emoji\" draggable=\"false\" alt=\"(.+?)\" src=\"qrc:\/imports\/assets\/twemoji\/.+?" width=\"[0-9]*\" height=\"[0-9]*\" style=\"(.+?)\" ?\/>/g, "$1");
    }
    function hasEmoji(value) {
        let match = value.match(/<img src=\"qrc:\/imports\/assets\/twemoji\/.+?" alt=\"(.+?)\" width=\"[0-9]*\" height=\"[0-9]*\" style=\"(.+?)\" ?\/>/g)
        return match && match.length > 0
    }
    function nbEmojis(value) {
        let match = value.match(/<img src=\"qrc:\/imports\/assets\/twemoji\/.+?" alt=\"(.+?)\" width=\"[0-9]*\" height=\"[0-9]*\" style=\"(.+?)\" ?\/>/g)
        return match ? match.length : 0
    }
    function getEmojis(value) {
        return value.match(/<img class=\"emoji\" draggable=\"false\" alt=\"(.+?)\" src=\"qrc:\/imports\/assets\/twemoji\/.+?" width=\"[0-9]*\" height=\"[0-9]*\" style=\"(.+?)\" ?\/>/g, "$1");
    }
    function getEmojiUnicode(shortname) {
        var _emoji;
        EmojiJSON.emoji_json.forEach(function(emoji) {
            if (emoji.shortname === shortname)
                _emoji = emoji;
        })

        if (_emoji !== undefined)
            return _emoji.unicode;
        return undefined;
    }

    function getEmojiCodepoint(iconCodePoint) {
        // Split the codepoint to get all the parts and then encode them from hex to utf8
        const splitCodePoint = iconCodePoint.split('-')
        let codePointParts = []
        splitCodePoint.forEach(function (codePoint) {
            codePointParts.push(`0x${codePoint}`)
        })
        return String.fromCodePoint(...codePointParts);
    }

    function getShortcodeFromId(emojiId) {
        switch (emojiId) {
            case 1: return ":heart:"
            case 2: return ":thumbsup:"
            case 3: return ":thumbsdown:"
            case 4: return ":laughing:"
            case 5: return ":cry:"
            case 6: return ":angry:"
            default: return undefined
        }
    }

    function getEmojiFromId(emojiId) {
        let shortcode = Emoji.getShortcodeFromId(emojiId)
        let emojiUnicode = Emoji.getEmojiUnicode(shortcode)
        if (emojiUnicode) {
            return Emoji.fromCodePoint(emojiUnicode)
        }
        return undefined
    }
}
