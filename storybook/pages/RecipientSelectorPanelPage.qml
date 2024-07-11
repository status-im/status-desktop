import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import AppLayouts.Wallet 1.0

import shared.popups.send.panels 1.0
import shared.stores.send 1.0

import StatusQ.Core.Utils 0.1
import StatusQ.Core.Theme 0.1
import StatusQ 0.1

import utils 1.0

import Storybook 1.0
import Models 1.0

import SortFilterProxyModel 0.2

SplitView {
    id: root

    readonly property var chainColors: ({
            eth: "#627EEA",
            oeth: "#E90101",
            arb1: "#939ba1"
        }
    )

    ListModel {
        id: savedAddressesModel

        Component.onCompleted: {
            const data = []
            for (let i = 0; i < 10; i++)
                data.push({
                              name: "some saved addr name " + i,
                              ens: [],
                              address: "0x2B748A02e06B159C7C3E98F5064577B96E55A7b4",
                              chainShortNames: "eth:arb1"
                          })
            append(data)
        }
    }

    ListModel {
        id: walletAccountsModel
        readonly property var data: [
            {
                name: "helloworld",
                emoji: "😋",
                colorId: Constants.walletAccountColors.primary,
                color: "#2A4AF5",
                address: "0x7F47C2e18a4BBf5487E6fb082eC2D9Ab0E6d7240",
                walletType: "",
                preferredSharingChainIds: "5:420:421613",
                colorizedChainShortNames: WalletUtils.colorizedChainPrefixNew(chainColors, "eth:oeth:arb1:"),
                currencyBalance: ({amount: 1.25,
                                      symbol: "USD",
                                      displayDecimals: 2,
                                      stripTrailingZeroes: false}),
                migratedToKeycard: true
            },
            {
                name: "Hot wallet (generated)",
                emoji: "🚗",
                colorId: Constants.walletAccountColors.army,
                color: "#216266",
                address: "0x7F47C2e98a4BBf5487E6fb082eC2D9Ab0E6d8881",
                walletType: Constants.generatedWalletType,
                preferredSharingChainIds: "5:420:421613",
                colorizedChainShortNames: WalletUtils.colorizedChainPrefixNew(chainColors, "eth:oeth:arb1:"),
                currencyBalance: ({amount: 10,
                                      symbol: "USD",
                                      displayDecimals: 2,
                                      stripTrailingZeroes: false}),
                migratedToKeycard: false
            },
            {
                name: "Family (seed)",
                emoji: "🎨",
                colorId: Constants.walletAccountColors.magenta,
                color: "#EC266C",
                address: "0x7F47C2e98a4BBf5487E6fb082eC2D9Ab0E6d8882",
                walletType: Constants.seedWalletType,
                preferredSharingChainIds: "5:420:421613",
                colorizedChainShortNames: WalletUtils.colorizedChainPrefixNew(chainColors, "eth:oeth:arb1:"),
                currencyBalance: ({amount: 110.05,
                                      symbol: "USD",
                                      displayDecimals: 2,
                                      stripTrailingZeroes: false}),
                migratedToKeycard: false
            },
            {
                name: "Tag Heuer (watch)",
                emoji: "⌚",
                colorId: Constants.walletAccountColors.copper,
                color: "#CB6256",
                address: "0x7F47C2e98a4BBf5487E6fb082eC2D9Ab0E6d8883",
                walletType: Constants.watchWalletType,
                preferredSharingChainIds: "5:420:421613",
                colorizedChainShortNames: WalletUtils.colorizedChainPrefixNew(chainColors, "eth:oeth:arb1:"),
                currencyBalance: ({amount: 3,
                                      symbol: "USD",
                                      displayDecimals: 2,
                                      stripTrailingZeroes: false}),
                migratedToKeycard: false
            },
            {
                name: "Fab (key)",
                emoji: "🔑",
                colorId: Constants.walletAccountColors.camel,
                color: "#C78F67",
                address: "0x7F47C2e98a4BBf5487E6fb082eC2D9Ab0E6d8884",
                walletType: Constants.keyWalletType,
                preferredSharingChainIds: "5:420:421613",
                colorizedChainShortNames: WalletUtils.colorizedChainPrefixNew(chainColors, "eth:oeth:arb1:"),
                currencyBalance: ({amount: 999,
                                      symbol: "USD",
                                      displayDecimals: 2,
                                      stripTrailingZeroes: false}),
                migratedToKeycard: false
            }
        ]

        Component.onCompleted: append(data)

    }

    ListModel {
        id: recentsModel

        readonly property var data: [
            {
                activityEntry:
                {
                    sender: "0x10bbfe4072ebb77e53aa9117c7300531d151feaf",
                    recipient: "0x10bbfe4072ebb77e53aa9117c7300531d151ffff",
                    timestamp: "1715274859",
                    txType: 0,
                    amountCurrency: {
                        objectName: "",
                        amount: 1,
                        symbol:"",
                        displayDecimals: 0,
                        stripTrailingZeroes: true
                    }
                }
            },
            {
                activityEntry:
                {
                    sender: "0x1bbbfe4072ebb77e53aa9117c7300531d151feaf",
                    recipient: "0xebfbfe4072ebb77e53aa9117c7300531d1511111",
                    timestamp: "1709832115",
                    txType: 1,
                    amountCurrency: {
                        objectName: "",
                        amount: 1,
                        symbol:"",
                        displayDecimals: 0,
                        stripTrailingZeroes: true
                    }
                }
            }
        ]

        Component.onCompleted: append(data)
    }

    SplitView {
        SplitView.fillWidth: true
        SplitView.fillHeight: true

        orientation: Qt.Vertical

        Rectangle {
            SplitView.fillWidth: true
            SplitView.fillHeight: true
            color: Theme.palette.baseColor3

            RecipientSelectorPanel {
                anchors.centerIn: parent
                height: heightSlider.value
                width: widthSlider.value
                savedAddressesModel: savedAddressesModel
                myAccountsModel: walletAccountsModel
                recentRecipientsModel: recentsModel

                onRecipientSelected: logs.logEvent("RecipientSelectorPanel::onRecipientSelected - [Type, Recipient]: [" + type + ", " + recipient + "]")
                onRecentRecipientsTabSelected: logs.logEvent("RecipientSelectorPanel::onRecentRecipientsTabSelected - Recents tab selected")
            }
        }

        Logs {
            id: logs
        }

        LogsView {
            clip: true

            SplitView.preferredHeight: 150
            SplitView.fillWidth: true

            logText: logs.logText
        }
    }

    Pane {
        SplitView.preferredWidth: 300

        ColumnLayout {
            Label {
                text: "Heigth:"
            }
            Slider {
                id: heightSlider
                from: 300
                to: 600
                stepSize: 1
                value: 500
            }
            Label {
                text: "Width:"
            }
            Slider {
                id: widthSlider
                from: 300
                to: 600
                stepSize: 1
                value: 450
            }
        }
    }
}

// category: Panel
