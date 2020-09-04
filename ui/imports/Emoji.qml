pragma Singleton

import QtQuick 2.13
import "./twemoji/twemoji.js" as Twemoji
import "../app/AppLayouts/Chat/components/emojiList.js" as EmojiJSON

QtObject {
    property string base: Qt.resolvedUrl("twemoji/")
    function parse(text, size) {
        Twemoji.twemoji.base = base
        Twemoji.twemoji.ext = ".png"
        Twemoji.twemoji.size = size
        return Twemoji.twemoji.parse(text)
    }
    function fromCodePoint(value) {
        return Twemoji.twemoji.convert.fromCodePoint(value)
    }
    function deparse(value){
        return value.replace(/<img src=\"qrc:\/imports\/twemoji\/.+?" alt=\"(.+?)\" \/>/g, "$1");
    }
    function deparseFromParse(value) {
        return value.replace(/<img class=\"emoji\" draggable=\"false\" alt=\"(.+?)\" src=\"qrc:\/imports\/twemoji\/.+?"\/>/g, "$1");
    }
    function hasEmoji(value) {
        let match = value.match(/<img src=\"qrc:\/imports\/twemoji\/.+?" alt=\"(.+?)\" \/>/g)
        return match && match.length > 0
    }
    function getEmojis(value) {
        return value.match(/<img class=\"emoji\" draggable=\"false\" alt=\"(.+?)\" src=\"qrc:\/imports\/twemoji\/.+?"\/>/g, "$1");
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
}
