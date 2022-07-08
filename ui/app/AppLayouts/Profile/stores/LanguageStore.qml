import QtQuick 2.13
import utils 1.0

QtObject {
    id: root

    property var languageModule
    property string locale: localAppSettings.locale
    property bool isDDMMYYDateFormat: localAccountSensitiveSettings.isDDMMYYDateFormat
    property bool is24hTimeFormat: localAccountSensitiveSettings.is24hTimeFormat

    // TODO: That definition should be moved to backend.
    property ListModel languageModel: ListModel {
        ListElement {key: "en"; shortName: "English"; name: "English"; category: ""; imageSource: "../../assets/twemoji/svg/1f1ec-1f1e7.svg"; selected: false}
        ListElement {key: "zh"; shortName: "普通话"; name: "Chinese (Mainland China)"; imageSource: "../../assets/twemoji/svg/1f1e8-1f1f3.svg"; category: ""; selected: false}
        ListElement {key: "ko"; shortName: "한국어"; name: "Korean"; category: ""; imageSource: "../../assets/twemoji/svg/1f1f0-1f1f7.svg"; selected: false}
        ListElement {key: "pt_BR"; shortName: "Português"; name: "Portuguese (Brazil)"; category: ""; imageSource: "../../assets/twemoji/svg/1f1e7-1f1f7.svg"; selected: false}
        ListElement {key: "ru"; shortName: "Русский Язык"; name: "Russian"; category: ""; imageSource: "../../assets/twemoji/svg/1f1f7-1f1fa.svg"; selected: false}
        ListElement {key: "ar"; shortName: "اَلْعَرَبِيَّةُ"; name: "Arabic"; category: qsTr("Beta Languages"); imageSource: "../../assets/twemoji/svg/1f1f8-1f1e6.svg"; selected: false}
        ListElement {key: "zh_TW"; shortName: "臺灣華語"; name: "Chinese (Taiwan)"; category: qsTr("Beta Languages"); imageSource: "../../assets/twemoji/svg/1f1f9-1f1fc.svg"; selected: false}
        ListElement {key: "de"; shortName: "Nederlands"; name: "Dutch"; category: qsTr("Beta Languages"); imageSource: "../../assets/twemoji/svg/1f1f3-1f1f1.svg"; selected: false}
        ListElement {key: "fil"; shortName: "Wikang Filipino"; name: "Filipino"; category: qsTr("Beta Languages"); imageSource: "../../assets/twemoji/svg/1f1f5-1f1ed.svg"; selected: false}
        ListElement {key: "fr"; shortName: "Français"; name: "French"; category: qsTr("Beta Languages"); imageSource: "../../assets/twemoji/svg/1f1eb-1f1f7.svg"; selected: false}
        ListElement {key: "id"; shortName: "Bahasa Indonesia"; name: "Indonesian"; category: qsTr("Beta Languages"); imageSource: "../../assets/twemoji/svg/1f1ee-1f1e9.svg"; selected: false}
        ListElement {key: "it"; shortName: "Italiano"; name: "Italian"; category: qsTr("Beta Languages"); imageSource: "../../assets/twemoji/svg/1f1ee-1f1f9.svg"; selected: false}
        ListElement {key: "es"; shortName: "Español"; name: "Spanish"; category: qsTr("Beta Languages"); imageSource: "../../assets/twemoji/svg/1f1ea-1f1f8.svg"; selected: false}
        ListElement {key: "tr"; shortName: "Türkçe"; name: "Turkish"; category: qsTr("Beta Languages"); imageSource: "../../assets/twemoji/svg/1f1f9-1f1f7.svg"; selected: false}
        ListElement {key: "ur"; shortName: "اُردُو"; name: "Urdu"; category: qsTr("Beta Languages"); imageSource: "../../assets/twemoji/svg/1f1f5-1f1f0.svg"; selected: false}
    }

    onLocaleChanged: {
        initializeLanguageModel()
    }

    // TODO: That logic should be moved to backend.
    function initializeLanguageModel() {
        var isSelected = false
        for(var i = 0; i < languageModel.count; i++) {
            if(localAppSettings.locale === root.languageModel.get(i).key) {
                isSelected = true
                root.languageModel.get(i).selected = true
            }
            else {
                root.languageModel.get(i).selected = false
            }
        }

        // Set default:
        if(!isSelected)
            root.languageModel.get(0).selected = true
    }

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
