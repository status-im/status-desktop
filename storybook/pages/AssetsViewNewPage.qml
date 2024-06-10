import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import shared.views 1.0
import utils 1.0

import Storybook 1.0

import Qt.labs.settings 1.1

SplitView {
    id: root

    ListModel {
        id: assetsModel

        function format(amount, symbol) {
            return `${amount.toLocaleString(Qt.locale())} ${symbol}`
        }

        Component.onCompleted: {
            const data = [
                {
                    key: "key_ETH",
                    symbol: "ETH",
                    name: "Ether",
                    icon: Constants.tokenIcon("ETH", false),
                    balance: 10.0,
                    balanceText: format(10.0, "ETH"),
                    error: "",

                    marketDetailsAvailable: true,
                    marketDetailsLoading: true,
                    marketPrice: 0,
                    marketChangePct24hour: 0,

                    communityId: "",
                    communityName: "",
                    communityIcon: Qt.resolvedUrl(""),

                    position: 2,
                    canBeHidden: false
                },
                {
                    key: "key_SNT",
                    symbol: "SNT",
                    name: "Status",
                    icon: Constants.tokenIcon("SNT", false),
                    balance: 20023.0,
                    balanceText: format(20023.0, "SNT"),
                    error: "",

                    marketDetailsAvailable: true,
                    marketDetailsLoading: false,
                    marketPrice: 50.23,
                    marketChangePct24hour: 12,

                    communityId: "",
                    communityName: "",
                    communityIcon: Qt.resolvedUrl(""),

                    position: 1,
                    canBeHidden: true
                },
                {
                    key: "key_MCT",
                    symbol: "MCT",
                    name: "My custom token",
                    icon: Constants.tokenIcon("ZRX", false),
                    balance: 102.4,
                    balanceText: format(102.4, "MCT"),
                    error: "",

                    marketDetailsAvailable: false,
                    marketDetailsLoading: false,
                    marketPrice: 0,
                    marketChangePct24hour: 0,

                    communityId: "34",
                    communityName: "Crypto Kitties",
                    communityIcon: Constants.tokenIcon("DAI", false),

                    position: 4,
                    canBeHidden: true
                },
                {
                    key: "key_DAI",
                    symbol: "DAI",
                    name: "Dai",
                    icon: Constants.tokenIcon("DAI", false),
                    balance: 123.24,
                    balanceText: format(123.24, "DAI"),
                    error: "",

                    marketDetailsAvailable: true,
                    marketDetailsLoading: false,
                    marketPrice: 23.23,
                    marketChangePct24hour: 2.3,

                    communityId: "",
                    communityName: "",
                    communityIcon: Qt.resolvedUrl(""),

                    position: 3,
                    canBeHidden: true
                },
                {
                    key: "key_USDT",
                    symbol: "USDT",
                    name: "USDT",
                    icon: Constants.tokenIcon("USDT", false),
                    balance: 15.24,
                    balanceText: format(15.24, "USDT"),
                    error: "",

                    marketDetailsAvailable: true,
                    marketDetailsLoading: false,
                    marketPrice: 0.99,
                    marketChangePct24hour: 0,

                    communityId: "",
                    communityName: "",
                    communityIcon: Qt.resolvedUrl(""),

                    position: 5,
                    canBeHidden: true
                },
                {
                    key: "key_TBT",
                    symbol: "TBT",
                    name: "The best token",
                    icon: Constants.tokenIcon("UNI", false),
                    balance: 102,
                    balanceText: format(102, "TBT"),
                    error: "Pocket Network (POKT) & Infura are currently both "
                               + "unavailable for %1. %1 balances are as of %2."
                               .arg("TBT").arg("10/06/2024"),

                    marketDetailsAvailable: false,
                    marketDetailsLoading: false,
                    marketPrice: 0,
                    marketChangePct24hour: 0,

                    communityId: "3423",
                    communityName: "Best tokens",
                    communityIcon: Constants.tokenIcon("UNI", false),

                    position: 6,
                    canBeHidden: true
                }
            ]

            append(data)
        }
    }

    SplitView {
        SplitView.fillWidth: true
        SplitView.fillHeight: true

        orientation: Qt.Vertical

        Pane {
            SplitView.fillWidth: true
            SplitView.fillHeight: true

            AssetsViewNew {
                anchors.fill: parent

                loading: loadingCheckBox.checked
                sorterVisible: sorterVisibleCheckBox.checked
                customOrderAvailable: customOrderAvailableCheckBox.checked

                sendEnabled: sendEnabledCheckBox.checked
                swapEnabled: swapEnabledCheckBox.checked
                swapVisible: swapVisibleCheckBox.checked

                balanceError: balanceErrorCheckBox.checked
                              ? "Balance error!" : ""

                marketDataError: marketDataErrorCheckBox.checked
                                 ? "Market data error!" : ""

                model: assetsModel

                onSendRequested: logs.logEvent(`send requested: ${key}`)
                onReceiveRequested: logs.logEvent(`receive requested: ${key}`)
                onSwapRequested: logs.logEvent(`swap requested: ${key}`)
                onAssetClicked: logs.logEvent(`asset clicked: ${key}`)

                onHideRequested: logs.logEvent(`hide requested: ${key}`)
                onHideCommunityAssets: logs.logEvent(`hide community assets requested: ${communityKey}`)
                onManageTokensRequested: logs.logEvent(`manage tokens requested`)
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
            CheckBox {
                id: loadingCheckBox

                text: "loading"
            }
            CheckBox {
                id: sorterVisibleCheckBox

                text: "sorter visible"
            }
            CheckBox {
                id: customOrderAvailableCheckBox

                text: "custom order available"
            }
            CheckBox {
                id: sendEnabledCheckBox

                text: "send enabled"
            }
            CheckBox {
                id: swapEnabledCheckBox

                text: "swap enabled"
            }
            CheckBox {
                id: swapVisibleCheckBox

                text: "swap visible"
            }
            CheckBox {
                id: balanceErrorCheckBox

                text: "balance error"
            }
            CheckBox {
                id: marketDataErrorCheckBox

                text: "market data error"
            }
        }
    }

    Settings {
        property alias loading: loadingCheckBox.checked
        property alias filterVisible: sorterVisibleCheckBox.checked
        property alias customOrderAvailable: customOrderAvailableCheckBox.checked
        property alias sendEnabled: sendEnabledCheckBox.checked
        property alias swapEnabled: swapEnabledCheckBox.checked
        property alias swapVisible: swapVisibleCheckBox.checked
        property alias balanceError: balanceErrorCheckBox.checked
        property alias marketDataError: marketDataErrorCheckBox.checked
    }
}

// category: Views
