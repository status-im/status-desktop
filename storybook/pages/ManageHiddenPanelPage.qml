import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15

import StatusQ 0.1
import StatusQ.Core 0.1
import StatusQ.Models 0.1

import AppLayouts.Wallet.panels 1.0
import AppLayouts.Wallet.stores 1.0

import utils 1.0

import Storybook 1.0
import Models 1.0

SplitView {
    id: root

    Logs { id: logs }

    orientation: Qt.Horizontal

    readonly property WalletAssetsStore walletAssetStore: WalletAssetsStore {
        assetsWithFilteredBalances: groupedAccountsAssetsModel
    }

    ManageCollectiblesModel {
        id: collectiblesModel
    }

    RolesRenamingModel {
        id: renamedModel
        sourceModel: collectiblesModel
        mapping: [
            RoleRename {
                from: "uid"
                to: "symbol"
            }
        ]
    }

    ManageTokensController {
        id: assetsController
        sourceModel: ctrlEmptyModel.checked ? null : walletAssetStore.groupedAccountAssetsModel
        settingsKey: "WalletAssets"
    }

    ManageTokensController {
        id: collectiblesController
        sourceModel: ctrlEmptyModel.checked ? null : renamedModel
        settingsKey: "WalletCollectibles"
    }

    StatusScrollView { // wrapped in a ScrollView on purpose; to simulate SettingsContentBase.qml
        SplitView.fillWidth: true
        SplitView.fillHeight: true
        Component.onCompleted: forceActiveFocus()

        ManageHiddenPanel {
            id: showcasePanel
            width: 500
            assetsController: assetsController
            collectiblesController: collectiblesController

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
                text: "Has saved settings: %1".arg(showcasePanel.hasSettings ? "true" : "false")
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

            Label {
                text: "Hidden community groups:"
            }
            Label {
                text: assetsController.hiddenCommunityGroups.concat(collectiblesController.hiddenCommunityGroups).join()
            }

            Label {
                text: "Hidden collection groups:"
            }
            Label {
                text: assetsController.hiddenCollectionGroups.concat(collectiblesController.hiddenCollectionGroups).join()
            }
        }
    }
}

// category: Panels

// https://www.figma.com/file/eM26pyHZUeAwMLviaS1KJn/%E2%9A%99%EF%B8%8F-Wallet-Settings%3A-Manage-Tokens?type=design&node-id=12-126364&mode=design&t=ZqKtOXpYtpReg4oL-0
// https://www.figma.com/file/eM26pyHZUeAwMLviaS1KJn/%E2%9A%99%EF%B8%8F-Wallet-Settings%3A-Manage-Tokens?type=design&node-id=40-127902&mode=design&t=ZqKtOXpYtpReg4oL-0
// https://www.figma.com/file/eM26pyHZUeAwMLviaS1KJn/%E2%9A%99%EF%B8%8F-Wallet-Settings%3A-Manage-Tokens?type=design&node-id=577-130046&mode=design&t=ZqKtOXpYtpReg4oL-0
// https://www.figma.com/file/eM26pyHZUeAwMLviaS1KJn/%E2%9A%99%EF%B8%8F-Wallet-Settings%3A-Manage-Tokens?type=design&node-id=577-151896&mode=design&t=ZqKtOXpYtpReg4oL-0
