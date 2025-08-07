import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

import StatusQ.Core.Theme
import StatusQ.Popups.Dialog

import utils
import shared.controls

StatusDialog {
    id: popup

    property var accountSettings

    title: qsTr("Search engine")
    width: 480
    footer: null
    horizontalPadding: Theme.halfPadding
    verticalPadding: Theme.halfPadding

    onClosed: {
        destroy()
    }

    contentItem: ColumnLayout {
        spacing: 0

        ButtonGroup {
            id: searchEnginGroup
        }

        RadioButtonSelector {
            Layout.fillWidth: true
            title: qsTr("None")
            buttonGroup: searchEnginGroup
            checked: accountSettings.shouldShowBrowserSearchEngine === Constants.browserSearchEngineNone
            onCheckedChanged: {
                if (checked) {
                    accountSettings.shouldShowBrowserSearchEngine = Constants.browserSearchEngineNone
                    popup.close()
                }
            }
        }

        RadioButtonSelector {
            Layout.fillWidth: true
            title: "Google"
            buttonGroup: searchEnginGroup
            checked: accountSettings.shouldShowBrowserSearchEngine === Constants.browserSearchEngineGoogle
            onCheckedChanged: {
                if (checked) {
                    accountSettings.shouldShowBrowserSearchEngine = Constants.browserSearchEngineGoogle
                    popup.close()
                }
            }
        }

        RadioButtonSelector {
            Layout.fillWidth: true
            title: "Yahoo!"
            buttonGroup: searchEnginGroup
            checked: accountSettings.shouldShowBrowserSearchEngine === Constants.browserSearchEngineYahoo
            onCheckedChanged: {
                if (checked) {
                    accountSettings.shouldShowBrowserSearchEngine = Constants.browserSearchEngineYahoo
                    popup.close()
                }
            }
        }

        RadioButtonSelector {
            Layout.fillWidth: true
            title: "DuckDuckGo"
            buttonGroup: searchEnginGroup
            checked: accountSettings.shouldShowBrowserSearchEngine === Constants.browserSearchEngineDuckDuckGo
            onCheckedChanged: {
                if (checked) {
                    accountSettings.shouldShowBrowserSearchEngine = Constants.browserSearchEngineDuckDuckGo
                    popup.close()
                }
            }
        }
    }
}

