pragma Singleton

import QtQuick 2.13
import "./twemoji/twemoji.js" as Twemoji
import "../shared/status/emojiList.js" as EmojiJSON

QtObject {
    readonly property var size: {
        "big": "72x72",
        "middle": "32x32",
        "small": "20x20"
    }
    property string base: Qt.resolvedUrl("twemoji/")
    function parse(text, renderSize = size.small) {
        const renderSizes = renderSize.split("x");
        if (!renderSize.includes("x") || renderSizes.length !== 2) {
            throw new Error("Invalid value for 'renderSize' parameter: ", renderSize);
        }
        Twemoji.twemoji.base = base
        Twemoji.twemoji.ext = ".png"
        Twemoji.twemoji.size = size.big // source size in filesystem - get 72x72 and downscale for increased pixel density
        return Twemoji.twemoji.parse(text, {
            attributes: function() { return { width: renderSizes[0], height: renderSizes[1] }}
        })
    }
    function fromCodePoint(value) {
        return Twemoji.twemoji.convert.fromCodePoint(value)
    }
    function deparse(value){
        return value.replace(/<img src=\"qrc:\/imports\/twemoji\/.+?" alt=\"(.+?)\" width=\"[0-9]*\" height=\"[0-9]*\" \/>/g, "$1");
    }
    function deparseFromParse(value) {
        return value.replace(/<img class=\"emoji\" draggable=\"false\" alt=\"(.+?)\" src=\"qrc:\/imports\/twemoji\/.+?" width=\"[0-9]*\" height=\"[0-9]*\"\/>/g, "$1");
    }
    function hasEmoji(value) {
        let match = value.match(/<img src=\"qrc:\/imports\/twemoji\/.+?" alt=\"(.+?)\" width=\"[0-9]*\" height=\"[0-9]*\"\ \/>/g)
        return match && match.length > 0
    }
    function getEmojis(value) {
        return value.match(/<img class=\"emoji\" draggable=\"false\" alt=\"(.+?)\" src=\"qrc:\/imports\/twemoji\/.+?" width=\"[0-9]*\" height=\"[0-9]*\"\/>/g, "$1");
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
}
