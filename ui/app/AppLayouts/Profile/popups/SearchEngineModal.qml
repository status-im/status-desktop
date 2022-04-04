import QtQuick 2.13
import QtQuick.Controls 2.13

import utils 1.0
import shared.popups 1.0
import shared.controls 1.0

// TODO: replace with StatusModal
ModalPopup {
    id: popup

    title: qsTr("Search engine")

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

        RadioButtonSelector {
            title: qsTr("None")
            buttonGroup: searchEnginGroup
            checked: localAccountSensitiveSettings.shouldShowBrowserSearchEngine === Constants.browserSearchEngineNone
            onCheckedChanged: {
                if (checked) {
                    localAccountSensitiveSettings.shouldShowBrowserSearchEngine = Constants.browserSearchEngineNone
                }
            }
        }

        RadioButtonSelector {
            title: "Google"
            buttonGroup: searchEnginGroup
            checked: localAccountSensitiveSettings.shouldShowBrowserSearchEngine === Constants.browserSearchEngineGoogle
            onCheckedChanged: {
                if (checked) {
                    localAccountSensitiveSettings.shouldShowBrowserSearchEngine = Constants.browserSearchEngineGoogle
                }
            }
        }

        RadioButtonSelector {
            title: "Yahoo!"
            buttonGroup: searchEnginGroup
            checked: localAccountSensitiveSettings.shouldShowBrowserSearchEngine === Constants.browserSearchEngineYahoo
            onCheckedChanged: {
                if (checked) {
                    localAccountSensitiveSettings.shouldShowBrowserSearchEngine = Constants.browserSearchEngineYahoo
                }
            }
        }

        RadioButtonSelector {
            title: "DuckDuckGo"
            buttonGroup: searchEnginGroup
            checked: localAccountSensitiveSettings.shouldShowBrowserSearchEngine === Constants.browserSearchEngineDuckDuckGo
            onCheckedChanged: {
                if (checked) {
                    localAccountSensitiveSettings.shouldShowBrowserSearchEngine = Constants.browserSearchEngineDuckDuckGo
                }
            }
        }


    }
}

