import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.14

import AppLayouts.stores 1.0 as AppLayoutStores
import AppLayouts.Profile.views 1.0
import AppLayouts.Profile.stores 1.0

import Storybook 1.0

import utils 1.0

import shared.stores 1.0 as SharedStores

SplitView {
    id: root

    Logs { id: logs }

    SplitView {
        orientation: Qt.Vertical
        SplitView.fillWidth: true

        LanguageView {
            SplitView.fillWidth: true
            SplitView.fillHeight: true
            contentWidth: parent.width - 150

            languageSelectionEnabled: ctrlLanguageSelectionEnabled.checked
            languageStore: LanguageStore {
                property string currentLanguage: "en"

                readonly property ListModel languageModel: ListModel {
                    ListElement {
                        locale: "ar"
                        name: "Arabic"
                        shortName: "العربية"
                        flag: "🇸🇦"
                        state: 0
                        selected: false
                    }
                    ListElement {
                        locale: "en"
                        name: "English"
                        shortName: "English"
                        flag: "🏴󠁧󠁢󠁥󠁮󠁧󠁿"
                        state: 2
                        selected: true
                    }
                    ListElement {
                        locale: "cs_CZ"
                        name: "Czech"
                        shortName: "čeština"
                        flag: "🇨🇿"
                        state: 1
                        selected: false
                    }
                }

                function changeLanguage(language) {
                    logs.logEvent("languageStore::changeLanguage", ["language"], arguments)
                    currentLanguage = language
                }
            }

            currencyStore: SharedStores.CurrenciesStore {
                property string currentCurrency: "EUR"

                function updateCurrency(shortName) {
                    logs.logEvent("currencyStore::updateCurrency", ["currencyKey"], arguments)
                    currentCurrency = shortName
                }

                readonly property var currenciesModel: ListModel {
                    ListElement {
                        key: "usd"
                        shortName: "USD"
                        name: qsTr("US Dollars")
                        symbol: "$"
                        category: ""
                        imageSource: "../../assets/twemoji/svg/1f1fa-1f1f8.svg"
                        selected: false
                        isToken: false
                    }

                    ListElement {
                        key: "gbp"
                        shortName: "GBP"
                        name: qsTr("British Pound")
                        symbol: "£"
                        category: ""
                        imageSource: "../../assets/twemoji/svg/1f1ec-1f1e7.svg"
                        selected: false
                        isToken: false
                    }

                    ListElement {
                        key: "eur"
                        shortName: "EUR"
                        name: qsTr("Euros")
                        symbol: "€"
                        category: ""
                        imageSource: "../../assets/twemoji/svg/1f1ea-1f1fa.svg"
                        selected: true
                        isToken: false
                    }
                }
            }
        }

        LogsAndControlsPanel {
            id: logsAndControlsPanel

            SplitView.minimumHeight: 100
            SplitView.preferredHeight: 200

            logsView.logText: logs.logText

            Switch {
                id: ctrlLanguageSelectionEnabled
                text: "Language selection enabled"
            }
        }
    }
}

// category: Components
// status: good
// https://www.figma.com/file/idUoxN7OIW2Jpp3PMJ1Rl8/%E2%9A%99%EF%B8%8F-Settings-%7C-Desktop?node-id=701%3A74776
// https://www.figma.com/file/idUoxN7OIW2Jpp3PMJ1Rl8/%E2%9A%99%EF%B8%8F-Settings-%7C-Desktop?node-id=1592%3A112840
// https://www.figma.com/file/idUoxN7OIW2Jpp3PMJ1Rl8/%E2%9A%99%EF%B8%8F-Settings-%7C-Desktop?node-id=701%3A75345
