import QtQuick

QtObject {
    id: root

    property var languageModule

    readonly property var languageModel: languageModule ? languageModule.model : null
    readonly property string currentLanguage: languageModule ? languageModule.currentLanguage : null

    function changeLanguage(language) {
        root.languageModule.changeLanguage(language)
    }
}
