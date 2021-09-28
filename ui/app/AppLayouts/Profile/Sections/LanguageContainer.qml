import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13

import utils 1.0
import "../../../../shared"
import "../../../../shared/status"
import "./Data/locales.js" as Locales_JSON

Item {
    id: languageContainer
    Layout.fillHeight: true
    Layout.fillWidth: true
    clip: true

    property Component languagePopup: LanguageModal {}

    Item {
        anchors.top: parent.top
        anchors.topMargin: topMargin
        anchors.bottom: parent.bottom
        width: profileContainer.profileContentWidth

        anchors.horizontalCenter: parent.horizontalCenter

        Column {
            id: generalColumn
            width: parent.width

            StatusSettingsLineButton {
                //% "Language"
                text: qsTrId("language")
                //% "Default"
                currentValue: globalSettings.locale === "" ? qsTrId("default") : globalSettings.locale
                onClicked: languagePopup.createObject(languageContainer).open()
            }
        }
    }
}
