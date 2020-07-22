import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
import "../../../../imports"
import "../../../../shared"
import "./Data/locales.js" as Locales_JSON

Item {
    id: languageContainer
    Layout.fillHeight: true
    Layout.fillWidth: true

    StyledText {
        id: title
        //% "Language settings"
        text: qsTrId("language-settings")
        anchors.left: parent.left
        anchors.leftMargin: 24
        anchors.top: parent.top
        anchors.topMargin: 24
        font.weight: Font.Bold
        font.pixelSize: 20
    }

    RowLayout {
        property string currentLocale: appSettings.locale
        id: languageSetting
        anchors.top: title.bottom
        anchors.topMargin: 20
        anchors.left: parent.left
        anchors.leftMargin: 24
        StyledText {
            text: qsTr("Language")
        }
        Select {
            selectedText: languageSetting.currentLocale
            anchors.right: undefined
            anchors.left: undefined
            width: 100
            Layout.leftMargin: Style.current.padding
            selectOptions: Locales_JSON.locales.map(locale => {
                return {
                    label: locale,
                    onClicked: function () {
                        profileModel.changeLocale(locale)
                        appSettings.locale = locale
                    }
               }
            })
        }
    }
}
