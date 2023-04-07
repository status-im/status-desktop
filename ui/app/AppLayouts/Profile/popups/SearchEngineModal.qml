import QtQuick 2.13
import QtQuick.Controls 2.13

import utils 1.0
import shared.popups 1.0
import shared.controls 1.0

// TODO: replace with StatusModal
ModalPopup {
    id: popup

    property var accountSettings

    title: qsTr("Search engine")

    onClosed: {
        destroy()
    }

    Column {
        anchors.left: parent.left
        anchors.right: parent.right

        spacing: 0

        ButtonGroup {
            id: searchEnginGroup
        }

        RadioButtonSelector {
            title: qsTr("None")
            buttonGroup: searchEnginGroup
            checked: accountSettings.shouldShowBrowserSearchEngine === Constants.browserSearchEngineNone
            onCheckedChanged: {
                if (checked) {
                    accountSettings.shouldShowBrowserSearchEngine = Constants.browserSearchEngineNone
                }
            }
        }

        RadioButtonSelector {
            title: "Google"
            buttonGroup: searchEnginGroup
            checked: accountSettings.shouldShowBrowserSearchEngine === Constants.browserSearchEngineGoogle
            onCheckedChanged: {
                if (checked) {
                    accountSettings.shouldShowBrowserSearchEngine = Constants.browserSearchEngineGoogle
                }
            }
        }

        RadioButtonSelector {
            title: "Yahoo!"
            buttonGroup: searchEnginGroup
            checked: accountSettings.shouldShowBrowserSearchEngine === Constants.browserSearchEngineYahoo
            onCheckedChanged: {
                if (checked) {
                    accountSettings.shouldShowBrowserSearchEngine = Constants.browserSearchEngineYahoo
                }
            }
        }

        RadioButtonSelector {
            title: "DuckDuckGo"
            buttonGroup: searchEnginGroup
            checked: accountSettings.shouldShowBrowserSearchEngine === Constants.browserSearchEngineDuckDuckGo
            onCheckedChanged: {
                if (checked) {
                    accountSettings.shouldShowBrowserSearchEngine = Constants.browserSearchEngineDuckDuckGo
                }
            }
        }


    }
}

