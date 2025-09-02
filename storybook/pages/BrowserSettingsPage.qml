import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import AppLayouts.Profile.views
import AppLayouts.Profile.stores

import Storybook

import utils

SplitView {
    Logs { id: logs }

    property QtObject mockData: QtObject {
        property QtObject accountSettings: QtObject {
            property string browserHomepage: "https://status.app"
            property int shouldShowBrowserSearchEngine: Constants.browserSearchEngineDuckDuckGo
            property bool shouldShowFavoritesBar: true
            property int useBrowserEthereumExplorer: 1
        }
    }
    SplitView {
        orientation: Qt.Vertical
        SplitView.fillWidth: true

        BrowserView {
            SplitView.fillWidth: true
            SplitView.fillHeight: true
            contentWidth: parent.width
            sectionTitle: "Browser"
            
            accountSettings: mockData.accountSettings
        }

        LogsAndControlsPanel {
            id: logsAndControlsPanel

            SplitView.minimumHeight: 100
            SplitView.preferredHeight: 200

            logsView.logText: logs.logText
        }
    }

    Pane {
        SplitView.minimumWidth: 300
        SplitView.preferredWidth: 300

        font.pixelSize: 13

        ColumnLayout {
            spacing: 6
            
            Label {
                text: "Browser Homepage"
            }

            TextField {
                Layout.fillWidth: true
                text: mockData.accountSettings.browserHomepage
                onTextChanged: mockData.accountSettings.browserHomepage = text
            }

            Label {
                text: "Browser Search Engine ID"
            }

            TextField {
                Layout.fillWidth: true
                text: mockData.accountSettings.shouldShowBrowserSearchEngine
                onTextChanged: {
                    if (text !== "") {
                        mockData.accountSettings.shouldShowBrowserSearchEngine = parseInt(text)
                    }
                }
            }

            Label {
                text: "Browser Ethereum Explorer ID"
            }

            TextField {
                Layout.fillWidth: true
                text: mockData.accountSettings.useBrowserEthereumExplorer
                onTextChanged: {
                    if (text !== "") {
                        mockData.accountSettings.useBrowserEthereumExplorer = parseInt(text)
                    }
                }
            }

            CheckBox {
                text: "Should show Favorites bar"
                checked: mockData.accountSettings.shouldShowFavoritesBar
                onToggled: mockData.accountSettings.shouldShowFavoritesBar = !mockData.accountSettings.shouldShowFavoritesBar
            }
        }
    }
}

// category: Settings
// status: good
// https://www.figma.com/file/idUoxN7OIW2Jpp3PMJ1Rl8/%E2%9A%99%EF%B8%8F-Settings-%7C-Desktop?node-id=448%3A36296
// https://www.figma.com/file/idUoxN7OIW2Jpp3PMJ1Rl8/%E2%9A%99%EF%B8%8F-Settings-%7C-Desktop?node-id=1573%3A296338
