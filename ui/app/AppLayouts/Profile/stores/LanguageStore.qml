import QtQuick 2.13
import utils 1.0

QtObject {
    id: root

    property var languageModule

    readonly property var languageModel: languageModule ? languageModule.model : null
    readonly property string currentLanguage: languageModule ? languageModule.currentLanguage : null
    readonly property bool isDDMMYYDateFormat: localAccountSensitiveSettings.isDDMMYYDateFormat
    readonly property bool is24hTimeFormat: localAccountSensitiveSettings.is24hTimeFormat

    function changeLanguage(locale) {
        root.languageModule.changeLanguage(locale)
    }

    function setIsDDMMYYDateFormat(isDDMMYYDateFormat) {
       root.languageModule.setIsDDMMYYDateFormat(isDDMMYYDateFormat)
    }

    function setIs24hTimeFormat(is24hTimeFormat) {
        root.languageModule.setIs24hTimeFormat(is24hTimeFormat)
    }
}

