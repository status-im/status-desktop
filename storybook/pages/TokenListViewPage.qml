import QtQuick 2.15
import QtQuick.Controls 2.15

import Models 1.0
import Storybook 1.0

import shared.popups.send.views 1.0

import AppLayouts.Wallet.stores 1.0

import StatusQ.Core.Utils 0.1

SplitView {
    orientation: Qt.Vertical

    readonly property WalletAssetsStore walletAssetStore: WalletAssetsStore {
        assetsWithFilteredBalances: groupedAccountsAssetsModel
    }

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

            assets: walletAssetStore.groupedAccountAssetsModel
            collectibles: WalletNestedCollectiblesModel {}
            networksModel: NetworksModel.allNetworks
            getCurrencyAmountFromBigInt: function(balance, symbol, decimals){
                let bigIntBalance = AmountsArithmetic.fromString(balance)
                let balance123 = AmountsArithmetic.toNumber(bigIntBalance, decimals)
                return ({
                            amount: balance123,
                            symbol: symbol,
                            displayDecimals: 2,
                            stripTrailingZeroes: false
                        })
            }
            getCurrentCurrencyAmount: function(balance){
                return ({
                            amount: balance,
                            symbol: "USD",
                            displayDecimals: 2,
                            stripTrailingZeroes: false
                        })
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
