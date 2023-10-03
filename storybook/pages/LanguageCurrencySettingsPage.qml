import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.14

import AppLayouts.Profile.views 1.0
import AppLayouts.Profile.stores 1.0

import Storybook 1.0

import utils 1.0

SplitView {
    Logs { id: logs }

    SplitView {
        orientation: Qt.Vertical
        SplitView.fillWidth: true

        LanguageView {
            SplitView.fillWidth: true
            SplitView.fillHeight: true
            contentWidth: parent.width

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
                }

                function changeLanguage(language) {
                    logs.logEvent("languageStore::changeLanguage", ["language"], arguments)
                    currentLanguage = language
                }
            }

            currencyStore: QtObject {
                property string currentCurrency: "USD"
                property string currentCurrencySymbol: "$"

                readonly property ListModel currenciesModel: ListModel {
                    ListElement {
                        key: "usd"
                        shortName: "USD"
                        name: "US Dollars"
                        symbol: "$"
                        category: ""
                        imageSource: "../../assets/twemoji/svg/1f1fa-1f1f8.svg"
                        selected: true
                    }

                    ListElement {
                        key: "gbp"
                        shortName: "GBP"
                        name: "British Pound"
                        symbol: "£"
                        category: ""
                        imageSource: "../../assets/twemoji/svg/1f1ec-1f1e7.svg"
                        selected: false
                    }
                }

                function updateCurrenciesModel() {
                    logs.logEvent("currencyStore::updateCurrenciesModel")
                }

                function updateCurrency(currencyKey) {
                    logs.logEvent("currencyStore::updateCurrency", ["currencyKey"], arguments)
                }
            }
        }

        LogsAndControlsPanel {
            id: logsAndControlsPanel

            SplitView.minimumHeight: 100
            SplitView.preferredHeight: 200

            logsView.logText: logs.logText
        }
    }

    Control {
        SplitView.minimumWidth: 300
        SplitView.preferredWidth: 300

        font.pixelSize: 13

        // model editor will go here
    }
}

// category: Components

// https://www.figma.com/file/idUoxN7OIW2Jpp3PMJ1Rl8/%E2%9A%99%EF%B8%8F-Settings-%7C-Desktop?node-id=701%3A74776
// https://www.figma.com/file/idUoxN7OIW2Jpp3PMJ1Rl8/%E2%9A%99%EF%B8%8F-Settings-%7C-Desktop?node-id=1592%3A112840
// https://www.figma.com/file/idUoxN7OIW2Jpp3PMJ1Rl8/%E2%9A%99%EF%B8%8F-Settings-%7C-Desktop?node-id=701%3A75345
