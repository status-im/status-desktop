import QtQuick 2.13
import QtQuick.Controls 2.13
import QtGraphicalEffects 1.12
import QtQuick.Dialogs 1.3
import "../../imports"
import "../../shared"

StatusInputListPopup {
    property string shortname

    id: emojiSuggestions
    getImageSource: function (modelData) {
        return `../../imports/twemoji/72x72/${modelData.unicode}.png`
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

    function addEmoji(index) {
        if (index === undefined) {
            index = listView.currentIndex
        }

        const message = extrapolateCursorPosition();
        const unicode = emojiSuggestions.modelList[index].unicode_alternates || emojiSuggestions.modelList[index].unicode
        replaceWithEmoji(message, emojiSuggestions.shortname, unicode)
    }
}
