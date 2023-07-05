import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import Models 1.0
import Storybook 1.0
import utils 1.0

import shared.popups 1.0
import shared.stores 1.0

SplitView {
    id: root

    orientation: Qt.Vertical

    Item {
        SplitView.fillWidth: true
        SplitView.fillHeight: true

        Rectangle {
            anchors.fill: parent
            color: "lightgray"
        }

        Loader {
            id: loader

            active: false

            sourceComponent: SendModal {
                visible: true
                modal: false
                closePolicy: Popup.NoAutoClose

                store: TransactionStore {
                    readonly property QtObject selectedSenderAccount: QtObject {
                        readonly property var assets: WalletAssetsModel {}
                    }

                    readonly property QtObject walletSectionSendInst: QtObject {}
                    readonly property QtObject mainModuleInst: QtObject {}

                    readonly property var savedAddressesModel: ListModel {
                        Component.onCompleted: {
                            for (let i = 0; i < 10; i++)
                                append({
                                    name: "some saved addr name " + i,
                                    ens: [],
                                    address: "0x2B748A02e06B159C7C3E98F5064577B96E55A7b4",
                                    chainShortNames: "eth:arb"
                                })
                        }
                    }

                    function splitAndFormatAddressPrefix(textAddrss, isBridgeTx, showUnpreferredNetworks) {
                        return textAddrss
                    }

                    function resolveENS() {
                        return ""
                    }


                    readonly property string currentCurrency: "USD"

                    readonly property QtObject currencyStore: QtObject {
                        readonly property string currentCurrency: "USD"

                        function formatCurrencyAmount() {
                            return "42"
                        }

                        function getFiatValue() {
                            return "42.42"
                        }
                    }

                    function getAllNetworksSupportedString() {
                        return "OPT"
                    }

                    function plainText(text) {
                        return text
                    }

                    function setDefaultPreferredDisabledChains() {}

                    function prepareTransactionsForAddress(address) {
                        console.log("prepareTransactionsForAddress:", address)
                    }

                    function getTransactions() {
                        return transactions
                    }

                    readonly property var transactions_: ListModel {
                        id: transactions

                        Component.onCompleted: {
                            for (let i = 0; i < 10; i++)
                                append({
                                    to: "to",
                                    loadingTransaction: false,
                                    value: {
                                               displayDecimals: true,
                                               stripTrailingZeroes: true,
                                               amount: 3.234
                                           },
                                    timestamp: new Date()
                                })
                        }
                    }

                    function findTokenSymbolByAddress() {
                        return "ETH"
                    }
                }
            }

            Component.onCompleted: {
                RootStore.currencyStore = {
                    currentCurrencySymbol: "USD"
                }

                RootStore.getNetworkIcon = () => "network/Network=Optimism"

                loader.active = true
            }
        }
    }

    LogsAndControlsPanel {
        SplitView.minimumHeight: 100
        SplitView.preferredHeight: 100

        SplitView.fillWidth: true
    }
}
