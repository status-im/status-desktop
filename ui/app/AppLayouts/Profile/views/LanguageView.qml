import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import utils
import shared.panels
import shared.popups
import shared.stores as SharedStores

import StatusQ
import StatusQ.Core
import StatusQ.Core.Theme
import StatusQ.Core.Utils as StatusQUtils
import StatusQ.Components
import StatusQ.Controls

import "../popups"

SettingsContentBase {
    id: root

    // list of language/locale codes, e.g. ["cs_CZ","ko","fr"]
    required property var availableLanguages
    // language currently selected for translations, e.g. "cs"
    required property string currentLanguage

    property SharedStores.CurrenciesStore currencyStore
    property bool languageSelectionEnabled

    objectName: "languageView"
    onVisibleChanged: { if(!visible) root.setViewIdleState()}
    onBaseAreaClicked: { root.setViewIdleState() }

    signal changeLanguageRequested(string newLanguageCode)

    function setViewIdleState() {
        currencyPicker.close()
        languagePicker.close()
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

                // updateCurrency function operation blocks a little bit the UI
                // so getting around it with a small pause (timer) in order to get
                // the desired visual behavior
                Timer {
                    id: currencyPause
                    interval: 100
                    onTriggered: {
                        const idx = StatusQUtils.ModelUtils.indexOf(root.currencyStore.currenciesModel, "key", currencyPicker.newKey)
                        const shortName = root.currencyStore.currenciesModel.get(idx === -1 ? 0 : idx).shortName
                        root.currencyStore.updateCurrency(shortName)
                    }
                }

                z: root.z + 2

                inputList: root.currencyStore.currenciesModel

                printSymbol: true
                placeholderSearchText: qsTr("Search Currencies")
                maxPickerHeight: 350

                onItemPickerChanged: (key, selected) => {
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
            StatusLanguageSelector {
                Layout.preferredWidth: currencyPicker.width
                id: languagePicker
                enabled: root.languageSelectionEnabled
                currentLanguage: root.currentLanguage
                languageCodes: root.availableLanguages
                lokalisedLanguageScores: LanguageService.lokaliseLanguages
                onLanguageSelected: (languageCode) =>
                                    languageConfirmationDialog.createObject(root, {oldCode: root.currentLanguage, newCode: languageCode}).open()

                StatusToolTip {
                    y: parent.height + Theme.padding
                    margins: 0
                    visible: !root.languageSelectionEnabled && languagePicker.hovered
                    orientation: StatusToolTip.Orientation.Bottom
                    text: qsTr("Translations coming soon")
                }
            }
        }

        StatusWarningBox {
            Layout.fillWidth: true
            Layout.bottomMargin: Theme.padding
            borderColor: Theme.palette.baseColor2
            textColor: Theme.palette.directColor1
            icon: "group-chat"
            iconColor: Theme.palette.baseColor1
            text: qsTr("We need your help to translate Status, so that together we can bring privacy and free speech to the people everywhere, including those who need it most.")
            extraContentComponent: StatusFlatButton {
                icon.name: "external-link"
                text: qsTr("Learn more")
                size: StatusBaseButton.Size.Small
                onClicked: Global.activateDeepLink(
                    // Status Community's translation channel
                    "https://status.app/cc/G-gAAORqbagnhrSvikdvJE1-f7iUTLVeGDI6uS1gbdHJClvLOIsozcOgbrhs8sVle2GBnz0QghKrJugxwVVmAGNFIcm4KPPNFIKvKdf_83iSXsosZUr1rHgLeJqn0el8TPRaMwxCExy35wPCYGG0TH9dzY_YAnS4705bQNv18a-cEVCyBKPdTgXvRJjjowqNh-zcFB9U6PpT2klNfmPCj05HNG3ShpUfTYxsXslmjKKSyWWQUsyikZIz8sV0zsia-Wwe#zQ3shZeEJqTC1xhGUjxuS4rtHSrhJ8vUYp64v6qWkLpvdy9L9"
                )
            }
        }

        Separator {
            Layout.fillWidth: true
            Layout.bottomMargin: Theme.padding
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
                font.pixelSize: Theme.additionalTextSize
                checked: LocaleUtils.settings.timeFormatUsesDefaults
                onToggled: {
                    LocaleUtils.settings.timeFormatUsesDefaults = checked
                    if (checked)
                        LocaleUtils.settings.timeFormatUses24Hours = LocaleUtils.is24hTimeFormatDefault()
                }
            }
            StatusCheckBox {
                text: qsTr("Use 24-Hour Time")
                font.pixelSize: Theme.additionalTextSize
                enabled: !use24hDefault.checked
                checked: LocaleUtils.settings.timeFormatUses24Hours
                onToggled: LocaleUtils.settings.timeFormatUses24Hours = checked
            }
        }

        Component {
            id: languageConfirmationDialog
            ConfirmationDialog {
                property string oldCode
                property string newCode

                destroyOnClose: true
                title: qsTr("Change language")
                confirmationText: qsTr("Display language has been changed. You must restart the application for changes to take effect.")
                confirmButtonLabel: qsTr("Restart")
                onConfirmButtonClicked: {
                    root.changeLanguageRequested(newCode)
                    close()
                }
                onRejected: root.currentLanguage = oldCode
            }
        }
    }
}
