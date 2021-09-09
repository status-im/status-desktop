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

        Loader {
            id: languageChangeConfirmationDialog
            active: Qt.platform.os === Constants.linux
            sourceComponent: ConfirmationDialog {
                property string newLocale
                header.title: qsTr("Change language")
                confirmationText: qsTr("Display language has been changed. You must restart the application for changes to take effect.")
                showCancelButton: true
                confirmButtonLabel: qsTr("Close the app now")
                cancelButtonLabel: qsTr("I'll do that later")
                onConfirmButtonClicked: {
                    profileModel.changeLocale(newLocale)
                    Qt.quit();
                }
                onCancelButtonClicked: {
                    languageChangeConfirmationDialog.item.close()
                    popup.close()
                }
            }

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
                        checked: globalSettings.locale === modelData.locale
                        onRadioCheckedChanged: {
                            if (checked && globalSettings.locale !== modelData.locale) {
                                globalSettings.locale = modelData.locale
                                if (Qt.platform.os === Constants.linux) {
                                    languageChangeConfirmationDialog.item.newLocale = modelData.locale
                                    languageChangeConfirmationDialog.item.open()
                                } else {
                                    profileModel.changeLocale(modelData.locale)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
