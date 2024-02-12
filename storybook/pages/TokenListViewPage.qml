import QtQuick 2.15
import QtQuick.Controls 2.15

import Models 1.0
import Storybook 1.0

import shared.popups.send.views 1.0

import AppLayouts.Wallet.stores 1.0

import StatusQ.Core.Utils 0.1

import shared.stores 1.0
import shared.stores.send 1.0

SplitView {
    id: root

    orientation: Qt.Vertical

    readonly property WalletAssetsStore walletAssetStore: WalletAssetsStore {
        assetsWithFilteredBalances: groupedAccountsAssetsModel
    }

    TransactionStore {
        id: txStore
        walletAssetStore: root.walletAssetStore
    }

    readonly property CurrenciesStore currencyStore: CurrenciesStore {}

    Item {
        SplitView.fillWidth: true
        SplitView.fillHeight: true

        Rectangle {
            anchors.fill: parent
            color: "lightgray"
        }

        TokenListView {
            anchors.centerIn: parent

            width: 400
            height: 600

            assets: txStore.processedAssetsModel
            collectibles: WalletNestedCollectiblesModel {}
            networksModel: NetworksModel.allNetworks
            formatCurrentCurrencyAmount: function(balance){
                return currencyStore.formatCurrencyAmount(balance, "USD")
            }
            formatCurrencyAmountFromBigInt: function(balance, symbol, decimals){
                let bigIntBalance = AmountsArithmetic.fromString(balance)
                let decimalBalance = AmountsArithmetic.toNumber(bigIntBalance, decimals)
                return currencyStore.formatCurrencyAmount(decimalBalance, symbol)
            }
        }
    }

    LogsAndControlsPanel {
        SplitView.minimumHeight: 100
        SplitView.preferredHeight: 100

        SplitView.fillWidth: true
    }
}

// category: Views
