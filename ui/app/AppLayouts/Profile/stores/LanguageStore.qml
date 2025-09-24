import QtQuick

import StatusQ

QtObject {
    id: root

    readonly property string currentLanguage: localAppSettings.language
    readonly property var availableLanguages: LanguageService.availableLanguages

    function changeLanguage(languageCode, shouldRetranslate = false) {
        const result = LanguageService.setLanguage(languageCode, shouldRetranslate)
        if (result)
            localAppSettings.language = languageCode
        return result
    }
}
