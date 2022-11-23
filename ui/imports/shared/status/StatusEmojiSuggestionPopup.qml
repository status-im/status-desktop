import QtQuick 2.14

import shared 1.0

import StatusQ.Core.Utils 0.1

StatusInputListPopup {
    id: emojiSuggestions

    property string shortname
    property string unicode: {
        if(listView.currentIndex < 0 || listView.currentIndex >= emojiSuggestions.modelList.count)
            return ""

        return emojiSuggestions.modelList[listView.currentIndex].unicode_alternates ||
                emojiSuggestions.modelList[listView.currentIndex].unicode
    }

    getImageSource: function (modelData) {
        return Emoji.svgImage(modelData.unicode)
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
        emojiSuggestions.open()
    }
}
