import QtQuick

import shared.status

import StatusQ.Core.Utils

StatusInputListPopup {
    id: root

    property string shortname
    property string unicode: {
        if(listView.currentIndex < 0 || listView.currentIndex >= root.modelList.length)
            return ""

        return root.modelList[listView.currentIndex].unicode
    }
    // The character to insert. It has to come from the catalogue rather than be
    // rebuilt from `unicode`, which follows Twemoji's filename convention and drops
    // U+FE0F - and without that the emoji renders in a text font.
    property string emoji: {
        if(listView.currentIndex < 0 || listView.currentIndex >= root.modelList.length)
            return ""

        return root.modelList[listView.currentIndex].emoji
    }

    getEmoji: function (modelData) {
        return modelData.emoji
    }
    getText: function (modelData) {
        return modelData.shortname
    }
    getId: function (modelData) {
        return modelData.unicode
    }

    function openPopup(emojisParam, shortnameParam) {
        modelList = emojisParam
        shortname = shortnameParam
        root.open()
    }
}
