import QtQuick 2.13
import QtQuick.Controls 2.13
import "../../../../imports"
import "../../../../shared"
import "../../../../shared/status"
import "./Data/locales.js" as Locales_JSON

ModalPopup {
    id: popup

    //% "Language"
    title: qsTrId("Language")

    onClosed: {
        destroy()
    }

    Column {
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.rightMargin: Style.current.padding
        anchors.leftMargin: Style.current.padding
        height: 50

        spacing: Style.current.padding

        ButtonGroup {
            id: languageGroup
        }

        Repeater {
            model: Locales_JSON.locales
            height: 50

            StatusRadioButtonRow {
                text: modelData.name
                buttonGroup: languageGroup
                checked: appSettings.locale === modelData.locale
                onRadioCheckedChanged: {
                    if (checked) {
                        profileModel.changeLocale(modelData.locale)
                        appSettings.locale = modelData.locale
                    }
                }
            }
        }
    }
}

