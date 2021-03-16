import QtQuick 2.13
import QtQuick.Controls 2.13
import "../../../../../imports"
import "../../../../../shared"
import "../../../../../shared/status"

ModalPopup {
    id: popup

    //% "Search engine"
    title: qsTrId("search-engine")

    onClosed: {
        destroy()
    }

    Column {
        spacing: Style.current.bigPadding
        width: parent.width

        ButtonGroup {
            id: searchEnginGroup
        }

        StatusRadioButton {
            //% "None"
            text: qsTrId("none")
            ButtonGroup.group: searchEnginGroup
            checked: appSettings.shouldShowBrowserSearchEngine === Constants.browserSearchEngineNone
            onCheckedChanged: {
                if (checked) {
                    appSettings.shouldShowBrowserSearchEngine = Constants.browserSearchEngineNone
                }
            }
        }

        StatusRadioButton {
            text: "Google"
            ButtonGroup.group: searchEnginGroup
            checked: appSettings.shouldShowBrowserSearchEngine === Constants.browserSearchEngineGoogle
            onCheckedChanged: {
                if (checked) {
                    appSettings.shouldShowBrowserSearchEngine = Constants.browserSearchEngineGoogle
                }
            }
        }

        StatusRadioButton {
            text: "Yahoo!"
            ButtonGroup.group: searchEnginGroup
            checked: appSettings.shouldShowBrowserSearchEngine === Constants.browserSearchEngineYahoo
            onCheckedChanged: {
                if (checked) {
                    appSettings.shouldShowBrowserSearchEngine = Constants.browserSearchEngineYahoo
                }
            }
        }

        StatusRadioButton {
            text: "DuckDuckGo"
            ButtonGroup.group: searchEnginGroup
            checked: appSettings.shouldShowBrowserSearchEngine === Constants.browserSearchEngineDuckDuckGo
            onCheckedChanged: {
                if (checked) {
                    appSettings.shouldShowBrowserSearchEngine = Constants.browserSearchEngineDuckDuckGo
                }
            }
        }


    }
}

