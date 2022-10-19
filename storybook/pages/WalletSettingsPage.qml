import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.14

import AppLayouts.Profile.views 1.0
import AppLayouts.Profile.stores 1.0

import Storybook 1.0

import utils 1.0

SplitView {
    Logs { id: logs }

    property var mockAccountData: QtObject {
        property var name: "Status account"
        property var emoji: '<img class="emoji" draggable="false" alt="👲🏼" src="qrc:/StatusQ/src/assets/twemoji/svg/1f472-1f3fc.svg?72x72" width="16" height="16" style="vertical-align: top"/>'
        property var color: "#4360df"
        property var address: "0x123"
        property var walletType: "generated" // watch key seed generated
        property var path: "m/44'/60'/0'/0/0"

        property var relatedAccounts: ListModel {
            ListElement{
                name: "Status account"
                emoji: '<img class="emoji" draggable="false" alt="👲🏼" src="qrc:/StatusQ/src/assets/twemoji/svg/1f472-1f3fc.svg?72x72" width="16" height="16" style="vertical-align: top"/>'
                color: "#4360df"
                address: "0x123"
                walletType: "generated" // watch key seed generated
                path: "m/44'/60'/0'/0/0"
            }
        }
    }

    SplitView {
        orientation: Qt.Vertical
        SplitView.fillWidth: true

        WalletView {
            SplitView.fillWidth: true
            SplitView.fillHeight: true
            contentWidth: parent.width

            emojiPopup: QtObject {
                property int x: 0
                property int y: 0
                function open() {
                    logs.logEvent("emojiPopup::open")
                }
            }

            onCopyToClipboard: {
                logs.logEvent("signals::copyToClipboard", ["address"], arguments)
            }

            walletStore: WalletStore {
                accountSensitiveSettings: QtObject {
                }

                currentAccount: mockAccountData

                areTestNetworksEnabled: false

                layer1Networks: ListModel {
                    ListElement {
                        chainName: "Ethereum Mainnet"
                        iconUrl: "network/Network=Ethereum"
                    }
                }

                layer2Networks: ListModel {
                    ListElement {
                        chainName: "Optimism"
                        iconUrl: "network/Network=Optimism"
                    }
                    ListElement {
                        chainName: "Arbitrum"
                        iconUrl: "network/Network=Arbitrum"
                    }
                }

                testNetworks: ListModel {}

                accounts: ListModel {}
                importedAccounts: ListModel {
                    ListElement {
                        name: "Status account"
                        emoji: '<img class="emoji" draggable="false" alt="👲🏼" src="qrc:/StatusQ/src/assets/twemoji/svg/1f472-1f3fc.svg?72x72" width="16" height="16" style="vertical-align: top"/>'
                        color: "#4360df"
                        address: "0x123"
                        walletType: "generated" // watch key seed generated
                        path: "m/44'/60'/0'/0/0"
                    }
                }
                generatedAccounts: ListModel {}
                watchOnlyAccounts: ListModel {}
                walletTokensModule: ListModel {}
                defaultTokenList: ListModel {}
                customTokenList: ListModel {}

                dappList: ListModel {
                    ListElement {
                        name: "Dapp 1"
                        accounts: []
                        color: "#ffffff"
                        emoji: ""
                        address: "0x123"
                    }
                }

                function toggleTestNetworksEnabled(){
                    logs.logEvent("walletStore::toggleTestNetworksEnabled")
                }

                function addCustomToken(chainId, address, name, symbol, decimals) {
                    logs.logEvent("walletStore::addCustomToken", ["chainId", "address", "name", "symbol", "decimals"], arguments)
                }

                function toggleVisible(chainId, address) {
                    logs.logEvent("walletStore::toggleVisible", ["chainId", "address"], arguments)
                }

                function removeCustomToken(chainId, address) {
                    logs.logEvent("walletStore::removeCustomToken", ["chainId", "address"], arguments)
                }

                function switchAccountByAddress(address) {
                    logs.logEvent("walletStore::switchAccountByAddress", ["address"], arguments)
                }

                function deleteAccount(address) {
                    logs.logEvent("walletStore::deleteAccount", ["address"], arguments)
                }

                function updateCurrentAccount(address, accountName, color, emoji) {
                    logs.logEvent("walletStore::updateCurrentAccount", ["address", "accountName", "color", "emoji"], arguments)
                }

                function disconnect(dappName) {
                    logs.logEvent("walletStore::disconnect", ["dappName"], arguments)
                }

                function accountsForDapp(dappName) {
                    logs.logEvent("walletStore::accountsForDapp", ["dappName"], arguments)
                }

                function disconnectAddress(dappName, address) {
                    logs.logEvent("walletStore::disconnectAddress", ["dappName", "address"], arguments)
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
