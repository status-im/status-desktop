import QtQuick

import shared.status

import StatusQ.Core.Utils

StatusInputListPopup {
    id: emojiSuggestions

    property string shortname
    property string unicode: {
        if(listView.currentIndex < 0 || listView.currentIndex >= emojiSuggestions.modelList.count)
            return ""

        return emojiSuggestions.modelList[listView.currentIndex].unicode
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
