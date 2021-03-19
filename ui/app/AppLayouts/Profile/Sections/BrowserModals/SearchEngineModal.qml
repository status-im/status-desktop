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
            checked: appSettings.shouldShowBrowserSearchEngine === Constants.browserSearchEngineNone
            onRadioCheckedChanged: {
                if (checked) {
                    appSettings.shouldShowBrowserSearchEngine = Constants.browserSearchEngineNone
                }
            }
        }

        StatusRadioButtonRow {
            text: "Google"
            buttonGroup: searchEnginGroup
            checked: appSettings.shouldShowBrowserSearchEngine === Constants.browserSearchEngineGoogle
            onRadioCheckedChanged: {
                if (checked) {
                    appSettings.shouldShowBrowserSearchEngine = Constants.browserSearchEngineGoogle
                }
            }
        }

        StatusRadioButtonRow {
            text: "Yahoo!"
            buttonGroup: searchEnginGroup
            checked: appSettings.shouldShowBrowserSearchEngine === Constants.browserSearchEngineYahoo
            onRadioCheckedChanged: {
                if (checked) {
                    appSettings.shouldShowBrowserSearchEngine = Constants.browserSearchEngineYahoo
                }
            }
        }

        StatusRadioButtonRow {
            text: "DuckDuckGo"
            buttonGroup: searchEnginGroup
            checked: appSettings.shouldShowBrowserSearchEngine === Constants.browserSearchEngineDuckDuckGo
            onRadioCheckedChanged: {
                if (checked) {
                    appSettings.shouldShowBrowserSearchEngine = Constants.browserSearchEngineDuckDuckGo
                }
            }
        }


    }
}

