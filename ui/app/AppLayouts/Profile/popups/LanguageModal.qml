import QtQuick 2.13
import QtQuick.Controls 2.13

import utils 1.0
import shared.popups 1.0
import shared.controls 1.0
import "../locales.js" as Locales_JSON

// TODO: replace with StatusQ StatusModal
ModalPopup {
    id: root

    //% "Language"
    title: qsTrId("Language")

    property var store

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
                    root.store.changeLocale(newLocale)
                    Qt.quit();
                }
                onCancelButtonClicked: {
                    languageChangeConfirmationDialog.item.close()
                    root.close()
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
                    RadioButtonSelector {
                        height: 64
                        anchors.rightMargin: 0
                        anchors.leftMargin: 0
                        title: modelData.name
                        buttonGroup: languageGroup
                        checked: globalSettings.locale === modelData.locale
                        onCheckedChanged: {
                            if (checked && globalSettings.locale !== modelData.locale) {
                                globalSettings.locale = modelData.locale
                                if (Qt.platform.os === Constants.linux) {
                                    languageChangeConfirmationDialog.item.newLocale = modelData.locale
                                    languageChangeConfirmationDialog.item.open()
                                } else {
                                    root.store.changeLocale(modelData.locale)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
