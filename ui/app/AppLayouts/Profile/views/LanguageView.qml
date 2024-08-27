import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import utils 1.0
import shared.panels 1.0
import shared.popups 1.0
import shared.stores 1.0 as SharedStores

import StatusQ 0.1
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
    property SharedStores.CurrenciesStore currencyStore
    property bool languageSelectionEnabled

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
            z: root.z + 1

            StatusBaseText {
                text: qsTr("Language")
            }
            Item { Layout.fillWidth: true }
            StatusListPicker {
                id: languagePicker

                button.interactive: root.languageSelectionEnabled
                StatusToolTip {
                    y: parent.height + Style.current.padding
                    margins: 0
                    visible: !root.languageSelectionEnabled && languagePicker.button.hovered
                    orientation: StatusToolTip.Orientation.Bottom
                    text: qsTr("Translations coming soon")
                }

                property string newKey

                function descriptionForState(state) {
                    if (state === Constants.translationsState.alpha) return qsTr("Alpha languages")
                    if (state === Constants.translationsState.beta) return qsTr("Beta languages")
                    return ""
                }

                objectName: "languagePicker"
                inputList: SortFilterProxyModel {
                    sourceModel: root.languageStore.languageModel

                    // "category" is the only role that can't be mocked by StatusListPicker::proxy
                    // due to StatusListPicker internal implementation limitation (ListView's section.property)
                    proxyRoles: [
                        FastExpressionRole {
                            name: "category"
                            expression: languagePicker.descriptionForState(model.state)
                            expectedRoles: ["state"]
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
                    shortName: (model) => model.native || model.shortName
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
                        Global.openPopup(languageConfirmationDialog)
                    }
                }
            }
        }

        StatusWarningBox {
            Layout.fillWidth: true
            Layout.bottomMargin: Style.current.padding
            borderColor: Theme.palette.baseColor2
            textColor: Theme.palette.directColor1
            icon: "group-chat"
            iconColor: Theme.palette.baseColor1
            text: qsTr("We need your help to translate Status, so that together we can bring privacy and free speech to the people everywhere, including those who need it most.")
            extraContentComponent: StatusFlatButton {
                icon.name: "external-link"
                text: qsTr("Learn more")
                size: StatusBaseButton.Size.Small
                onClicked: Global.openLinkWithConfirmation(Constants.externalStatusLinkWithHttps + '/translations',  Constants.externalStatusLinkWithHttps)
            }
        }

        Separator {
            Layout.fillWidth: true
            Layout.bottomMargin: Style.current.padding
        }

        // Time format options:
        Column {
            Layout.fillWidth: true
            spacing: Constants.settingsSection.itemSpacing
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

        Component {
            id: languageConfirmationDialog
            ConfirmationDialog {
                destroyOnClose: true
                headerSettings.title: qsTr("Change language")
                confirmationText: qsTr("Display language has been changed. You must restart the application for changes to take effect.")
                confirmButtonLabel: qsTr("Restart")
                onConfirmButtonClicked: {
                    Utils.restartApplication()
                }
            }
        }
    }
}
