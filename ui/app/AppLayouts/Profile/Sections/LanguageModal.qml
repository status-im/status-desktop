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

        ScrollView {
            width: parent.width
            anchors.top: parent.top
            anchors.topMargin: Style.current.padding
            anchors.bottom: parent.bottom
            anchors.bottomMargin: Style.current.bigPadding
            anchors.left: parent.left
            anchors.leftMargin: 16
            anchors.right: parent.right
            anchors.rightMargin: 16
            ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
            ScrollBar.vertical.policy: ScrollBar.AlwaysOn
            clip: true

            ButtonGroup {
                id: languageGroup
            }

            ListView {
                id: languagesListView
                anchors.fill: parent
                anchors.rightMargin: Style.current.padding
                model: Locales_JSON.locales
                spacing: 0

                delegate: Component {
                    StatusRadioButtonRow {
                        height: 64
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
    }
}
