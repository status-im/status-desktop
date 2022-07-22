import QtQuick 2.13
import utils 1.0

QtObject {
    id: root

    property var languageModule

    readonly property var languageModel: languageModule ? languageModule.model : null
    readonly property string currentLocale: languageModule ? languageModule.currentLocale : null
    readonly property bool isDDMMYYDateFormat: localAccountSensitiveSettings.isDDMMYYDateFormat
    readonly property bool is24hTimeFormat: localAccountSensitiveSettings.is24hTimeFormat

    function changeLocale(locale) {
        root.languageModule.changeLocale(locale)
    }

    function setIsDDMMYYDateFormat(isDDMMYYDateFormat) {
       root.languageModule.setIsDDMMYYDateFormat(isDDMMYYDateFormat)
    }

    function setIs24hTimeFormat(is24hTimeFormat) {
        root.languageModule.setIs24hTimeFormat(is24hTimeFormat)
    }
}
