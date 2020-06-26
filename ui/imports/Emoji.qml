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
}