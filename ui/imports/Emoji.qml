pragma Singleton

import QtQuick 2.13
import "./twemoji/twemoji.js" as Twemoji

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
    function hasEmoji(value) {
        let match = value.match(/<img src=\"qrc:\/imports\/twemoji\/.+?" alt=\"(.+?)\" \/>/g)
        return match && match.length > 0
    }
}
