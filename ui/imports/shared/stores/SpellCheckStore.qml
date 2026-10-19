import QtQuick

QtObject {
    readonly property bool enabled: localAccountSensitiveSettings.spellCheckEnabled
    readonly property bool skipCapitalizedWords: localAccountSensitiveSettings.spellCheckSkipCapitalizedWords
    readonly property string language: localAppSettings.language || "en"

    function setEnabled(value) {
        localAccountSensitiveSettings.spellCheckEnabled = value
    }

    function setSkipCapitalizedWords(value) {
        localAccountSensitiveSettings.spellCheckSkipCapitalizedWords = value
    }
}
