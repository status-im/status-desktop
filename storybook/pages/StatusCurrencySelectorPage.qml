import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import StatusQ
import StatusQ.Core
import StatusQ.Controls
import StatusQ.Components

import Storybook

import utils

SplitView {
    id: root
    orientation: Qt.Vertical

    Logs { id: logs }

    ListModel {
        id: mockCurrenciesModel
        ListElement {
            key: "usd"
            shortName: "USD"
            name: qsTr("US Dollars")
            symbol: "$"
            category: ""
            imageSource: ""
            emoji: "🇺🇸"
            selected: false
            isToken: false
        }
        ListElement {
            key: "gbp"
            shortName: "GBP"
            name: qsTr("British Pound")
            symbol: "£"
            category: ""
            imageSource: ""
            emoji: "🇬🇧"
            selected: false
            isToken: false
        }
        ListElement {
            key: "eur"
            shortName: "EUR"
            name: qsTr("Euros")
            symbol: "€"
            category: ""
            imageSource: ""
            emoji: "🇪🇺"
            selected: false
            isToken: false
        }
        ListElement {
            key: "eth"
            shortName: "ETH"
            name: qsTr("Ethereum")
            symbol: "Ξ"
            category: qsTr("Tokens")
            imageSource: "../../assets/png/tokens/ETH.png"
            emoji: ""
            selected: false
            isToken: true
        }
        ListElement {
            key: "czk"
            shortName: "CZK"
            name: qsTr("Czech koruna")
            symbol: "Kč"
            category: qsTr("Other Fiat")
            imageSource: ""
            emoji: "🇨🇿"
            selected: false
            isToken: false
        }
        ListElement {
            key: "btc"
            shortName: "BTC"
            name: qsTr("Bitcoin")
            symbol: "฿"
            category: qsTr("Tokens")
            imageSource: "../../assets/png/tokens/WBTC.png"
            emoji: ""
            selected: false
            isToken: true
        }
    }

    Item {
        SplitView.fillWidth: true
        SplitView.fillHeight: true

        StatusCurrencySelector {
            anchors.centerIn: parent
            enabled: ctrlEnabled.checked
            currentCurrency: ctrlCurrentCurrency.text.toUpperCase()
            currenciesModel: mockCurrenciesModel
            onCurrencySelected: function(shortName) {
                logs.logEvent("onCurrencySelected", ["shortName"], arguments)
                currentCurrency = shortName
            }
        }
    }

    LogsAndControlsPanel {
        id: logsAndControlsPanel

        SplitView.minimumHeight: 200
        SplitView.preferredHeight: 200

        logsView.logText: logs.logText

        ColumnLayout {
            anchors.fill: parent
            Switch {
                id: ctrlEnabled
                text: "Enabled"
                checked: true
            }
            RowLayout {
                Layout.fillWidth: true
                Label { text: "Current currency:" }
                TextField {
                    Layout.preferredWidth: 150
                    id: ctrlCurrentCurrency
                    text: "CZK"
                    placeholderText: "Currency code"
                }
            }
        }
    }
}

// category: Components
// status: good
