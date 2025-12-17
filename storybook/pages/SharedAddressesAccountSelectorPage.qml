import QtQuick
import QtQuick.Controls

import AppLayouts.Wallet.stores
import AppLayouts.Communities.panels

import Storybook
import Models
import Mocks

SplitView {
    id: root

    orientation: Qt.Vertical
    SplitView.fillWidth: true

    Logs { id: logs }

    readonly property WalletAssetsStoreMock walletAssetStore: WalletAssetsStoreMock {
    }

    WalletAccountsModel {
        id: walletAccountsModel
    }

    ListModel {
        id: groupedAccountAssetsModel

        ListElement {
            symbol: "DAI"

            balances: [
                ListElement {
                    chainId: 5
                    balance: "20"
                    account: "0x7F47C2e18a4BBf5487E6fb082eC2D9Ab0E6d7240"
                },
                ListElement {
                   chainId: 5
                   balance: "123456789123456789"
                   account: "0x7F47C2e98a4BBf5487E6fb082eC2D9Ab0E6d8881"
                }
            ]
        }

        ListElement {
            symbol: "ETH"

            balances: [
                ListElement {
                    chainId: 11155420
                    balance: "1013151281976507736"
                    account: "0x7F47C2e18a4BBf5487E6fb082eC2D9Ab0E6d7240"
                },
                ListElement {
                   chainId: 5
                   balance: "123456789123456789"
                   account: "0x7F47C2e98a4BBf5487E6fb082eC2D9Ab0E6d8881"
                }
            ]
        }
    }

    SharedAddressesAccountSelector {
        id: accountSelector

        SplitView.fillWidth: true
        SplitView.fillHeight: true

        hasPermissions: true
        uniquePermissionAssetsKeys: ["ETH", "DAI", "STT"]
        uniquePermissionCollectiblesKeys: ["ATKN_key", "TMC1_key", "MYTKN_key"]

        model: walletAccountsModel
        walletAssetsModel: groupedAccountAssetsModel

        walletCollectiblesModel: ListModel {
            ListElement {
                name: "TMaster-C1"
                ownership: [
                    ListElement {
                        accountAddress: "0x7F47C2e18a4BBf5487E6fb082eC2D9Ab0E6d7240"
                        balance: 1
                    }
                ]
                communityId: "communityId_1"
            }
            ListElement {
                name: "TMaster-C1"
                ownership: [
                    ListElement {
                        accountAddress: "0x7F47C2e18a4BBf5487E6fb082eC2D9Ab0E6d7240"
                        balance: 1
                    }
                ]
                communityId: "communityId_1"
            }
            ListElement {
                name: "TMaster-C1"
                ownership: [
                    ListElement {
                        accountAddress: "0x7F47C2e18a4BBf5487E6fb082eC2D9Ab0E6d7240"
                        balance: 1
                    }
                ]
                communityId: "communityId_1"
            }
            ListElement {
                name: "TMaster-C1"
                ownership: [
                    ListElement {
                        accountAddress: "0x7F47C2e98a4BBf5487E6fb082eC2D9Ab0E6d8882"
                        balance: 1
                    }
                ]
                communityId: "communityId_1"
            }
            ListElement {
                name: "TMaster-C1"
                ownership: [
                    ListElement {
                        accountAddress: "0x7F47C2e98a4BBf5487E6fb082eC2D9Ab0E6d8882"
                        balance: 1
                    }
                ]
                communityId: "communityId_1"
            }
            ListElement {
                name: "My token"
                ownership: [
                    ListElement {
                        accountAddress: "0x7F47C2e98a4BBf5487E6fb082eC2D9Ab0E6d8882"
                        balance: 1
                    }
                ]
                communityId: "communityId_1"
            }
            ListElement {
                name: "My token 2"
                ownership: [
                    ListElement {
                        accountAddress: "0x7F47C2e98a4BBf5487E6fb082eC2D9Ab0E6d8882"
                        balance: 1
                    }
                ]
                communityId: "communityId_1"
            }
            ListElement {
                name: "TMaster-C2"
                ownership: [
                    ListElement {
                        accountAddress: "0x7F47C2e98a4BBf5487E6fb082eC2D9Ab0E6d8882"
                        balance: 1
                    }
                ]
                communityId: "communityId_2"
            }
            ListElement {
                name: "A token"
                ownership: [
                    ListElement {
                        accountAddress: "0x7F47C2e18a4BBf5487E6fb082eC2D9Ab0E6d7240"
                        balance: 1
                    }
                ]
                communityId: "communityId_1"
            }
            ListElement {
                name: "A token"
                ownership: [
                    ListElement {
                        accountAddress: "0x7F47C2e18a4BBf5487E6fb082eC2D9Ab0E6d7240"
                        balance: 1
                    }
                ]
                communityId: "communityId_1"
            }
        }

        communityCollectiblesModel: ListModel {
            Component.onCompleted: {
                append([
                    {
                       key: "TMC1_key",
                       symbol: "TMC1",
                       name: "TMaster-C1",
                       communityId: "communityId_1",
                       icon: ModelsData.collectibles.anniversary
                    },
                    {
                       key: "MYTKN_key",
                       symbol: "MYTKN",
                       name: "My token",
                       communityId: "communityId_1",
                       icon: ModelsData.collectibles.cryptoKitties
                    },
                    {
                       key: "ATKN_key",
                       symbol: "ATKN",
                       name: "A token",
                       communityId: "communityId_1",
                       icon: ModelsData.collectibles.mana
                    }
                ])
            }
        }

        communityId: "communityId_1"

        selectedSharedAddressesMap: new Map()//root.selectedSharedAddressesMap

        getCurrencyAmount: (balance, symbol) => ({
            amount: balance,
            symbol: symbol.toUpperCase(),
            displayDecimals: 2,
            stripTrailingZeroes: false
        })
    }

    LogsAndControlsPanel {
        id: logsAndControlsPanel

        SplitView.minimumHeight: 100
        SplitView.preferredHeight: 200

        logsView.logText: logs.logText
    }
}

// category: Panels
