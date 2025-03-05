import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.14

import AppLayouts.stores 1.0 as AppLayoutStores
import AppLayouts.Profile.views 1.0
import AppLayouts.Profile.stores 1.0

import Storybook 1.0

import utils 1.0
import mainui 1.0

import shared.stores 1.0 as SharedStores

SplitView {
    id: root

    Logs { id: logs }

    Popups {
        popupParent: root
        sharedRootStore: SharedStores.RootStore {}
        rootStore: AppLayoutStores.RootStore {}
        communityTokensStore: SharedStores.CommunityTokensStore {}
        networksStore: SharedStores.NetworksStore {}
    }

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
                property string currentCurrency: "USD"

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

            Switch {
                id: ctrlLanguageSelectionEnabled
                text: "Language selection enabled"
            }
        }
    }
}

// category: Components

// https://www.figma.com/file/idUoxN7OIW2Jpp3PMJ1Rl8/%E2%9A%99%EF%B8%8F-Settings-%7C-Desktop?node-id=701%3A74776
// https://www.figma.com/file/idUoxN7OIW2Jpp3PMJ1Rl8/%E2%9A%99%EF%B8%8F-Settings-%7C-Desktop?node-id=1592%3A112840
// https://www.figma.com/file/idUoxN7OIW2Jpp3PMJ1Rl8/%E2%9A%99%EF%B8%8F-Settings-%7C-Desktop?node-id=701%3A75345
