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

    Item {
        anchors.fill: parent

        ButtonGroup {
            id: languageGroup
        }

        ScrollView {
            width: parent.width
            anchors.top: parent.top
            anchors.topMargin: Style.current.padding
            anchors.bottom: parent.bottom
            anchors.bottomMargin: Style.current.bigPadding
            ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
            ScrollBar.vertical.policy: ScrollBar.AlwaysOn
            clip: true

            ListView {
                id: languagesListView
                anchors.fill: parent
                anchors.rightMargin: Style.current.padding
                anchors.leftMargin: Style.current.padding
                model: Locales_JSON.locales
                spacing: 0

                delegate: Component {
                    StatusRadioButtonRow {
                        height: 64
                        anchors.rightMargin: 0
                        text: modelData.name
                        buttonGroup: languageGroup
                        checked: appSettings.locale === modelData.locale
                        onRadioCheckedChanged: {
                            if (checked && appSettings.locale !== modelData.locale) {
                                profileModel.changeLocale(modelData.locale)
                                appSettings.locale = modelData.locale
                            }
                        }
                    }
                }
            }
        }
    }
}
