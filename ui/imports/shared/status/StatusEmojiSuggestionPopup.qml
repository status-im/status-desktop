import QtQuick 2.13
import QtQuick.Controls 2.13
import QtGraphicalEffects 1.12
import QtQuick.Dialogs 1.3

import utils 1.0
import shared 1.0

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
        return `../../assets/twemoji/72x72/${modelData.unicode}.png`
    }
    getText: function (modelData) {
        return modelData.shortname
    }
    onClicked: function (index) {
        emojiSuggestions.addEmoji(index)
    }

    function openPopup(emojisParam, shortnameParam) {
        modelList = emojisParam
        shortname = shortnameParam
        emojiSuggestions.open()
    }
}
