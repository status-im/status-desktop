import QtQuick 2.13
import utils 1.0

QtObject {
    id: root

    property var languageModule

    readonly property var languageModel: languageModule ? languageModule.model : null
    readonly property string currentLanguage: languageModule ? languageModule.currentLanguage : null

    function changeLanguage(language) {
        root.languageModule.changeLanguage(language)
    }
}
