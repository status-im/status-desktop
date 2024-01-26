import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15

import StatusQ.Core 0.1
import StatusQ.Models 0.1

import utils 1.0

import Storybook 1.0
import Models 1.0

import AppLayouts.Wallet.panels 1.0
import AppLayouts.Wallet.stores 1.0

SplitView {
    id: root

    Logs { id: logs }

    orientation: Qt.Horizontal

    readonly property WalletAssetsStore walletAssetStore: WalletAssetsStore {
        assetsWithFilteredBalances: groupedAccountsAssetsModel
    }

    ManageAssetsPanel {
        id: showcasePanel

        SplitView.fillWidth: true
        SplitView.fillHeight: true

        getCurrencyAmount: function (balance, symbol) {
            return ({
                amount: balance,
                symbol: symbol,
                displayDecimals: 2,
                stripTrailingZeroes: false
            })
        }
        getCurrentCurrencyAmount: function (balance) {
            return ({
                amount: balance,
                symbol: "USD",
                displayDecimals: 2,
                stripTrailingZeroes: false
            })
        }

        controller: ManageTokensController {
            sourceModel: ctrlEmptyModel.checked ? null : walletAssetStore.groupedAccountAssetsModel
            settingsKey: "WalletAssets"
        }
    }

    LogsAndControlsPanel {
        id: logsAndControlsPanel

        SplitView.minimumWidth: 150
        SplitView.preferredWidth: 250

        logsView.logText: logs.logText

        ColumnLayout {
            Label {
                Layout.fillWidth: true
                text: "Dirty: %1".arg(showcasePanel.dirty ? "true" : "false")
            }

            Label {
                Layout.fillWidth: true
                text: "Has saved settings: %1".arg(showcasePanel.hasSettings ? "true" : "false")
            }

            Button {
                enabled: showcasePanel.dirty
                text: "Save"
                onClicked: showcasePanel.saveSettings()
            }

            Button {
                text: "Revert"
                onClicked: showcasePanel.revert()
            }

            Button {
                enabled: showcasePanel.hasSettings
                text: "Clear settings"
                onClicked: showcasePanel.clearSettings()
            }

            Switch {
                id: ctrlEmptyModel
                text: "Empty model"
            }
        }
    }
}

// category: Panels

// https://www.figma.com/file/FkFClTCYKf83RJWoifWgoX/Wallet-v2?type=design&node-id=18139-95033&mode=design&t=nqFScWLfusXBNQA5-0
// https://www.figma.com/file/FkFClTCYKf83RJWoifWgoX/Wallet-v2?type=design&node-id=17674-273051&mode=design&t=nqFScWLfusXBNQA5-0
// https://www.figma.com/file/FkFClTCYKf83RJWoifWgoX/Wallet-v2?type=design&node-id=17636-249780&mode=design&t=nqFScWLfusXBNQA5-0
// https://www.figma.com/file/FkFClTCYKf83RJWoifWgoX/Wallet-v2?type=design&node-id=17674-276833&mode=design&t=nqFScWLfusXBNQA5-0
// https://www.figma.com/file/FkFClTCYKf83RJWoifWgoX/Wallet-v2?type=design&node-id=17675-283206&mode=design&t=nqFScWLfusXBNQA5-0
