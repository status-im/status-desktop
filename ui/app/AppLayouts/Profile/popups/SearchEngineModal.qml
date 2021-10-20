import QtQuick 2.13
import QtQuick.Controls 2.13

import utils 1.0
import "../../../../shared"
import "../../../../shared/popups"
import "../../../../shared/status"

// TODO: replace with StatusModal
ModalPopup {
    id: popup

    //% "Search engine"
    title: qsTrId("search-engine")

    onClosed: {
        destroy()
    }

    Column {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.rightMargin: Style.current.padding
        anchors.leftMargin: Style.current.padding

        spacing: 0

        ButtonGroup {
            id: searchEnginGroup
        }

        StatusRadioButtonRow {
            //% "None"
            text: qsTrId("none")
            buttonGroup: searchEnginGroup
            checked: localAccountSensitiveSettings.shouldShowBrowserSearchEngine === Constants.browserSearchEngineNone
            onRadioCheckedChanged: {
                if (checked) {
                    localAccountSensitiveSettings.shouldShowBrowserSearchEngine = Constants.browserSearchEngineNone
                }
            }
        }

        StatusRadioButtonRow {
            text: "Google"
            buttonGroup: searchEnginGroup
            checked: localAccountSensitiveSettings.shouldShowBrowserSearchEngine === Constants.browserSearchEngineGoogle
            onRadioCheckedChanged: {
                if (checked) {
                    localAccountSensitiveSettings.shouldShowBrowserSearchEngine = Constants.browserSearchEngineGoogle
                }
            }
        }

        StatusRadioButtonRow {
            text: "Yahoo!"
            buttonGroup: searchEnginGroup
            checked: localAccountSensitiveSettings.shouldShowBrowserSearchEngine === Constants.browserSearchEngineYahoo
            onRadioCheckedChanged: {
                if (checked) {
                    localAccountSensitiveSettings.shouldShowBrowserSearchEngine = Constants.browserSearchEngineYahoo
                }
            }
        }

        StatusRadioButtonRow {
            text: "DuckDuckGo"
            buttonGroup: searchEnginGroup
            checked: localAccountSensitiveSettings.shouldShowBrowserSearchEngine === Constants.browserSearchEngineDuckDuckGo
            onRadioCheckedChanged: {
                if (checked) {
                    localAccountSensitiveSettings.shouldShowBrowserSearchEngine = Constants.browserSearchEngineDuckDuckGo
                }
            }
        }


    }
}

