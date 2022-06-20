import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13

import utils 1.0
import shared.panels 1.0
import shared.popups 1.0

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Components 0.1
import StatusQ.Controls 0.1

import "../popups"
import "../stores"

SettingsContentBase {
    id: root

    property LanguageStore languageStore
    property var currencyStore

    onVisibleChanged: { if(!visible) root.setViewIdleState()}
    onBaseAreaClicked: { root.setViewIdleState() }

    Component.onCompleted: {
        root.currencyStore.updateCurrenciesModel()
        root.languageStore.initializeLanguageModel()
    }

    function setViewIdleState() {
        currencyPicker.close()
        languagePicker.close()
    }

    ColumnLayout {
        spacing: Constants.settingsSection.itemSpacing
        width: root.contentWidth

        Item {
            id: currency
            Layout.fillWidth: true
            Layout.leftMargin: Style.current.padding
            Layout.rightMargin: Style.current.padding
            height: Style.dp(38)
            z: root.z + 2

            StatusBaseText {
                text: qsTr("Set Display Currency")
                anchors.left: parent.left
                font.pixelSize: Style.current.primaryTextFontSize
                color: Theme.palette.directColor1
            }
            StatusListPicker {
                id: currencyPicker

                property string newKey

                Timer {
                    id: currencyPause
                    interval: 100
                    onTriggered: {
                        // updateCurrency function operation blocks a little bit the UI so getting around it with a small pause (timer) in order to get the desired visual behavior
                        root.currencyStore.updateCurrency(currencyPicker.newKey)
                    }
                }

                z: root.z + 2
                width: Style.dp(104)
                height: parent.height
                anchors.right: parent.right
                inputList: root.currencyStore.currenciesModel
                printSymbol: true
                placeholderSearchText: qsTr("Search Currencies")
                maxPickerHeight: Style.dp(350)

                onItemPickerChanged: {
                    if(selected) {
                        currencyPicker.newKey = key
                        currencyPause.start()
                    }
                }
            }
        }

        Item {
            id: language
            Layout.fillWidth: true
            Layout.leftMargin: Style.current.padding
            Layout.rightMargin: Style.current.padding
            height: Style.dp(38)
            z: root.z + 1

            StatusBaseText {
                text: qsTr("Language")
                anchors.left: parent.left
                font.pixelSize: Style.current.primaryTextFontSize
                color: Theme.palette.directColor1
            }
            StatusListPicker {
                id: languagePicker

                property string newKey

                Timer {
                    id: languagePause
                    interval: 100
                    onTriggered: {
                        // changeLocale function operation blocks a little bit the UI so getting around it with a small pause (timer) in order to get the desired visual behavior
                        root.languageStore.changeLocale(languagePicker.newKey)
                    }
                }

                z: root.z + 1
                width: Style.dp(104)
                height: parent.height
                anchors.right: parent.right
                inputList: root.languageStore.languageModel
                placeholderSearchText: qsTr("Search Languages")
                maxPickerHeight: Style.dp(350)

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
                            languagePause.start()
                        }
                    }
                }
            }
        }

        Separator {
            Layout.fillWidth: true
            Layout.bottomMargin: Style.current.padding
        }

        // Date format options:
        Column {
            Layout.fillWidth: true
            Layout.leftMargin: Style.current.padding
            Layout.rightMargin: Style.current.padding
            spacing: Style.current.padding
            StatusBaseText {
                text: qsTr("Date Format")
                anchors.left: parent.left
                font.pixelSize: Style.current.primaryTextFontSize
                color: Theme.palette.directColor1
            }

            StatusRadioButton {
                id: ddmmyyFormat
                ButtonGroup.group: dateFormatGroup
                text: qsTr("DD/MM/YY")
                font.pixelSize: Style.dp(13)
                checked: root.languageStore.isDDMMYYDateFormat
                onCheckedChanged: root.languageStore.setIsDDMMYYDateFormat(checked)
            }

            StatusRadioButton {
                id: mmddyyFormat
                ButtonGroup.group: dateFormatGroup
                text: qsTr("MM/DD/YY")
                font.pixelSize: Style.dp(13)
                checked: !root.languageStore.isDDMMYYDateFormat
            }

            ButtonGroup { id: dateFormatGroup }
        }

        // Time format options:
        Column {
            Layout.fillWidth: true
            Layout.leftMargin: Style.current.padding
            Layout.rightMargin: Style.current.padding
            Layout.topMargin: Style.current.padding
            spacing: Style.current.padding
            StatusBaseText {
                text: qsTr("Time Format")
                anchors.left: parent.left
                font.pixelSize: Style.current.primaryTextFontSize
                color: Theme.palette.directColor1
            }

            StatusRadioButton {
                id: h24Format
                ButtonGroup.group: timeFormatGroup
                text: qsTr("24-Hour Time")
                font.pixelSize: Style.dp(13)
                checked: root.languageStore.is24hTimeFormat
                onCheckedChanged: root.languageStore.setIs24hTimeFormat(checked)
            }

            StatusRadioButton {
                id: h12Format
                ButtonGroup.group: timeFormatGroup
                text: qsTr("12-Hour Time")
                font.pixelSize: Style.dp(13)
                checked: !root.languageStore.is24hTimeFormat
            }

            ButtonGroup { id: timeFormatGroup }
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
    }
}

