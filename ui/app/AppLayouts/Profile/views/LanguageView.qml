import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13

import utils 1.0
import shared.panels 1.0
import shared.popups 1.0

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Components 0.1

import "../popups"
import "../stores"

Item {
    id: root

    property LanguageStore languageStore
    property int profileContentWidth

    QtObject {
        id: d
        property int margins: 64
        property int zOnTop: 100

        function setViewIdleState() {
            languagePicker.close()
        }
    }

    z: d.zOnTop
    Layout.fillHeight: true
    Layout.fillWidth: true
    clip: true

    onVisibleChanged: { if(!visible) d.setViewIdleState()}

    Component.onCompleted: { root.languageStore.initializeLanguageModel() }

    Column {
        z: d.zOnTop
        width: 560 - (2 * Style.current.padding)
        anchors.margins: d.margins
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        spacing: 45

        StatusBaseText {
            id: title
            text: qsTr("Language & Currency")
            font.weight: Font.Bold
            font.pixelSize: 22
            color: Theme.palette.directColor1
            anchors.bottomMargin: Style.current.padding
        }

        Item {
            id: language
            width: parent.width
            height: 38
            z: d.zOnTop

            StatusBaseText {
                text: qsTr("Language")
                anchors.left: parent.left
                font.pixelSize: 15
                color: Theme.palette.directColor1
            }
            StatusListPicker {
                id: languagePicker

                property string newKey

                Timer {
                    id: pause
                    interval: 100
                    onTriggered: {
                        // changeLocale function operation blocks a little bit the UI so getting around it with a small pause (timer) in order to get the desired visual behavior
                        root.languageStore.changeLocale(languagePicker.newKey)
                    }
                }

                z: d.zOnTop
                width: 104
                height: parent.height
                anchors.right: parent.right
                inputList: root.languageStore.languageModel
                searchText: qsTr("Search Languages")

                onItemPickerChanged: {
                    if(selected && localAppSettings.locale !== key) {
                        // TEMPORARY: It should be removed as it is only used in Linux OS but it must be investigated how to change language in execution time, as well, in Linux (will be addressed in another task)
                        if (Qt.platform.os === Constants.linux) {
                                linuxConfirmationDialog.active = true
                                linuxConfirmationDialog.item.newLocale = key
                                linuxConfirmationDialog.item.open()
                        }
                        else {
                            languagePicker.newKey = key
                            pause.start()
                        }
                    }
                }
            }
        }

        Separator {
            anchors.left: parent.left
            anchors.leftMargin: -Style.current.padding
            anchors.right: parent.right
            anchors.rightMargin: -Style.current.padding
        }
    }

    // TEMPORARY: It should be removed as it is only used in Linux OS but it must be investigated how to change language in execution time, as well, in Linux (will be addressed in another task)
    Loader {
        id: linuxConfirmationDialog
        active: false
        sourceComponent: ConfirmationDialog {
           property string newLocale

           header.title: qsTr("Change language")
           confirmationText: qsTr("Display language has been changed. You must restart the application for changes to take effect.")
           confirmButtonLabel: qsTr("Close the app now")
           onConfirmButtonClicked: {
               root.languageStore.changeLocale(newLocale)
               loader.active = false
               Qt.quit()
           }
       }
    }

    // Outsite area
    MouseArea {
        anchors.fill: parent
        onClicked: { d.setViewIdleState() }
    }
}
