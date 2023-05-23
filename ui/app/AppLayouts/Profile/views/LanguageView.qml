import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13

import utils 1.0
import shared.panels 1.0
import shared.popups 1.0

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Core.Utils 0.1 as StatusQUtils
import StatusQ.Components 0.1
import StatusQ.Controls 0.1

import AppLayouts.Profile.stores 1.0

import "../popups"

import SortFilterProxyModel 0.2

SettingsContentBase {
    id: root

    property LanguageStore languageStore
    property var currencyStore

    objectName: "languageView"
    onVisibleChanged: { if(!visible) root.setViewIdleState()}
    onBaseAreaClicked: { root.setViewIdleState() }

    Component.onCompleted: {
        root.currencyStore.updateCurrenciesModel()
    }

    function setViewIdleState() {
        currencyPicker.close()
        languagePicker.close()
    }

    function changeLanguage(key) {
        languagePicker.newKey = key
        Qt.callLater(root.languageStore.changeLanguage, languagePicker.newKey)
    }

    ColumnLayout {
        spacing: Constants.settingsSection.itemSpacing
        width: root.contentWidth

        RowLayout {
            Layout.fillWidth: true
            Layout.leftMargin: Style.current.padding
            Layout.rightMargin: Style.current.padding
            z: root.z + 2

            StatusBaseText {
                text: qsTr("Set Display Currency")
            }
            Item { Layout.fillWidth: true }
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
                inputList: root.currencyStore.currenciesModel
                printSymbol: true
                placeholderSearchText: qsTr("Search Currencies")
                maxPickerHeight: 350

                onItemPickerChanged: {
                    if(selected) {
                        currencyPicker.newKey = key
                        currencyPause.start()
                    }
                }
            }
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.leftMargin: Style.current.padding
            Layout.rightMargin: Style.current.padding
            z: root.z + 1

            StatusBaseText {
                text: qsTr("Language")
            }
            Item { Layout.fillWidth: true }
            StatusListPicker {
                id: languagePicker
                property string newKey

                function descriptionForState(state) {
                    if (state === Constants.translationsState.alpha) return qsTr("Alpha languages")
                    if (state === Constants.translationsState.beta) return qsTr("Beta languages")
                    return ""
                }

                objectName: "languagePicker"
                inputList: SortFilterProxyModel {
                    sourceModel: root.languageStore.languageModel

                    // !Don't use proxy roles cause they harm performance a lot!
                    // "category" is the only role that can't be mocked by StatusListPicker::proxy
                    // due to StatusListPicker internal implementation limitation (ListView's section.property)
                    proxyRoles: [
                        ExpressionRole {
                            name: "category"
                            expression: languagePicker.descriptionForState(model.state)
                        }
                    ]

                    sorters: [
                        RoleSorter {
                            roleName: "state"
                            sortOrder: Qt.DescendingOrder
                        },
                        StringSorter {
                            roleName: "name"
                        }
                    ]
                }

                proxy {
                    key: (model) => model.locale
                    name: (model) => model.name
                    shortName: (model) => model.native
                    symbol: (model) => ""
                    imageSource: (model) => StatusQUtils.Emoji.iconSource(model.flag)
                    selected: (model) => model.locale === root.languageStore.currentLanguage
                    setSelected: (model, val) => null // readonly
                }

                z: root.z + 1
                placeholderSearchText: qsTr("Search Languages")
                maxPickerHeight: 350

                onItemPickerChanged: {
                    if(selected && root.languageStore.currentLanguage !== key) {
                        root.changeLanguage(key)
                        languageConfirmationDialog.active = true
                        languageConfirmationDialog.item.open()
                    }
                }
            }
        }

        Separator {
            Layout.fillWidth: true
            Layout.bottomMargin: Style.current.padding
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
            }
            StatusCheckBox {
                id: use24hDefault
                text: qsTr("Use System Settings")
                font.pixelSize: 13
                checked: LocaleUtils.settings.timeFormatUsesDefaults
                onToggled: {
                    LocaleUtils.settings.timeFormatUsesDefaults = checked
                    if (checked)
                        LocaleUtils.settings.timeFormatUses24Hours = LocaleUtils.is24hTimeFormatDefault()
                }
            }
            StatusCheckBox {
                text: qsTr("Use 24-Hour Time")
                font.pixelSize: 13
                enabled: !use24hDefault.checked
                checked: LocaleUtils.settings.timeFormatUses24Hours
                onToggled: LocaleUtils.settings.timeFormatUses24Hours = checked
            }
        }

        Loader {
            id: languageConfirmationDialog
            active: false
            sourceComponent: ConfirmationDialog {
                headerSettings.title: qsTr("Change language")
                confirmationText: qsTr("Display language has been changed. You must restart the application for changes to take effect.")
                confirmButtonLabel: qsTr("Close the app now")
                onConfirmButtonClicked: {
                    languageConfirmationDialog.active = false
                    Qt.quit()
                }
            }
        }
    }
}

