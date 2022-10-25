import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.14

import AppLayouts.Profile.views 1.0
import AppLayouts.Profile.stores 1.0

import Storybook 1.0

import utils 1.0

SplitView {
    Logs { id: logs }

    ListModel {
        id: dappsModel

        ListElement {
            name: "http://simpledapp.eth"
            accounts: [
                ListElement {
                    name: "Main Account"
                    address: "0x2B748A02e06B159C7C3E98F5064577B96E55A7b4"
                    color: "#4360DF"
                    emoji: "😎"
                },
                ListElement {
                    name: "Account 2"
                    address: "0x5aD88F52b5cb0E4120c0Dd32CFeE782436F492E5"
                    color: "#887AF9"
                    emoji: "😋"
                }
            ]
        }
    }

    property QtObject mockData: QtObject {
        property QtObject accountSettings: QtObject {
            property string browserHomepage: "https://status.im/"
            property int shouldShowBrowserSearchEngine: 3
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
            sectionTitle: "Browser section"
            
            accountSettings: mockData.accountSettings

            store: ProfileSectionStore {
                property WalletStore walletStore: WalletStore {
                    accountSensitiveSettings: mockData.accountSettings
                    dappList: dappsModel

                    function disconnect(dappName) {
                        for (let i = 0; i < dappsModel.count; i++) {
                            if (dappsModel.get(i).name === dappName) {
                                dappsModel.remove(i)
                                return
                            }
                        }
                    }
                    function disconnectAddress(dappName, address) {
                        for (let i = 0; i < dappsModel.count; i++) {
                            const dapp = dappsModel.get(i)
                            if (dapp.name === dappName) {
                                for (let i = 0; i < dapp.accounts.count; i++) {
                                    if (dapp.accounts.get(i).address === address) {
                                        dapp.accounts.remove(i)
                                        return
                                    }
                                }
                                return
                            }
                        }
                    }
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


